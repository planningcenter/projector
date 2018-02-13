//
//  MCTDocument.m
//  MCTDocument
//
//  Created by Skylar Schipper on 3/27/14.
//

#import "MCTDocument.h"
#import "MCTDocumentParsers.h"

#include <CommonCrypto/CommonDigest.h>

@interface MCTDocument () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *loadingView;
@property (nonatomic, copy) void(^parseCompletion)(MCTDocument *, NSError *);
@property (nonatomic, assign, readwrite) NSUInteger count;
@property (nonatomic, strong, readwrite) NSDictionary *userInfo;
@property (nonatomic, strong, readwrite) NSString *documentPath;
@property (nonatomic, strong) NSCache *slideCache;
@property (nonatomic, strong) NSString *documentParseDatePath;

@end

@implementation MCTDocument

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = filePath;
        self.count = 0;
        [self preLoadData];
    }
    return self;
}

- (BOOL)isParsed {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.documentParseDatePath];
}

- (void)parseWithCompletion:(void(^)(MCTDocument *document, NSError *error))completion {
    _parsing = YES;
    self.parseCompletion = [completion copy];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        NSString *fileExt = [self.filePath pathExtension];
        NSString *mimeType = [[self class] mimeTypeForExtention:fileExt];
        _parser = [self newParserForFileWithMimeType:mimeType];

        [self.parser setTargetPath:self.documentPath];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.filePath]];


            self.loadingView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.loadingView.delegate = self;
            [self.loadingView loadRequest:request];
        });
    });
}

- (void)completeWithError:(NSError *)error {
    _parsing = NO;
    self.loadingView.delegate = nil;
    self.loadingView = nil;
    _parser = nil;
    if (error) {
        self.count = 0;
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.documentParseDatePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:self.documentParseDatePath error:nil];
        }
    } else {
        [[NSString stringWithFormat:@"%@",[NSDate date]] writeToFile:self.documentParseDatePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    if (self.parseCompletion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.parseCompletion(self, error);
            self.parseCompletion = nil;
        });
    }
}

- (void)parseHTMLString:(NSString *)HTML javascript:(NSDictionary *)javascript {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        [self.parser parseHTML:HTML javascriptResults:javascript];

        NSError *error = nil;
        if (![self.parser writeToTargetPath:&error]) {
            [self completeWithError:error];
            return;
        }

        error = nil;
        NSMutableDictionary *info = [[self.parser infoDictionary] mutableCopy];
        info[kMCTDocumentInfoUUID] = [[NSUUID UUID] UUIDString];
        info[kMCTDocumentInfoCreated] = @([[NSDate date] timeIntervalSince1970]);

        NSString *fileExt = [self.filePath pathExtension];
        NSString *mimeType = [[self class] mimeTypeForExtention:fileExt];
        info[kMCTDocumentMimeType] = (mimeType) ?: [NSNull null];

        if (![self writeInfo:info error:&error]) {
            [self completeWithError:error];
            return;
        }

        if (![self addSkipBackupToFiles]) {
            [self completeWithError:[NSError errorWithDomain:MCTDocumentErrorDomain code:100 userInfo:nil]];
        }

        self.count = [self.parser count];

        [self completeWithError:nil];
    });
}

- (void)preLoadData {
    if ([self isParsed]) {
        NSNumber *count = self.userInfo[kMCTDocumentSlideCount];
        NSString *slideDir = [[self.userInfo[kMCTDocumentSlidePath] pathComponents] firstObject];
        slideDir = [self.documentPath stringByAppendingPathComponent:slideDir];

        NSError *loadError = nil;
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:slideDir error:&loadError];

        if (!contents || loadError) {
#if DEBUG
            NSLog(@"Failed to get contents: %@",loadError);
#endif
            [self bustParse];
            return;
        }
        if (contents.count != [count unsignedIntegerValue]) {
#if DEBUG
            NSLog(@"Count's don't match: %@ != %lu",count,(unsigned long)contents.count);
#endif
            [self bustParse];
            return;
        }

        self.count = contents.count;
    }
}

- (void)bustParse {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.documentParseDatePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.documentParseDatePath error:nil];
    }
}

#pragma mark -
#pragma mark - Writers
- (BOOL)writeInfo:(NSDictionary *)info error:(NSError **)error {
    self.userInfo = [info copy];
    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:error];
    if (!data) {
        return NO;
    }
    return [data writeToFile:[self.documentPath stringByAppendingPathComponent:@"Info.json"] options:NSDataWritingAtomic error:error];
}

- (NSDictionary *)userInfo {
    if (!_userInfo) {
        NSData *data = [NSData dataWithContentsOfFile:[self.documentPath stringByAppendingPathComponent:@"Info.json"]];
        if (!data) {
            _userInfo = @{};
        } else {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (!json) {
                _userInfo = @{};
            } else {
                _userInfo = [json copy];
            }
        }
    }
    return _userInfo;
}

#pragma mark -
#pragma mark - Parser
- (id<MCTDocumentParser>)newParserForFileWithMimeType:(NSString *)mimeType {
    if ([mimeType isEqualToString:MCTDocumentPowerPointXParserMimeType]) {
        return [[MCTDocumentPowerPointXParser alloc] init];
    }
    return nil;
}
+ (NSString *)mimeTypeForExtention:(NSString *)extention {
    if (extention.length == 0) {
        return @"application/octet-stream";
    }
#if TARGET_OS_IPHONE
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extention, NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!mimeType) {
        return @"application/octet-stream";
    } else {
        NSString *type = (__bridge NSString *)mimeType;
        CFRelease(mimeType);
        return type;
    }
#endif
    return @"application/octet-stream";
}

#pragma mark -
#pragma mark - Web View Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *HTML = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    if (HTML.length == 0) {
        [self completeWithError:[NSError errorWithDomain:MCTDocumentErrorDomain code:2 userInfo:nil]];
        return;
    }

    NSMutableDictionary *js = nil;
    if ([self.parser respondsToSelector:@selector(webViewJavaScript)]) {
        NSDictionary *scripts = [self.parser webViewJavaScript];
        js = [NSMutableDictionary dictionaryWithCapacity:scripts.count];
        for (NSString *key in scripts) {
            NSString *value = [webView stringByEvaluatingJavaScriptFromString:scripts[key]];
            if (value) {
                js[key] = value;
            }
        }
    }

    [self parseHTMLString:HTML javascript:js];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self completeWithError:error];
}

#pragma mark -
#pragma mark - Paths
+ (NSString *)documentsPath {
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"web-docs"];
    });
    return path;
}
- (NSString *)documentPath {
    if (!_documentPath) {
        NSString *path = [[self class] documentsPath];
        _documentPath = [path stringByAppendingPathComponent:[self MD5Checksum]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_documentPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_documentPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return _documentPath;
}
- (NSString *)documentParseDatePath {
    if (!_documentParseDatePath) {
        _documentParseDatePath = [self.documentPath stringByAppendingPathComponent:@"_parse_date"];
    }
    return _documentParseDatePath;
}
- (BOOL)addSkipBackupToFiles {
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:self.documentPath] includingPropertiesForKeys:[NSArray array] options:0 errorHandler:^BOOL(NSURL *url, NSError *error) {
        return YES;
    }];

    for (NSURL *URL in enumerator) {
        NSError *error = nil;
        if (![URL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error]) {
            NSLog(@"%@",error);
            return NO;
        }
    }

    return YES;
}

- (NSString *)MD5Checksum {
    CFReadStreamRef readStream = NULL;
    CFStringRef filePath = (__bridge CFStringRef)(self.filePath);

    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, filePath, kCFURLPOSIXPathStyle, (Boolean)false);
    if (!fileURL) {
        return nil;
    }

    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, (CFURLRef)fileURL);
    if (!readStream) {
        CFRelease(fileURL);
        return nil;
    }
    if (!(Boolean)CFReadStreamOpen(readStream)) {
        CFRelease(fileURL);
        CFRelease(readStream);
        return nil;
    }

    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);

    size_t readSize = 4096;

    BOOL moreData = YES;
    while (moreData) {
        UInt8 buffer[readSize];
        CFIndex count = CFReadStreamRead(readStream, buffer, sizeof(buffer));
        if (count == -1) {
            break;
        }
        if (count == 0) {
            moreData = NO;
            continue;
        }
        CC_MD5_Update(&hashObject, (const void *)buffer, (CC_LONG)readSize);
    }

    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);

    if (moreData) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
        CFRelease(fileURL);
        return nil;
    }

    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    CFStringRef result = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)hash, kCFStringEncodingUTF8);

    NSString *hashString = nil;

    if (result) {
        hashString = (__bridge NSString *)(result);
    }

    CFRelease(result);
    CFReadStreamClose(readStream);
    CFRelease(readStream);
    CFRelease(fileURL);

    return hashString;
}

#pragma mark -
#pragma mark - Slides
- (NSCache *)slideCache {
    if (!_slideCache) {
        _slideCache = [[NSCache alloc] init];
    }
    return _slideCache;
}
- (MCTDocumentSlide *)slideForIndex:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%zd",index];
    MCTDocumentSlide *slide = [self.slideCache objectForKey:key];
    if (slide) {
        return slide;
    }

    slide = [self newSlideForIndex:index];
    if (slide) {
        [self.slideCache setObject:slide forKey:key];
    }

    return slide;
}
- (MCTDocumentSlide *)newSlideForIndex:(NSInteger)index {
    return [[MCTDocumentSlide alloc] initWithBasePath:self.documentPath slidePath:self.userInfo[kMCTDocumentSlidePath] index:index];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p slides:%tu name:%@>",NSStringFromClass([self class]),self,self.count,[self.documentPath lastPathComponent]];
}

@end

NSString * const MCTDocumentErrorDomain = @"MCTDocumentErrorDomain";
NSString * const kMCTDocumentInfoUUID = @"kMCTDocumentInfoUUID";
NSString * const kMCTDocumentInfoCreated = @"kMCTDocumentInfoCreated";
NSString * const kMCTDocumentSlidePath = @"kMCTDocumentSlidePath";
NSString * const kMCTDocumentSlideCount = @"slideCount";
NSString * const kMCTDocumentMimeType = @"kMCTDocumentMimeType";
