//
//  LESLyricsEditorTextShadowOffsetCell.m
//  Projector
//
//  Created by Skylar Schipper on 6/23/14.
//

#import "LESLyricsEditorTextShadowOffsetCell.h"
#import "ColorPickerInputView.h"

static uint8_t _LESLyricsEditorTextShadowOffsetCellViewLineCount = 11;

@interface _LESLyricsEditorTextShadowOffsetCellView : PCOView

@property (nonatomic) CGSize currentOffset;
@property (nonatomic, weak) ColorPickerInputView *inputView;

@property (nonatomic, copy) void(^sizePickedHandler)(CGSize);

@property (nonatomic, weak) UIImageView *centerView;

@end

@interface LESLyricsEditorTextShadowOffsetCell ()

@property (nonatomic, weak) _LESLyricsEditorTextShadowOffsetCellView *offsetView;

@end

@implementation LESLyricsEditorTextShadowOffsetCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _LESLyricsEditorTextShadowOffsetCellView *view = [_LESLyricsEditorTextShadowOffsetCellView newAutoLayoutView];
    view.backgroundColor = self.backgroundColor;
    view.currentOffset = CGSizeMake(1.0, 1.0);
    
    self.offsetView = view;
    [self.contentView addSubview:view];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (![[PROAppDelegate delegate] isPad]) {
        insets = UIEdgeInsetsMake(0, 0, 0, 60);
    }
    [self.contentView addConstraints:[NSLayoutConstraint insetViewInSuperview:view insets:insets]];
}

- (void)setSizePickerHandler:(void (^)(CGSize))sizePickerHandler {
    self.offsetView.sizePickedHandler = sizePickerHandler;
}
- (void (^)(CGSize))sizePickerHandler {
    return self.offsetView.sizePickedHandler;
}


- (void)setSize:(CGSize)size {
    self.offsetView.currentOffset = size;
}
- (CGSize)size {
    return self.offsetView.currentOffset;
}

@end


@implementation _LESLyricsEditorTextShadowOffsetCellView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    ColorPickerInputView *view = [[ColorPickerInputView alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 24.0)];
    self.inputView = view;
    [self addSubview:view];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerDidRecognizeAction:)];
    longPress.minimumPressDuration = 0.01;
    [self addGestureRecognizer:longPress];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage templateImageNamed:@"light-source-icon"]];
    imageView.tintColor = [UIColor projectorOrangeColor];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:imageView];
    self.centerView = imageView;
    
    NSArray *constraints = [NSLayoutConstraint center:imageView inView:self];
    NSLayoutConstraint *constraint = [constraints lastObject];
    constraint.constant = -1.0;
    [self addConstraints:constraints];
    
    [self bringSubviewToFront:self.inputView];
}

- (void)setCurrentOffset:(CGSize)currentOffset {
    _currentOffset = currentOffset;
    
    [self.inputView moveToPoint:[self centerPointForCurrentOffset]];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self.inputView moveToPoint:[self centerPointForCurrentOffset]];
}

- (CGPoint)centerPointForCurrentOffset {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat horizontalOffset = width / _LESLyricsEditorTextShadowOffsetCellViewLineCount;
    CGFloat verticalOffset = height / _LESLyricsEditorTextShadowOffsetCellViewLineCount;
    
    CGPoint point = CGPointMake((self.currentOffset.width * horizontalOffset) + PCOKitHalf(width), (self.currentOffset.height * verticalOffset) + PCOKitHalf(height));
    
    return [self bestPointForPoint:point];
}

- (CGPoint)bestPointForPoint:(CGPoint)point {
    NSArray *points = [self intersectionPoints];
    NSValue *closest = [NSValue valueWithCGPoint:self.center];
    for (NSValue *currentPoint in points) {
        CGFloat currentDistance = PCOKitDistanceForPoints([currentPoint CGPointValue], point);
        CGFloat closestDistance = PCOKitDistanceForPoints([closest CGPointValue], point);
        
        if (currentDistance < closestDistance) {
            closest = currentPoint;
        }
    }
    
    return [closest CGPointValue];
}

- (CGSize)offsetForPoint:(CGPoint)point {
    CGSize offset = CGSizeZero;
    NSArray *points = [self intersectionPoints];
    NSInteger closestIndex = ([points count] - 1) / 2;
    NSValue *closest = [NSValue valueWithCGPoint:self.center];
    for (NSValue *currentPoint in points) {
        CGFloat currentDistance = PCOKitDistanceForPoints([currentPoint CGPointValue], point);
        CGFloat closestDistance = PCOKitDistanceForPoints([closest CGPointValue], point);
        
        if (currentDistance < closestDistance) {
            closest = currentPoint;
            closestIndex = [points indexOfObject:currentPoint];
        }
    }
    
    offset.width = (closestIndex / _LESLyricsEditorTextShadowOffsetCellViewLineCount) - ((_LESLyricsEditorTextShadowOffsetCellViewLineCount - 1) / 2);
    offset.height = (closestIndex % _LESLyricsEditorTextShadowOffsetCellViewLineCount) - ((_LESLyricsEditorTextShadowOffsetCellViewLineCount - 1) / 2);
    
    return offset;
}


- (NSArray *)intersectionPoints {
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat horizontalOffset = width / _LESLyricsEditorTextShadowOffsetCellViewLineCount;
    CGFloat verticalOffset = height / _LESLyricsEditorTextShadowOffsetCellViewLineCount;
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:_LESLyricsEditorTextShadowOffsetCellViewLineCount * _LESLyricsEditorTextShadowOffsetCellViewLineCount];
    
    CGFloat halfXOffset = PCOKitHalf(horizontalOffset);
    CGFloat halfYOffset = PCOKitHalf(verticalOffset);
    
    for (NSUInteger column = 1; column <= _LESLyricsEditorTextShadowOffsetCellViewLineCount; column++) {
        for (NSUInteger row = 1; row <= _LESLyricsEditorTextShadowOffsetCellViewLineCount; row++) {
            CGFloat x = horizontalOffset * column;
            CGFloat y = verticalOffset * row;
            x -= halfXOffset;
            y -= halfYOffset;
            CGPoint point = CGPointMake(x, y);
            [array addObject:[NSValue valueWithCGPoint:PCOCGPointIntegral(point)]];
        }
    }
    
    return [array copy];
}

- (void)drawRect:(CGRect)rect {
    
    [pco_kit_GRAY(75.0) set];
    
    CGRect centerFrame = self.centerView.frame;
    
    NSArray *points = [self intersectionPoints];
    for (NSValue *value in points) {
        CGPoint point = [value CGPointValue];
        CGRect frame = (CGRect){{point.x - 1.0, point.y - 1.0}, {2.0, 2.0}};
        if (!CGRectIntersectsRect(centerFrame, frame)) {
            [[UIBezierPath bezierPathWithRect:frame] fill];
        }
    }
}

- (void)gestureRecognizerDidRecognizeAction:(UILongPressGestureRecognizer *)longPress {
    CGSize offset = [self offsetForPoint:[longPress locationInView:self]];
    [UIView animateWithDuration:0.1 animations:^{
        self.currentOffset = offset;
    }];
    
    if (self.sizePickedHandler) {
        self.sizePickedHandler(offset);
    }
}

@end