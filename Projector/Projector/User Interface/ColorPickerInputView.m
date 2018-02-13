/*!
 * ColorPickerInputView.m
 *
 *
 * Created by Skylar Schipper on 5/20/14
 */

#import "ColorPickerInputView.h"

@interface ColorPickerInputView ()

@end

@implementation ColorPickerInputView

- (void)initializeDefaults {
    [super initializeDefaults];
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    
    [[UIColor projectorBlackColor] setStroke];
    
    CGFloat inset = 0.5;
    CGSize radii = CGSizeMake(PCOKitRectGetHalfWidth(self.bounds), PCOKitRectGetHalfHeight(self.bounds));
    
    UIBezierPath *outer = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(inset, inset, inset, inset)) byRoundingCorners:UIRectCornerAllCorners cornerRadii:radii];
    outer.lineWidth = 1.0;
    [outer stroke];
    
    [[UIColor whiteColor] setStroke];
    
    inset += 1.5;
    UIBezierPath *innter = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(inset, inset, inset, inset)) byRoundingCorners:UIRectCornerAllCorners cornerRadii:radii];
    innter.lineWidth = 2.0;
    [innter stroke];
}

- (void)moveToPoint:(CGPoint)point {
    self.center = point;
}

@end
