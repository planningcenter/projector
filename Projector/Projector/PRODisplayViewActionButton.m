/*!
 * PRODisplayViewActionButton.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/10/14
 */

#import "PRODisplayViewActionButton.h"

@interface _PRODisplayViewActionButtonInner : UIView

@property (nonatomic, weak) UILabel *label;

@end

@interface PRODisplayViewActionButton ()

@property (nonatomic, strong, readwrite) NSString *title;

@property (nonatomic, weak) UIVisualEffectView *effectView;

@property (nonatomic, weak) _PRODisplayViewActionButtonInner *innerView;

@end

@implementation PRODisplayViewActionButton

- (instancetype)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.title = title;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    self.layer.needsDisplayOnBoundsChange = YES;
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:effect];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.userInteractionEnabled = NO;
    
    view.layer.cornerRadius = PCOKitHalf(self.intrinsicContentSize.width - 16.0);
    view.layer.masksToBounds = YES;
    
    _PRODisplayViewActionButtonInner *inner = [_PRODisplayViewActionButtonInner newAutoLayoutView];
    inner.backgroundColor = [UIColor clearColor];
    inner.layer.needsDisplayOnBoundsChange = YES;
    
    [view.contentView addSubview:inner];
    [view.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:inner offset:0.0 edges:UIRectEdgeAll]];
    
    _innerView = inner;
    
    _effectView = view;
    [self addSubview:view];
    [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:8.0 edges:UIRectEdgeAll]];
    
    self.actionState = PRODisplayViewActionButtonStateOff;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.innerView.label.text = title;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(40.0, 40.0);
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.innerView.tintColor = self.tintColor;
}

- (UIView *)contentView {
    return self.innerView;
}

- (void)setActionState:(PRODisplayViewActionButtonState)actionState {
    _actionState = actionState;
    
    switch (actionState) {
        case PRODisplayViewActionButtonStateOff:
            self.tintColor = [UIColor projectorBlackColor];
            break;
        case PRODisplayViewActionButtonStateCurrent:
            self.tintColor = [UIColor currentItemGreenColor];
            break;
        case PRODisplayViewActionButtonStateNext:
            self.tintColor = [UIColor nextUpItemBlueColor];
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in [touches allObjects]) {
        if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    }
}

@end

@implementation _PRODisplayViewActionButtonInner

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self setNeedsDisplay];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [self.tintColor set];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5))];
    path.lineWidth = 1.0;
    [path stroke];
}

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [UILabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_14];
        
        
        _label = label;
        [self addSubview:label];
        
        [self addConstraints:[NSLayoutConstraint center:label inView:self]];
    }
    return _label;
}

@end
