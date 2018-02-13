/*!
 * PROScreenPositionPicker.m
 *
 *
 * Created by Skylar Schipper on 4/15/14
 */

#import "PROScreenPositionPicker.h"
#import "PCOKeyValueStore.h"

static NSUInteger const PROScreenPositionPickerColumnCount = 3;
static NSUInteger const PROScreenPositionPickerRowCount = 3;

static NSString *const kProjectorLastScreenPosition = @"com.projector.AlertLocation";

@interface PROScreenPositionPicker ()

@property (nonatomic, weak) UITapGestureRecognizer *tapGesture;

@end

@implementation PROScreenPositionPicker

- (void)initializeDefaults {
    [super initializeDefaults];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    self.tapGesture = tap;
    [self addGestureRecognizer:tap];
    
    [self setPosition:[[self class] screenPosition] callTargets:NO];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    [super setStrokeColor:strokeColor];
    [self setNeedsDisplay];
}

- (CGRect)rectForCurrentPosition {
    return [[self class] rectForPosition:self.position boundingSize:self.bounds.size];
}
+ (CGRect)rectForPosition:(PROScreenPosition)position boundingSize:(CGSize)bounding {
    CGSize size = CGSizeMake(bounding.width / PROScreenPositionPickerColumnCount, bounding.height / PROScreenPositionPickerRowCount);
    
    CGPoint origin = CGPointZero;
    switch (position) {
        case PROScreenTopMiddlePosition:
            origin.x = size.width;
            break;
        case PROScreenTopRightPosition:
            origin.x = size.width * 2;
            break;
        case PROScreenMiddleLeftPosition:
            origin.y = size.height;
            break;
        case PROScreenMiddleMiddlePosition:
            origin.y = size.height;
            origin.x = size.width;
            break;
        case PROScreenMiddleRightPosition:
            origin.y = size.height;
            origin.x = size.width * 2;
            break;
        case PROScreenBottomLeftPosition:
            origin.y = size.height * 2;
            break;
        case PROScreenBottomMiddlePosition:
            origin.y = size.height * 2;
            origin.x = size.width;
            break;
        case PROScreenBottomRightPosition:
            origin.y = size.height * 2;
            origin.x = size.width * 2;
            break;
        default:
            break;
    }
    
    CGRect rect = (CGRect){origin, size};
    return CGRectIntegral(rect);
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    PROScreenPosition pos = [self positionForPoint:[tap locationInView:self]];
    self.position = pos;
}

- (PROScreenPosition)positionForPoint:(CGPoint)point {
    CGSize size = self.bounds.size;
    
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenTopLeftPosition boundingSize:size], point)) {
        return PROScreenTopLeftPosition;
    }
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenTopMiddlePosition boundingSize:size], point)) {
        return PROScreenTopMiddlePosition;
    }
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenTopRightPosition boundingSize:size], point)) {
        return PROScreenTopRightPosition;
    }
    
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenMiddleLeftPosition boundingSize:size], point)) {
        return PROScreenMiddleLeftPosition;
    }
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenMiddleMiddlePosition boundingSize:size], point)) {
        return PROScreenMiddleMiddlePosition;
    }
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenMiddleRightPosition boundingSize:size], point)) {
        return PROScreenMiddleRightPosition;
    }
    
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenBottomLeftPosition boundingSize:size], point)) {
        return PROScreenBottomLeftPosition;
    }
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenBottomMiddlePosition boundingSize:size], point)) {
        return PROScreenBottomMiddlePosition;
    }
    if (CGRectContainsPoint([[self class] rectForPosition:PROScreenBottomRightPosition boundingSize:size], point)) {
        return PROScreenBottomRightPosition;
    }
    
    return PROScreenBottomLeftPosition;
}

#pragma mark -
#pragma mark - Drawing
- (void)drawRect:(CGRect)rect {
    CGRect selectedRect = [self rectForCurrentPosition];
    
    CGFloat colWidth = CGRectGetWidth(self.bounds) / PROScreenPositionPickerColumnCount;
    CGFloat rowHeight = CGRectGetHeight(self.bounds) / PROScreenPositionPickerRowCount;
    
    [self.strokeColor setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(colWidth - 1.0, 0.0, 1.0, CGRectGetHeight(self.bounds))] fill];
    [[UIBezierPath bezierPathWithRect:CGRectMake((colWidth * 2.0) - 1.0, 0.0, 1.0, CGRectGetHeight(self.bounds))] fill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0.0, rowHeight - 1.0, CGRectGetWidth(self.bounds), 1.0)] fill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0.0, (rowHeight * 2.0) - 1.0, CGRectGetWidth(self.bounds), 1.0)] fill];
    
    [self.selectedStrokeColor setStroke];
    [self.selectedColor setFill];
    
    UIRectCorner roundCorner = 0;
    if (self.position == PROScreenTopLeftPosition) {
        roundCorner = UIRectCornerTopLeft;
    }
    if (self.position == PROScreenBottomLeftPosition) {
        roundCorner = UIRectCornerBottomLeft;
    }
    if (self.position == PROScreenTopRightPosition) {
        roundCorner = UIRectCornerTopRight;
    }
    if (self.position == PROScreenBottomRightPosition) {
        roundCorner = UIRectCornerBottomRight;
    }
    
    UIBezierPath *selectedPath = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(selectedRect, UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0)) byRoundingCorners:roundCorner cornerRadii:CGSizeMake(8.0, 8.0)];
    selectedPath.lineWidth = 2.0;
    [selectedPath fill];
    [selectedPath stroke];
    
    UIImage *image = [UIImage imageNamed:@"lr_white_check_mark"];
    CGSize imageSize = image.size;
    CGPoint imageOrigin = selectedRect.origin;
    imageOrigin.x += PCOKitRectGetHalfWidth(selectedRect);
    imageOrigin.y += PCOKitRectGetHalfHeight(selectedRect);
    imageOrigin.x -= imageSize.width / 2.0;
    imageOrigin.y -= imageSize.height / 2.0;
    CGRect imageRect = (CGRect){imageOrigin, imageSize};
    [image drawInRect:CGRectIntegral(imageRect)];
}

#pragma mark -
#pragma mark - Position
- (void)setPosition:(PROScreenPosition)position {
    [self setPosition:position callTargets:YES];
}
- (void)setPosition:(PROScreenPosition)position callTargets:(BOOL)callTargets {
    _position = position;
    [[self class] setScreenPosition:position];
    [self setNeedsDisplay];
    if (callTargets) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark -
#pragma mark - Position Selection
+ (PROScreenPosition)screenPosition {
    NSNumber *obj = [[PCOKeyValueStore defaultStore] objectForKey:kProjectorLastScreenPosition];
    if (!obj) {
        return PROScreenBottomLeftPosition;
    }
    return [obj integerValue];
}
+ (void)setScreenPosition:(PROScreenPosition)position {
    [[PCOKeyValueStore defaultStore] setObject:@(position) forKey:kProjectorLastScreenPosition];
    [PCOEventLogger logEvent:[NSString stringWithFormat:@"Nursery Alert Settings - Position %td", position]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PROScreenPositionPickerDidPickPosition object:nil userInfo:nil];
    });
}

@end

_PCO_EXTERN_STRING PROScreenPositionPickerDidPickPosition = @"PROScreenPositionPickerDidPickPosition";
