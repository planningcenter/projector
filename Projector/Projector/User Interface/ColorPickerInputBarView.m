/*!
 * ColorPickerInputBarView.m
 *
 *
 * Created by Skylar Schipper on 5/20/14
 */

#import "ColorPickerInputBarView.h"

@interface ColorPickerInputBarView ()

@end

@implementation ColorPickerInputBarView

- (void)moveToPoint:(CGPoint)point {
    self.center = CGPointMake(point.x, PCOKitRectGetHalfHeight(self.superview.bounds));
}

@end
