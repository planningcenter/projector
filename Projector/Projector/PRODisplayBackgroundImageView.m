/*!
 * PRODisplayBackgroundImageView.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 10/20/14
 */

#import "PRODisplayBackgroundImageView.h"

@interface PRODisplayBackgroundImageView ()

@end

@implementation PRODisplayBackgroundImageView

- (void)setImage:(UIImage *)image animation:(PRODisplayViewSlideAnimation)animation {
    
    self.image = image;
    
//    if (animation == PRODisplayViewAnimateCrossFade) {
//        if (!self.image) {
//            CGFloat alpha = self.alpha;
//            self.image = image;
//            self.alpha = 0.0;
//            [UIView animateWithDuration:1.0 animations:^{
//                self.alpha = alpha;
//            }];
//        } else {
//            [UIView transitionWithView:self duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//                self.image = image;
//            } completion:^(BOOL finished) {
//                
//            }];
//        }
//    } else {
//        self.image = image;
//    }
}

@end
