/*!
 * ColorPickerHexTextField.m
 *
 *
 * Created by Skylar Schipper on 5/21/14
 */

#import "ColorPickerHexTextField.h"

@interface ColorPickerHexTextField ()

@end

@implementation ColorPickerHexTextField

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.textInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    
    self.font = [UIFont defaultFontOfSize_16];
    self.textAlignment = NSTextAlignmentRight;
    self.textColor = [UIColor layoutEditorSidebarColorPickerHexTextEntryTextColor];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    self.backgroundColor = newSuperview.backgroundColor;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor layoutEditorSidebarColorPickerHexTextEntryBackgroundColor] setFill];
    [[UIColor layoutEditorSidebarColorPickerHexTextEntryStrokeColor] setStroke];
    
    CGRect frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0.5, 8.5, 0.5, 0.5));
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    path.lineWidth = 1.0;
    
    [path fill];
    [path stroke];
    
    CGFloat arrowHalf = 6.0;
    
    UIBezierPath *arrow = [UIBezierPath bezierPath];
    [arrow moveToPoint:CGPointMake(CGRectGetMinX(frame), PCOKitRectGetHalfHeight(frame) - arrowHalf)];
    [arrow addLineToPoint:CGPointMake(CGRectGetMinX(frame), PCOKitRectGetHalfHeight(frame) + arrowHalf)];
    [arrow addLineToPoint:CGPointMake(0.0, PCOKitRectGetHalfHeight(frame))];
    [arrow closePath];
    
    [[UIColor layoutEditorSidebarColorPickerHexTextEntryStrokeColor] setFill];
    [arrow fill];
}

@end
