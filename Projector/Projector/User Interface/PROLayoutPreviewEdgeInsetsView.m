/*!
 * PROLayoutPreviewEdgeInsetsView.m
 *
 *
 * Created by Skylar Schipper on 6/18/14
 */

#import "PROLayoutPreviewEdgeInsetsView.h"

typedef NS_ENUM(NSUInteger, PROLayoutPreviewEdgeInsetsHandle) {
    PROLayoutPreviewEdgeInsetsHandleTopLeft      = 0,
    PROLayoutPreviewEdgeInsetsHandleTopMiddle    = 1,
    PROLayoutPreviewEdgeInsetsHandleTopRight     = 2,
    PROLayoutPreviewEdgeInsetsHandleMiddleLeft   = 3,
    PROLayoutPreviewEdgeInsetsHandleMiddleRight  = 4,
    PROLayoutPreviewEdgeInsetsHandleBottomLeft   = 5,
    PROLayoutPreviewEdgeInsetsHandleBottomMiddle = 6,
    PROLayoutPreviewEdgeInsetsHandleBottomRight  = 7,
    PROLayoutPreviewEdgeInsetsHandleNone         = NSNotFound
};

@interface PROLayoutPreviewEdgeInsetsView ()

@property (nonatomic) PROLayoutPreviewEdgeInsetsHandle currentHandle;
@property (nonatomic) CGPoint translationPoint;

@end

@implementation PROLayoutPreviewEdgeInsetsView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.color = [UIColor whiteColor];
    
    self.currentHandle = PROLayoutPreviewEdgeInsetsHandleNone;
    
    self.layer.needsDisplayOnBoundsChange = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureForInsetResize:)];
    longPress.minimumPressDuration = 0.001;
    [self addGestureRecognizer:longPress];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self.color set];
    
    CGRect insetFrame = UIEdgeInsetsInsetRect(self.bounds, self.insets);
    insetFrame = CGRectIntegral(insetFrame);
    
    CGFloat lineWidth = 2.0;
    
    // Outer Path
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:insetFrame];
    path.lineWidth = lineWidth;
    [path stroke];
    
    // Handles
    CGFloat pillHeight = 18.0;
    CGFloat cornerRadius = PCOKitHalf(pillHeight);
    CGRect pillFrame = CGRectMake(0.0, 0.0, pillHeight, pillHeight);
    
    pillFrame.origin = insetFrame.origin;
    pillFrame.origin.x -= cornerRadius;
    pillFrame.origin.y -= cornerRadius;
    
    // Top Left
    UIBezierPath *topLeft = [UIBezierPath bezierPathWithRoundedRect:pillFrame cornerRadius:cornerRadius];
    topLeft.lineWidth = lineWidth;
    [topLeft stroke];
    [topLeft fill];
    
    // Top Right
    pillFrame.origin.x = CGRectGetMaxX(insetFrame) - PCOKitRectGetHalfWidth(pillFrame);
    UIBezierPath *topRight = [UIBezierPath bezierPathWithRoundedRect:pillFrame cornerRadius:cornerRadius];
    topRight.lineWidth = lineWidth;
    [topRight stroke];
    [topRight fill];
    
    // Bottom Right
    pillFrame.origin.y = CGRectGetMaxY(insetFrame) - PCOKitRectGetHalfHeight(pillFrame);
    UIBezierPath *bottomRight = [UIBezierPath bezierPathWithRoundedRect:pillFrame cornerRadius:cornerRadius];
    bottomRight.lineWidth = lineWidth;
    [bottomRight stroke];
    [bottomRight fill];
    
    // Bottom Left
    pillFrame.origin.x = insetFrame.origin.x - cornerRadius;
    UIBezierPath *bottomLeft = [UIBezierPath bezierPathWithRoundedRect:pillFrame cornerRadius:cornerRadius];
    bottomLeft.lineWidth = lineWidth;
    [bottomLeft stroke];
    [bottomLeft fill];
    
    [[UIColor projectorOrangeColor] setFill];
    
    switch (self.currentHandle) {
        case PROLayoutPreviewEdgeInsetsHandleTopLeft:
            [topLeft fill];
            break;
        case PROLayoutPreviewEdgeInsetsHandleTopMiddle:
            break;
        case PROLayoutPreviewEdgeInsetsHandleTopRight:
            [topRight fill];
            break;
        case PROLayoutPreviewEdgeInsetsHandleMiddleLeft:
            break;
        case PROLayoutPreviewEdgeInsetsHandleMiddleRight:
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomLeft:
            [bottomLeft fill];
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomMiddle:
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomRight:
            [bottomRight fill];
            break;
        default:
            break;
    }
}

- (void)handleGestureForInsetResize:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self handleInsetResizeStart:longPress];
    } else if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled) {
        [self handleInsetResizeEnd:longPress];
    } else if (longPress.state == UIGestureRecognizerStateChanged) {
        [self handleInsetResizeChange:longPress];
    }
    [self setNeedsDisplay];
}
- (void)handleInsetResizeStart:(UILongPressGestureRecognizer *)longPress {
    self.translationPoint = [longPress locationInView:self];
    self.currentHandle = [self closestHandleForPoint:[longPress locationInView:self]];
}
- (void)handleInsetResizeEnd:(UILongPressGestureRecognizer *)longPress {
    self.translationPoint = CGPointZero;
    self.currentHandle = PROLayoutPreviewEdgeInsetsHandleNone;
    [self.delegate insetView:self didChangeInsets:self.insets];
}
- (void)handleInsetResizeChange:(UILongPressGestureRecognizer *)longPress {
    CGPoint location = [longPress locationInView:self];
    CGPoint offset = PCOCGPointBySubtractingPoint(location, self.translationPoint);
    self.translationPoint = location;
    
    UIEdgeInsets insets = self.insets;
    
    switch (self.currentHandle) {
        case PROLayoutPreviewEdgeInsetsHandleTopLeft:
            insets.left += offset.x;
            insets.top += offset.y;
            break;
        case PROLayoutPreviewEdgeInsetsHandleTopMiddle:
            insets.top += offset.y;
            break;
        case PROLayoutPreviewEdgeInsetsHandleTopRight:
            insets.right -= offset.x;
            insets.top += offset.y;
            break;
        case PROLayoutPreviewEdgeInsetsHandleMiddleLeft:
            insets.left += offset.x;
            break;
        case PROLayoutPreviewEdgeInsetsHandleMiddleRight:
            insets.right += offset.x;
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomLeft:
            insets.bottom -= offset.y;
            insets.left += offset.x;
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomMiddle:
            insets.bottom -= offset.y;
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomRight:
            insets.bottom -= offset.y;
            insets.right -= offset.x;
            break;
        default:
            break;
    }
    
    self.insets = insets;
}

- (PROLayoutPreviewEdgeInsetsHandle)closestHandleForPoint:(CGPoint)point {
    NSArray *distances = @[
                           @(PCOKitDistanceForPoints([self locationOfHandle:PROLayoutPreviewEdgeInsetsHandleTopLeft], point)),
                           @(PCOKitDistanceForPoints([self locationOfHandle:PROLayoutPreviewEdgeInsetsHandleTopMiddle], point)),
                           @(PCOKitDistanceForPoints([self locationOfHandle:PROLayoutPreviewEdgeInsetsHandleTopRight], point)),
                           @(PCOKitDistanceForPoints([self locationOfHandle:PROLayoutPreviewEdgeInsetsHandleMiddleLeft], point)),
                           @(PCOKitDistanceForPoints([self locationOfHandle:PROLayoutPreviewEdgeInsetsHandleMiddleRight], point)),
                           @(PCOKitDistanceForPoints([self locationOfHandle:PROLayoutPreviewEdgeInsetsHandleBottomLeft], point)),
                           @(PCOKitDistanceForPoints([self locationOfHandle:PROLayoutPreviewEdgeInsetsHandleBottomMiddle], point)),
                           @(PCOKitDistanceForPoints([self locationOfHandle:PROLayoutPreviewEdgeInsetsHandleBottomRight], point))
                           ];
    
    NSNumber *max = [distances valueForKeyPath:@"@min.doubleValue"];
    
    NSUInteger index = [distances indexOfObject:max];
    if (index == NSNotFound) {
        return 0;
    }
    return index;
}
- (CGPoint)locationOfHandle:(PROLayoutPreviewEdgeInsetsHandle)handle {
    switch (handle) {
        case PROLayoutPreviewEdgeInsetsHandleTopLeft:
            return CGPointMake(self.insets.left, self.insets.top);
            break;
        case PROLayoutPreviewEdgeInsetsHandleTopMiddle:
            return CGPointMake(MAXFLOAT, MAXFLOAT);
            break;
        case PROLayoutPreviewEdgeInsetsHandleTopRight:
            return CGPointMake(CGRectGetWidth(self.bounds) - self.insets.right, self.insets.top);
            break;
        case PROLayoutPreviewEdgeInsetsHandleMiddleLeft:
            return CGPointMake(MAXFLOAT, MAXFLOAT);
            break;
        case PROLayoutPreviewEdgeInsetsHandleMiddleRight:
            return CGPointMake(MAXFLOAT, MAXFLOAT);
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomLeft:
            return CGPointMake(self.insets.left, CGRectGetHeight(self.bounds) - self.insets.bottom);
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomMiddle:
            return CGPointMake(MAXFLOAT, MAXFLOAT);
            break;
        case PROLayoutPreviewEdgeInsetsHandleBottomRight:
            return CGPointMake(CGRectGetWidth(self.bounds) - self.insets.right, CGRectGetHeight(self.bounds) - self.insets.bottom);
            break;
        default:
            break;
    }
    return CGPointZero;
}

@end
