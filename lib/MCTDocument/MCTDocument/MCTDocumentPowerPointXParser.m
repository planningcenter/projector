/*!
 * MCTDocumentPowerPointXParser.m
 *
 * Created by Skylar Schipper on 3/27/14
 */

#import "MCTDocumentPowerPointXParser.h"
#import "MCTDocumentParserHelper.h"

@interface MCTDocumentPowerPointXParser ()

@property (nonatomic, strong) NSString *path;

@property (nonatomic, strong) NSString *parsedHTML;
@property (nonatomic, strong) NSArray *slides;

@property (nonatomic, strong) NSMutableDictionary *info;

@end

@implementation MCTDocumentPowerPointXParser

- (void)parseHTML:(NSString *)HTML javascriptResults:(NSDictionary *)javascriptResults {
    NSString *dataPath = [self.path stringByAppendingPathComponent:@"data"];
    self.info[@"data"] = @"data";

    NSDictionary *fileMap = [self moveFilesIntoPath:dataPath HTML:HTML];
    NSString *style = [self getStyles:HTML];
    NSString *openBody = [self openBodyTag:HTML];

    for (NSString *key in [fileMap allKeys]) {
        HTML = [HTML stringByReplacingOccurrencesOfString:key withString:[[NSURL fileURLWithPath:fileMap[key]] absoluteString]];
    }

    NSArray *slides = [NSJSONSerialization JSONObjectWithData:[javascriptResults[@"slides"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    self.slides = [self generateSlides:slides map:fileMap bodyTag:openBody style:style];

    if (javascriptResults[kMCTDocumentSlideCount]) {
        static NSNumberFormatter *numberFormatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            numberFormatter = [[NSNumberFormatter alloc] init];
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        });
        self.info[kMCTDocumentSlideCount] = [numberFormatter numberFromString:javascriptResults[kMCTDocumentSlideCount]];
    }

    self.parsedHTML = HTML;
}

- (NSString *)textEncoding {
    return @"utf-8";
}

- (void)setTargetPath:(NSString *)targetPath {
    self.path = targetPath;
}
- (NSDictionary *)infoDictionary {
    return [self.info copy];
}
- (NSMutableDictionary *)info {
    if (!_info) {
        _info = [NSMutableDictionary dictionary];
    }
    return _info;
}

- (BOOL)writeToTargetPath:(NSError **)error {
    NSString *parsedHTMLName = @"parsed.html";
    self.info[@"parsed"] = parsedHTMLName;
    if (![self.parsedHTML writeToFile:[self.path stringByAppendingPathComponent:parsedHTMLName] atomically:YES encoding:NSUTF8StringEncoding error:error]) {
        return NO;
    }

    NSString *slides = @"slides";
    self.info[kMCTDocumentSlidePath] = @"slides/<index>.html";

    NSString *slidePath = [self.path stringByAppendingPathComponent:slides];
    if (![[NSFileManager defaultManager] fileExistsAtPath:slidePath]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:slidePath withIntermediateDirectories:YES attributes:nil error:error]) {
            return NO;
        }
    }

    NSUInteger index = 0;
    for (NSString *slide in self.slides) {
        NSString *path = [slidePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%tu.html",index]];
        if (![slide writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:error]) {
            return NO;
        }
        index++;
    }

    return YES;
}
- (NSDictionary *)webViewJavaScript {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    dict[kMCTDocumentSlideCount] = @"document.getElementsByClassName('slide').length";
    dict[@"slides"] = @"var divs = document.getElementsByClassName('slide'); var strings = []; for (var i = 0; i < divs.length; i++) { var div = divs[i]; strings.push(div.outerHTML); } JSON.stringify(strings);";

    return dict;
}

- (NSInteger)count {
    return self.slides.count;
}


#pragma mark -
#pragma mark - Parse helpers
- (NSDictionary *)moveFilesIntoPath:(NSString *)path HTML:(NSString *)HTML {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"\"x-apple-ql-id://(\\S+)\"" options:0 error:&error];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:50];
    [regex enumerateMatchesInString:HTML options:0 range:NSMakeRange(0, HTML.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        @autoreleasepool {
            NSString *url = [HTML substringWithRange:result.range];
            url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSString *key = [url copy];
            NSURL *URL = [NSURL URLWithString:url];
            NSData *data = [NSData dataWithContentsOfURL:URL];
            if (!data) {
                return;
            }
            NSURLComponents *components = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
            NSString *filePath = [path stringByAppendingPathComponent:[components.path lastPathComponent]];
            dictionary[key] = filePath;
            [data writeToFile:filePath atomically:YES];
        }
    }];

    return [dictionary copy];
}
- (NSString *)getStyles:(NSString *)HTML {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"<style(.*?)</style>" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionDotMatchesLineSeparators error:&error];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });

    NSMutableString *style = [NSMutableString string];
    [regex enumerateMatchesInString:HTML options:0 range:NSMakeRange(0, HTML.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [style appendString:[HTML substringWithRange:result.range]];
    }];
    [style replaceOccurrencesOfString:@"<style type=\"text/css\">" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, style.length)];
    [style replaceOccurrencesOfString:@"</style>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, style.length)];
    [style replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, style.length)];
    [style replaceOccurrencesOfString:@"\r" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, style.length)];
    [style replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, style.length)];

    NSString *fixed = [MCTDocumentParserHelper fixWidth:style];
    fixed = [MCTDocumentParserHelper fixHeight:fixed];
    fixed = [MCTDocumentParserHelper fixSize:fixed];

    return fixed;
}
- (NSString *)openBodyTag:(NSString *)HTML {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"<body(.*?)>" options:0 error:&error];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });

    NSString __block *tag = nil;
    [regex enumerateMatchesInString:HTML options:0 range:NSMakeRange(0, HTML.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        tag = [HTML substringWithRange:result.range];
        *stop = YES;
    }];
    if (tag.length == 0) {
        tag = @"<body>";
    }
    return tag;
}
- (NSArray *)generateSlides:(NSArray *)slides map:(NSDictionary *)map bodyTag:(NSString *)bodyTag style:(NSString *)style {
    NSMutableArray *parsedSlides = [NSMutableArray arrayWithCapacity:slides.count];
    for (NSString *slide in slides) {
        NSString *parsedSlide = [slide copy];
        for (NSString *key in [map allKeys]) {
            parsedSlide = [parsedSlide stringByReplacingOccurrencesOfString:key withString:[[NSURL fileURLWithPath:map[key]] absoluteString]];
        }
        parsedSlide = [MCTDocumentParserHelper fixTopOffset:parsedSlide];
        parsedSlide = [MCTDocumentParserHelper fixWidth:parsedSlide];
        parsedSlide = [MCTDocumentParserHelper fixHeight:parsedSlide];
        parsedSlide = [MCTDocumentParserHelper fixTop:parsedSlide];
        parsedSlide = [MCTDocumentParserHelper fixLeft:parsedSlide];
        [parsedSlides addObject:[NSString stringWithFormat:@"<head><style type=\"text/css\">%@</style></head>\n%@%@</body>",style,bodyTag,parsedSlide]];
    }
    return [parsedSlides copy];
}

@end
