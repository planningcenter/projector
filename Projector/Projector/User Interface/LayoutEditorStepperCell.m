/*!
 * LayoutEditorStepperCell.m
 *
 *
 * Created by Skylar Schipper on 6/10/14
 */

#import "LayoutEditorStepperCell.h"

static CGFloat const _LayoutEditorStepperCellStepperControlWidth = 44.0;
static CGFloat const _LayoutEditorStepperCellStepperControlStrokeWidth = 1.0;

@interface _LayoutEditorStepperCellStepperControl : PCOControl

@property (nonatomic) BOOL invertArrow;

@end
@interface _LayoutEditorStepperCellStepper : PCOControl

@property (nonatomic, strong) NSNumber *maxValue;
@property (nonatomic, strong) NSNumber *minValue;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic) LayoutEditorStepperStyle stepperStyle;

@property (nonatomic, weak) PCOView *leftView;
@property (nonatomic, weak) PCOView *rightView;
@property (nonatomic, weak) _LayoutEditorStepperCellStepperControl *leftControl;
@property (nonatomic, weak) _LayoutEditorStepperCellStepperControl *rightControl;
@property (nonatomic, weak) PCOLabel *displayLabel;

@property (nonatomic, weak) _LayoutEditorStepperCellStepperControl *currentRepeatFire;
@property (nonatomic, strong) NSTimer *touchRepeatTimer;
@property (nonatomic) uint64_t touchRepeatCount;

@end


@interface LayoutEditorStepperCell ()

@property (nonatomic) CGFloat stepperPadding;
@property (nonatomic, weak) _LayoutEditorStepperCellStepper *stepper;

@property (nonatomic, weak) NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) NSLayoutConstraint *rightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *bottomConstraint;

@end

@implementation LayoutEditorStepperCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor layoutControllerPreviewBackgroundColor];
    self.textLabel.textColor = [UIColor layoutEditorSidebarTitleTextColor];
    self.textLabel.font = [UIFont defaultFontOfSize_16];
    
    self.minValue = @0;
    self.maxValue = @100;
    
    [self.stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.stepper.displayLabel.textColor = [UIColor whiteColor];
    self.stepper.displayLabel.font = [UIFont defaultFontOfSize_14];
    
    self.stepperPadding = 6.0;
    
    self.stepperStyle = LayoutEditorStepperStyleInteger;
    self.value = @0;
    
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.textLabel offset:16.0 edges:UIRectEdgeLeft]];
    [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.textLabel offset:4.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.stepper attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
}

#pragma mark -
#pragma mark - Proxy Setters/Getters
- (void)setStepperStyle:(LayoutEditorStepperStyle)stepperStyle {
    self.stepper.stepperStyle = stepperStyle;
}
- (LayoutEditorStepperStyle)stepperStyle {
    return self.stepper.stepperStyle;
}
- (void)setValue:(NSNumber *)value {
    self.stepper.value = value;
}
- (NSNumber *)value {
    return self.stepper.value;
}
- (void)setMinValue:(NSNumber *)minValue {
    self.stepper.minValue = minValue;
}
- (NSNumber *)minValue {
    return self.stepper.minValue;
}
- (void)setMaxValue:(NSNumber *)maxValue {
    self.stepper.maxValue = maxValue;
}
- (NSNumber *)maxValue {
    return self.stepper.maxValue;
}

#pragma mark -
#pragma mark - Layout
- (void)setStepperPadding:(CGFloat)stepperPadding {
    _stepperPadding = stepperPadding;
    self.topConstraint.constant = stepperPadding;
    self.rightConstraint.constant = -stepperPadding;
    self.bottomConstraint.constant = -stepperPadding;
}

#pragma mark -
#pragma mark - Lazy Getters
- (_LayoutEditorStepperCellStepper *)stepper {
    if (!_stepper) {
        _LayoutEditorStepperCellStepper *stepper = [_LayoutEditorStepperCellStepper newAutoLayoutView];
        
        _stepper = stepper;
        [self.contentView addSubview:stepper];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:stepper attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.stepperPadding];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:stepper attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.stepperPadding];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:stepper attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.stepperPadding];
        
        [self.contentView addConstraints:@[top, bottom, right]];
        
        self.topConstraint = top;
        self.bottomConstraint = bottom;
        self.rightConstraint = right;
    }
    return _stepper;
}

#pragma mark -
#pragma mark - Value Handlers
- (void)stepperValueChanged:(id)sender {
    if (self.valueChangeHandler) {
        welf();
        NSNumber *val = [self.value copy];
        self.valueChangeHandler(welf, val);
    }
}


@end


@implementation _LayoutEditorStepperCellStepper

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = pco_kit_GRAY(8.0);
    self.layer.borderColor = [[UIColor layoutEditorSidebarControlStrokeColor] CGColor];
    self.layer.borderWidth = _LayoutEditorStepperCellStepperControlStrokeWidth;
    self.layer.cornerRadius = 6.0;
    self.clipsToBounds = YES;
    
    [self.leftControl addTarget:self action:@selector(valueChangedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightControl addTarget:self action:@selector(valueChangedHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.leftControl addTarget:self action:@selector(touchDownBegin:) forControlEvents:UIControlEventTouchDown];
    [self.leftControl addTarget:self action:@selector(touchDownEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.rightControl addTarget:self action:@selector(touchDownBegin:) forControlEvents:UIControlEventTouchDown];
    [self.rightControl addTarget:self action:@selector(touchDownEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
}

- (void)setValue:(NSNumber *)value {
    if ([value floatValue] < [self.minValue floatValue]) {
        _value = [self.minValue copy];
    } else if ([value floatValue] > [self.maxValue floatValue]) {
        _value = [self.maxValue copy];
    } else {
        _value = [value copy];
    }
    
    [self updateDisplayValue];
}
- (void)setStepperStyle:(LayoutEditorStepperStyle)stepperStyle {
    _stepperStyle = stepperStyle;
    
    [self updateDisplayValue];
}

- (void)updateDisplayValue {
    if (self.stepperStyle == LayoutEditorStepperStyleInteger) {
        self.displayLabel.text = [NSString stringWithFormat:@"%llu",[self.value unsignedLongLongValue]];
    } else {
        self.displayLabel.text = [NSString stringWithFormat:@"%.01f",[self.value doubleValue]];
    }
}

- (CGSize)intrinsicContentSize {
    CGFloat width = _LayoutEditorStepperCellStepperControlWidth * 2.0;
    CGSize label = [self.displayLabel intrinsicContentSize];
    width += MAX(label.width, _LayoutEditorStepperCellStepperControlWidth);
    width += (_LayoutEditorStepperCellStepperControlStrokeWidth * 2.0);
    return CGSizeMake(width, UIViewNoIntrinsicMetric);
}

- (_LayoutEditorStepperCellStepperControl *)leftControl {
    if (!_leftControl) {
        _LayoutEditorStepperCellStepperControl *control = [_LayoutEditorStepperCellStepperControl newAutoLayoutView];
        control.invertArrow = YES;
        
        _leftControl = control;
        [self addSubview:control];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:control offset:0.0 edges:UIRectEdgeTop | UIRectEdgeLeft | UIRectEdgeBottom]];
        [self addConstraint:[NSLayoutConstraint width:_LayoutEditorStepperCellStepperControlWidth forView:control]];
    }
    return _leftControl;
}
- (_LayoutEditorStepperCellStepperControl *)rightControl {
    if (!_rightControl) {
        _LayoutEditorStepperCellStepperControl *control = [_LayoutEditorStepperCellStepperControl newAutoLayoutView];
        
        _rightControl = control;
        [self addSubview:control];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:control offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeRight]];
        [self addConstraint:[NSLayoutConstraint width:_LayoutEditorStepperCellStepperControlWidth forView:control]];
    }
    return _rightControl;
}
- (PCOView *)leftView {
    if (!_leftView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor colorWithCGColor:self.layer.borderColor];
        
        _leftView = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
        [self addConstraint:[NSLayoutConstraint width:_LayoutEditorStepperCellStepperControlStrokeWidth forView:view]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.leftControl attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    }
    return _leftView;
}
- (PCOView *)rightView {
    if (!_rightView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor colorWithCGColor:self.layer.borderColor];
        
        _rightView = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
        [self addConstraint:[NSLayoutConstraint width:_LayoutEditorStepperCellStepperControlStrokeWidth forView:view]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.rightControl attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    }
    return _rightView;
}
- (PCOLabel *)displayLabel {
    if (!_displayLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.textAlignment = NSTextAlignmentCenter;
        label.insets = UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0);
        
        _displayLabel = label;
        [self addSubview:label];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.leftView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.rightView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    }
    return _displayLabel;
}

- (void)valueChangedHandler:(id)sender {
    BOOL up = (sender == self.rightControl);
    if (self.stepperStyle == LayoutEditorStepperStyleInteger) {
        NSInteger value = [self.value integerValue];
        value += (up) ? 1 : -1;
        self.value = @(value);
    } else {
        CGFloat value = [self.value floatValue];
        value += (up) ? 0.1 : -0.1;
        self.value = @(value);
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchDownBegin:(id)sender {
    self.touchRepeatCount = 0;
    if ([sender isKindOfClass:[_LayoutEditorStepperCellStepperControl class]]) {
        self.currentRepeatFire = sender;
    }
    if (![self.touchRepeatTimer isValid]) {
        self.touchRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(_touchRepeatTimerFire:) userInfo:nil repeats:YES];
    }
}
- (void)touchDownEnd:(id)sender {
    [self.touchRepeatTimer invalidate];
    self.touchRepeatTimer = nil;
}
- (void)_touchRepeatTimerFire:(NSTimer *)timer {
    self.touchRepeatCount++;
    
    if (self.currentRepeatFire) {
        if (self.touchRepeatCount == 1) {
            [self valueChangedHandler:self.currentRepeatFire];
        } else if (self.touchRepeatCount <= 100) {
            if (self.touchRepeatCount % 50 == 0) {
                [self valueChangedHandler:self.currentRepeatFire];
            }
        } else if (self.touchRepeatCount < 1000) {
            if (self.touchRepeatCount % 10 == 0) {
                [self valueChangedHandler:self.currentRepeatFire];
            }
        } else {
            [self valueChangedHandler:self.currentRepeatFire];
        }
    }
}

@end

@implementation _LayoutEditorStepperCellStepperControl

- (void)drawRect:(CGRect)rect {
    if (self.highlighted) {
        [[UIColor whiteColor] setFill];
    } else {
        [[UIColor layoutEditorSidebarTitleTextColor] setFill];
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx); {
        if (self.invertArrow) {
            CGContextRotateCTM(ctx, PCOKitRotate180);
            CGContextTranslateCTM(ctx, - CGRectGetWidth(self.bounds) - _LayoutEditorStepperCellStepperControlStrokeWidth, -CGRectGetHeight(self.bounds) - _LayoutEditorStepperCellStepperControlStrokeWidth);
        }
        
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint:CGPointMake(22, 11)];
        [bezierPath addLineToPoint:CGPointMake(29, 20)];
        [bezierPath addLineToPoint:CGPointMake(16, 20)];
        [bezierPath addLineToPoint:CGPointMake(22, 11)];
        [bezierPath closePath];
        [bezierPath fill];
        
    } CGContextRestoreGState(ctx);
}

- (void)setInvertArrow:(BOOL)invertArrow {
    _invertArrow = invertArrow;
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor blackColor];
    } else {
        self.backgroundColor = [UIColor layoutControllerPreviewBackgroundColor];
    }
    
    [self setNeedsDisplay];
}

@end

_PCO_EXTERN_STRING kLayoutEditorStepperCellIdentifier = @"kLayoutEditorStepperCellIdentifier";

