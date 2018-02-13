/*!
 * PROSidebarBlurVendor.m
 *
 *
 * Created by Skylar Schipper on 3/18/14
 */

#import "PROSidebarBlurVendor.h"
#import "UIImage+PCOAdditions.h"

@interface PROSidebarBlurVendor ()

@end

@implementation PROSidebarBlurVendor

- (BOOL)shouldPerformBlur {
#if __LP64__
    return YES;
#endif
    return NO;
}
- (UIImage *)blurImage:(UIImage *)image {
    return [image pco_bluredImageWithRadius:10.0 tintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6] error:nil];
}

@end
