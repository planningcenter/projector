/*!
 * PRONavigationController.h
 *
 *
 * Created by Skylar Schipper on 3/12/14
 */

#ifndef PRONavigationController_h
#define PRONavigationController_h

#import "PCONavigationController.h"

typedef NS_ENUM(NSInteger, PRONavigationControllerBarStyle) {
    PRONavigationControllerBarDefaultStyle = 0
};

@interface PRONavigationController : PCONavigationController

@property (nonatomic) PRONavigationControllerBarStyle barStyle;

+ (UIColor *)barTintColorForStyle:(PRONavigationControllerBarStyle)style;
+ (UIColor *)tintColorForStyle:(PRONavigationControllerBarStyle)style;
+ (UIColor *)barTextColorForStyle:(PRONavigationControllerBarStyle)style;

- (void)updateCurrentBarStyle;

@end

#endif
