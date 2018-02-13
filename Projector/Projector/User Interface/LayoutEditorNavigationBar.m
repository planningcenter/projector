/*!
 * LayoutEditorNavigationBar.m
 *
 *
 * Created by Skylar Schipper on 6/25/14
 */

#import "LayoutEditorNavigationBar.h"

@interface LayoutEditorNavigationBar ()

@end

@implementation LayoutEditorNavigationBar

- (void)drawRect:(CGRect)rect {
    [[UIColor projectorBlackColor] setFill];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    [[UIColor projectorOrangeColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0.0, CGRectGetHeight(self.bounds) - 1.0, CGRectGetWidth(self.bounds), 1.0)] fill];
}

@end
