/*!
 * PROLogoLoadingView.h
 *
 *
 * Created by Skylar Schipper on 5/9/14
 */

#ifndef PROLogoLoadingView_h
#define PROLogoLoadingView_h

#import "PCOView.h"

@interface PROLogoLoadingView : PCOView

@property (nonatomic) CGFloat sizeIndex;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end

#endif
