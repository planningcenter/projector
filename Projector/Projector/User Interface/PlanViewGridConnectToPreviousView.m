/*!
 * PlanViewGridConnectToPreviousView.m
 *
 *
 * Created by Skylar Schipper on 5/6/14
 */

#import "PlanViewGridConnectToPreviousView.h"

@interface PlanViewGridConnectToPreviousView ()

@end

@implementation PlanViewGridConnectToPreviousView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.backgroundColor = newSuperview.backgroundColor;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor blackColor] setFill];
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGFloat leftEdge = PCOKitRectGetHalfWidth(self.bounds) - 2.0;
    CGFloat rightEdge = PCOKitRectGetHalfWidth(self.bounds) + 2.0;
    CGFloat arrowHeight = 6.0;
    
    [path moveToPoint:CGPointMake(leftEdge, 0.0)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), 0.0)];
    [path addLineToPoint:CGPointMake(rightEdge, arrowHeight)];
    [path addLineToPoint:CGPointMake(rightEdge, CGRectGetHeight(self.bounds))];
    [path addLineToPoint:CGPointMake(0.0, CGRectGetHeight(self.bounds))];
    [path addLineToPoint:CGPointMake(leftEdge, CGRectGetHeight(self.bounds) - arrowHeight)];
    
    [path closePath];
    [path fill];
}

@end
