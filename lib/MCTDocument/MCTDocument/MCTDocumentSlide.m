/*!
 * MCTDocumentSlide.m
 *
 * Created by Skylar Schipper on 3/28/14
 */

#import "MCTDocumentSlide.h"

@interface MCTDocumentSlide ()

@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *slidePath;

@property (nonatomic, strong) NSString *htmlContent;

@end

@implementation MCTDocumentSlide

- (instancetype)initWithBasePath:(NSString *)basePath slidePath:(NSString *)slidePath index:(NSInteger)index {
    self = [super init];
    if (self) {
        self.path = basePath;
        self.index = index;
        self.slidePath = slidePath;
    }
    return self;
}

- (NSString *)HTML {
    return self.htmlContent;
}
- (NSString *)htmlContent {
    if (!_htmlContent) {
        _htmlContent = [NSString stringWithContentsOfFile:[self formatPath] encoding:NSUTF8StringEncoding error:nil];
    }
    return _htmlContent;
}

- (NSString *)formatPath {
    NSString *slide = [[self class] slidePathForFormat:self.slidePath index:self.index];
    return [self.path stringByAppendingPathComponent:slide];
}
+ (NSString *)slidePathForFormat:(NSString *)format index:(NSInteger)index {
    return [format stringByReplacingOccurrencesOfString:@"<index>" withString:[NSString stringWithFormat:@"%zd",index]];
}

- (void)loadWebView:(UIWebView *)webView {
    webView.scalesPageToFit = YES;
    if (self.htmlContent) {
        [webView loadHTMLString:self.htmlContent baseURL:nil];
    }
}

#pragma mark -
#pragma mark - Debug
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p index: %zd>",NSStringFromClass([self class]),self,self.index];
}

@end
