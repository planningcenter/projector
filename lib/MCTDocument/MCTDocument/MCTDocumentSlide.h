/*!
 * MCTDocumentSlide.h
 *
 * Created by Skylar Schipper on 3/28/14
 */

#ifndef MCTDocumentSlide_h
#define MCTDocumentSlide_h

@import Foundation;
@import UIKit;

@interface MCTDocumentSlide : NSObject

- (instancetype)initWithBasePath:(NSString *)basePath slidePath:(NSString *)slidePath index:(NSInteger)index;

- (NSString *)HTML;

+ (NSString *)slidePathForFormat:(NSString *)format index:(NSInteger)index;

- (void)loadWebView:(UIWebView *)webView;

@end

#endif
