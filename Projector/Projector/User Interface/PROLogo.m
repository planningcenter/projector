/*!
 * PROLogo.m
 *
 *
 * Created by Skylar Schipper on 6/26/14
 */

@import AVFoundation;
@import MobileCoreServices;

#import "PROLogo.h"
#import "PROThumbnailGenerator.h"
#import "PCOSafeCoreDataManagedObject.h"

static NSArray *_logosCache;
static NSString *const PROLogoFilePathString = @"logos-t4r";

@interface PROLogo () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong, readwrite) NSString *UUID;

@property (nonatomic, strong) NSData *data;

@property (nonatomic, strong, readwrite) NSProgress *progress;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic) PROLogoThumbnailGenerator thumbnailGenerator;

@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, strong) NSURL *originalDownloadURL;

@property (nonatomic) BOOL lastDownloadDidFail;

@end

@implementation PROLogo
@synthesize mimeType = _mimeType;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.UUID = [[NSUUID UUID] UUIDString];
        self.addedDate = [NSDate date];
        self.fileName = [self.UUID stringByAppendingPathExtension:@"dat"];
        self.attachmentID = @"0";
        self.localizedName = NSLocalizedString(@"My Logo", nil);
        self.mediaID = @0;
        self.lastDownloadDidFail = NO;
        
        [self generateThumbnailIfNeededCompletion:nil];
        
        welf();
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            welf.data = nil;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [welf cancelDownload];
        }];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)save:(NSError **)error {
    NSString *filePath = [self fileInfoPath];
    NSDictionary *info = @{
                           @"uuid": self.UUID,
                           @"name": PCOSafe(self.fileName),
                           @"attachmentID": PCOSafe(self.attachmentID),
                           @"addedDate": @([self.addedDate timeIntervalSince1970]),
                           @"localizedName": PCOSafe(self.localizedName),
                           @"userInfo": PCOSafe(self.userInfo),
                           @"mimeType": PCOSafe(self.mimeType),
                           @"thumbnailGenerator": @(self.thumbnailGenerator),
                           @"mediaID": PCOSafe(self.mediaID),
                           @"originalDownloadURL": PCOSafe([self.originalDownloadURL absoluteString]),
                           @"lastDownloadDidFail": @(self.lastDownloadDidFail)
                           };
    
    NSError *jsonError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (!data || jsonError) {
        if (error != NULL) {
            *error = jsonError;
        }
        return NO;
    }
    
    NSError *writeError = nil;
    if (![data writeToFile:filePath options:NSDataWritingAtomic error:&writeError]) {
        if (error != NULL) {
            *error = writeError;
        }
        return NO;
    }
    
    if (error != NULL) {
        *error = nil;
    }
    
    if ([_logosCache containsObject:self]) {
        return YES;
    }
    
    NSMutableArray *array = [_logosCache mutableCopy];
    if (!array) {
        array = [NSMutableArray array];
    }
    
    [array insertObject:self atIndex:0];
    
    _logosCache = [array copy];
    
    return YES;
}
- (BOOL)saveWithData:(NSData *)data error:(NSError **)error {
    if (![data writeToFile:[self filePath] options:NSDataWritingAtomic error:error]) {
        return NO;
    }
    return [self save:error];
}
- (BOOL)saveWithFile:(NSURL *)fileURL error:(NSError **)error {
    if (![[NSFileManager defaultManager] copyItemAtPath:[fileURL path] toPath:[self filePath] error:error]) {
        return NO;
    }
    return [self save:error];
}

- (BOOL)destroy:(NSError **)error {
    NSString *thumbPath = [[self fileThumbnailURL] path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
        NSError *deleteError = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:thumbPath error:&deleteError]) {
            if (error != NULL) {
                *error = deleteError;
            }
            return NO;
        }
    }
    
    NSString *filePath = [self filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *deleteError = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&deleteError]) {
            if (error != NULL) {
                *error = deleteError;
            }
            return NO;
        }
    }
    
    NSString *infoPath = [self fileInfoPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:infoPath]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:infoPath error:error]) {
            return NO;
        }
    }
    
    [[self class] clear];
    
    return YES;
}

- (void)loadWithCompletion:(void(^)(NSData *, NSError *))completion {
    if (self.data) {
        if (completion) {
            completion(self.data, nil);
        }
        return;
    }
    
    NSString *fullPath = [self filePath];
    
    NSError *existsError = nil;
    if (![self fileExists:&existsError]) {
        if (completion) {
            completion(nil, existsError);
        }
        return;
    }
    
    NSError *readError = nil;
    NSData *data = [NSData dataWithContentsOfFile:fullPath options:NSDataReadingMappedIfSafe error:&readError];
    self.data = data;
    if (completion) {
        completion(data, readError);
    }
}
- (BOOL)fileExists:(NSError **)error {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:PROLogoErrorDomain code:404 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"File not found", nil)}];
        }
        return NO;
    }
    return YES;
}

- (NSString *)filePath {
    return [[[self class] logoFileAssetPath] stringByAppendingPathComponent:self.fileName];
}
- (NSString *)fileInfoPath {
    return [[[self class] logoFilePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.logo",self.UUID]];
}
- (NSString *)fileResumeDataFilePath {
    NSString *path = [[[self class] logoFilePath] stringByAppendingPathComponent:@"suspended"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            PCOLogError(@"%@",error);
            return nil;
        }
    }
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.download",self.UUID]];
}

- (NSString *)mimeType {
    if (!_mimeType || _mimeType.length == 0) {
        _mimeType = @"application/octet-stream";
    }
    return _mimeType;
}

+ (NSString *)logoFilePath {
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:PROLogoFilePathString];
    });
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *createDirError = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&createDirError]) {
            PCOLogError(@"%@",createDirError);
        }
    }
    return path;
}
+ (NSString *)logoFileAssetPath {
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [[self logoFilePath] stringByAppendingPathComponent:@"assets"];
    });
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *createDirError = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&createDirError]) {
            PCOLogError(@"%@",createDirError);
        }
    }
    return path;
}
+ (NSArray *)allLogos {
    return [self allLogosFetchFresh:NO];
}
+ (NSArray *)allLogosFetchFresh:(BOOL)flush {
    if (flush) {
        [self clear];
    }
    if (!_logosCache) {
        _logosCache = [self _fetchLogosList];
    }
    return _logosCache;
}
+ (NSArray *)_fetchLogosList {
    NSMutableSet *nameSet = [NSMutableSet setWithCapacity:100];
    for (NSString *name in [[NSFileManager defaultManager] enumeratorAtPath:[self logoFilePath]]) {
        if ([[name pathExtension] isEqualToString:@"logo"]) {
            PROLogo *logo = [self newLogoForFileName:name];
            if (name) {
                [nameSet addObject:logo];
            }
        }
    }
    return [nameSet sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"addedDate" ascending:NO]]];
}

+ (void)clear {
    _logosCache = nil;
}

+ (instancetype)newLogoForFileName:(NSString *)fileName {
    NSString *filePath = [[self logoFilePath] stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        return nil;
    }
    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (!info) {
        return nil;
    }
    PROLogo *logo = [[PROLogo alloc] init];
    [logo _setFromJSON:info];
    return logo;
}
- (void)_setFromJSON:(NSDictionary *)JSON {
    if (JSON[@"uuid"]) {
        self.UUID = JSON[@"uuid"];
    }
    if (JSON[@"name"]) {
        self.fileName = PCOCocoaNullToNil(JSON[@"name"]);
    }
    if (JSON[@"attachmentID"]) {
        self.attachmentID = PCOCocoaNullToNil(JSON[@"attachmentID"]);
    }
    if (JSON[@"addedDate"]) {
        self.addedDate = [NSDate dateWithTimeIntervalSince1970:[JSON[@"addedDate"] floatValue]];
    }
    if (JSON[@"localizedName"]) {
        self.localizedName = PCOCocoaNullToNil(JSON[@"localizedName"]);
    }
    if (JSON[@"userInfo"]) {
        self.userInfo = PCOCocoaNullToNil(JSON[@"userInfo"]);
    }
    if (JSON[@"mimeType"]) {
        self.mimeType = PCOCocoaNullToNil(JSON[@"mimeType"]);
    }
    if (JSON[@"thumbnailGenerator"]) {
        self.thumbnailGenerator = [JSON[@"thumbnailGenerator"] integerValue];
    }
    if (JSON[@"mediaID"]) {
        self.mediaID = PCOCocoaNullToNil(JSON[@"mediaID"]);
    }
    if (JSON[@"originalDownloadURL"]) {
        NSString *URLString = PCOCocoaNullToNil(JSON[@"originalDownloadURL"]);
        if (URLString) {
            self.originalDownloadURL = [NSURL URLWithString:URLString];
        }
    }
    if (JSON[@"lastDownloadDidFail"]) {
        self.lastDownloadDidFail = [JSON[@"lastDownloadDidFail"] boolValue];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@/%@>",NSStringFromClass([self class]),self.UUID];
}

- (void)downloadFileFromURL:(NSURL *)URL mimeType:(NSString *)mimeType thumbnailGenerator:(PROLogoThumbnailGenerator)generator {
    if (self.lastDownloadDidFail) {
        PCOLogError(@"*** Last Download did fail...");
        return;
    }
    
    if (self.downloadTask) {
        return;
    }
    
    if (!self.session) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    self.originalDownloadURL = URL;
    self.thumbnailGenerator = generator;
    
    self.mimeType = [mimeType copy];
    
    PCOLogInfo(@"<DOWNLOAD-LOGO> %@",[URL absoluteString]);
    
    self.progress = [[NSProgress alloc] initWithParent:nil userInfo:@{@"uuid": self.UUID}];
    self.progress.kind = NSProgressKindFile;
    
    NSString *resumeData = [self fileResumeDataFilePath];
    
    NSURLRequest *request = [PCOServer signedRequestFromRequest:[NSURLRequest requestWithURL:URL]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:resumeData]) {
        self.downloadTask = [self.session downloadTaskWithResumeData:[NSData dataWithContentsOfFile:resumeData]];
        
        [[NSFileManager defaultManager] removeItemAtPath:resumeData error:nil];
    } else {
        self.downloadTask = [self.session downloadTaskWithRequest:request];
    }
    
    
    [self.downloadTask resume];
}

+ (PROLogo *)logoForUUID:(NSString *)UUID {
    if (!UUID) {
        return nil;
    }
    return [[[self allLogos] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"UUID == %@",UUID]] firstObject];
}

- (NSURL *)fileURL {
    return [NSURL fileURLWithPath:[self filePath]];
}
- (NSURL *)fileThumbnailURL {
    return [NSURL fileURLWithPath:[[[self class] logoFileAssetPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"t_%@.thumbnail",self.UUID]]];
}

- (void)generateThumbnailIfNeededCompletion:(void(^)(void))completion {
    welf();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:[[welf fileThumbnailURL] path] isDirectory:NULL]) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
            return;
        }
        
        if (![welf fileExists:NULL]) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
            return;
        }
        
        if (self.thumbnailGenerator == PROLogoThumbnailGeneratorVideo) {
            NSURL *videoURL = [welf fileURL];
            
            [PROThumbnailGenerator generateVideoThumbnailForFileAtURL:videoURL completion:^(NSURL *location, NSError *error) {
                if (!error && location) {
                    if (![[NSFileManager defaultManager] fileExistsAtPath:location.path]) {
                        if (completion) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion();
                            });
                        }
                        return;
                    }
                    NSURL *dest = [welf fileThumbnailURL];
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:dest.path]) {
                        NSError *deleteError = nil;
                        if (![[NSFileManager defaultManager] removeItemAtPath:dest.path error:&deleteError]) {
                            if (completion) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion();
                                });
                            }
                            return;
                        }
                    }
                    NSError *copyError = nil;
                    if ([[NSFileManager defaultManager] copyItemAtURL:location toURL:dest error:&copyError]) {
                        PCOError(copyError);
                    }
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion();
                        });
                    }
                }
            }];
            
            return;
        }
        
        [[NSFileManager defaultManager] copyItemAtURL:[welf fileURL] toURL:[welf fileThumbnailURL] error:nil];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}
- (void)loadThumbnailWithCompletion:(void(^)(UIImage *, NSError *))completion {
    if (self.thumbnailImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(self.thumbnailImage, nil);
            }
        });
        return;
    }
    
    NSError *existsError = nil;
    if (![self fileExists:&existsError]) {
        if (completion) {
            completion(nil, existsError);
        }
        return;
    }
    
    welf();
    
    [self generateThumbnailIfNeededCompletion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:[[welf fileThumbnailURL] path]];
            welf.thumbnailImage = image;
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image, nil);
                });
            }
        });
    }];
}

- (void)cancelDownload {
    welf();
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        if (!resumeData) {
            return;
        }
        
        NSString *filePath = [welf fileResumeDataFilePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *removeError = nil;
            if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError]) {
                PCOLogError(@"%@",removeError);
                return;
            }
        }
        
        [resumeData writeToFile:filePath atomically:YES];
    }];
}
- (BOOL)finishFileDownloadIfNeeded {
    NSError *error = nil;
    if ([self fileExists:&error]) {
        return NO;
    }
    
    if (!self.originalDownloadURL) {
        return NO;
    }
    
    [self downloadFileFromURL:self.originalDownloadURL mimeType:self.mimeType thumbnailGenerator:self.thumbnailGenerator];
    
    return YES;
}

#pragma mark -
#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    PCOLogDebug(@"Finshed download: %@",downloadTask.originalRequest.URL);
    if ([[NSFileManager defaultManager] fileExistsAtPath:[location path]]) {
        NSError *copyError = nil;
        if (![[NSFileManager defaultManager] copyItemAtPath:[location path] toPath:[self filePath] error:&copyError]) {
            PCOLogError(@"%@",copyError);
        } else {
            [self generateThumbnailIfNeededCompletion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:PROLogoThubnailGenerationCompletedNotification object:self.progress userInfo:@{@"logo": self}];
            }];
        }
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.progress.totalUnitCount = totalBytesExpectedToWrite;
    self.progress.completedUnitCount = totalBytesWritten;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PROLogoDownloadProgressUpdatedNotification object:self.progress userInfo:nil];
    });
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    NSMutableURLRequest *req = [request mutableCopy];
    
    // So... S3 doesn't like these headers so we're dropping them.
    [req setValue:nil forHTTPHeaderField:@"Content-Type"];
    [req setValue:nil forHTTPHeaderField:@"Accept"];
    
    completionHandler(req);
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    PCOError(error);
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    if ([response respondsToSelector:@selector(responseOK)] && ![response responseOK]) {
        PCOLogError(@"Failed to download resource: %@",response);
        self.lastDownloadDidFail = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PROLogoDownloadProgressCompletedNotification object:self userInfo:nil];
    });
}

@end

_PCO_EXTERN_STRING PROLogoErrorDomain = @"PROLogoErrorDomain";
_PCO_EXTERN_STRING PROLogoDownloadProgressUpdatedNotification = @"PROLogoDownloadProgressUpdatedNotification";
_PCO_EXTERN_STRING PROLogoDownloadProgressCompletedNotification = @"PROLogoDownloadProgressCompletedNotification";
_PCO_EXTERN_STRING PROLogoThubnailGenerationCompletedNotification = @"PROLogoThubnailGenerationCompletedNotification";
