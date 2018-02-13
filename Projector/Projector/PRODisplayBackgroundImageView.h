/*!
 * PRODisplayBackgroundImageView.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 10/20/14
 */

#ifndef Projector_PRODisplayBackgroundImageView_h
#define Projector_PRODisplayBackgroundImageView_h

@import UIKit;

#import "PRODisplayView.h"

@interface PRODisplayBackgroundImageView : UIImageView

- (void)setImage:(UIImage *)image animation:(PRODisplayViewSlideAnimation)animation;

@end

#endif
