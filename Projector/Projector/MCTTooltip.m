/*!
 * MCTTooltip.m
 * MCTTooltop
 *
 *
 * Created by Skylar Schipper on 11/20/14
 */

#import "MCTTooltip.h"

#define LABEL_PADDING 8.0

@interface _MCTTooltipPop : UIView

@property (nonatomic, weak) UILabel *textLabel;

- (CGFloat)preferredHeight;

@end

@interface MCTTooltip ()

@property (nonatomic, weak) UILabel *infoLabel;

@property (nonatomic, readwrite, getter=isTooltipShowing) BOOL tooltipShowing;

@property (nonatomic, weak) _MCTTooltipPop *tipView;

@property (nonatomic, strong, readonly) UIColor *highlightColor;

@property (nonatomic, copy) void (^labelConfig)(UILabel *);
@property (nonatomic, copy) void (^viewConfig)(UIView *);

@end

@implementation MCTTooltip

// MARK: - Initialize
- (instancetype)init {
    self = [super init];
    if (self) {
        [self finalSetup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self finalSetup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self finalSetup];
    }
    return self;
}
- (void)finalSetup {
    self.backgroundColor = [UIColor clearColor];
    self.infoFont = [UIFont systemFontOfSize:16.0];

    self.message = NSLocalizedString(@"This is the text for your tooltip.\n\nWe'll do our best to lay it out for you.", nil);
    
    self.preferredTooltipSize = CGSizeMake(200.0, 32.0);
    
    self.closeIconColor = HEX(0xDD4E4A);
    
    [self hideTooltipAnimated:NO completion:nil];
}

- (UIColor *)highlightColor {
    CGFloat h, s, b, a;
    if ([self.tintColor getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h saturation:s brightness:b * 0.60 alpha:a];
    }
    return self.tintColor;
}

// MARK: - Setters
- (void)setInfoFont:(UIFont *)infoFont {
    _infoFont = infoFont;
    self.infoLabel.font = infoFont;
}

// MARK: - Layout
- (CGSize)intrinsicContentSize {
    return CGSizeMake(32.0, 32.0);
}

// MARK: - Drawing
- (void)drawRect:(CGRect)rect {
    if ([self isTooltipShowing]) {
        [self.closeIconColor set];
    } else {
        [self.tintColor set];
    }
    
    
    if ([self isHighlighted]) {
        if (self.highlightColor) {
            [self.highlightColor set];
        }
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0))];
    path.lineWidth = 1.0;
    [path stroke];
}

// MARK: - Style
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (self.highlightColor) {
            self.infoLabel.textColor = self.highlightColor;
        } else {
            if ([self isTooltipShowing]) {
                self.infoLabel.textColor = self.closeIconColor;
            } else {
                self.infoLabel.textColor = self.tintColor;
            }
        }
    } else {
        if ([self isTooltipShowing]) {
            self.infoLabel.textColor = self.closeIconColor;
        } else {
            self.infoLabel.textColor = self.tintColor;
        }
    }
    
    [self setNeedsDisplay];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    if ([self isTooltipShowing]) {
        self.infoLabel.textColor = self.closeIconColor;
    } else {
        self.infoLabel.textColor = self.tintColor;
    }
    
    [self setNeedsDisplay];
}

- (void)setCloseIconColor:(UIColor *)closeIconColor {
    _closeIconColor = closeIconColor;
    if ([self isTooltipShowing]) {
        self.infoLabel.textColor = self.closeIconColor;
    }
}

// MARK: - Lazy Loaders
- (UILabel *)infoLabel {
    if (!_infoLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = self.infoFont;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = self.tintColor;
        label.text = NSLocalizedString(@"i", nil);
        
        _infoLabel = label;
        [self addSubview:label];
        
        CGFloat offset = 1.0;
        if (self.window.screen.scale >= 2.0) {
            offset = 0.5;
        }
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:offset]];
    }
    return _infoLabel;
}
- (_MCTTooltipPop *)tipView {
    if (!_tipView) {
        _MCTTooltipPop *view = [[_MCTTooltipPop alloc] initWithFrame:CGRectZero];
        view.alpha = 0.0;
        view.backgroundColor = [UIColor whiteColor];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tipTouchDismissAction:)]];
        
        [self willConfigurePopupView:view];
        if (self.viewConfig) {
            self.viewConfig(view);
        }
        [self willConfigureMessageLabel:view.textLabel];
        if (self.labelConfig) {
            self.labelConfig(view.textLabel);
        }
        
        _tipView = view;
        [self addSubview:view];
    }
    return _tipView;
}

- (void)tipTouchDismissAction:(id)sender {
    [self hideTooltipAnimated:YES completion:nil];
}

- (void)configureMessageLabel:(void(^)(UILabel *label))block {
    self.labelConfig = block;
}
- (void)configurePopupView:(void(^)(UIView *view))block {
    self.viewConfig = block;
}
- (void)willConfigureMessageLabel:(UILabel *)label {
    
}
- (void)willConfigurePopupView:(UIView *)view {
    
}

// MARK: - Touch Tracking
- (void)beginTracking {
    
}
- (void)endTrackingInside {
    if (![self isTooltipShowing]) {
        [self showTooltipAnimated:YES completion:nil];
    } else {
        [self hideTooltipAnimated:YES completion:nil];
    }
}
- (void)endTrackingOutside {
    if ([self isTooltipShowing]) {
        [self hideTooltipAnimated:YES completion:nil];
    }
}

// MARK: - User Interaction
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([super beginTrackingWithTouch:touch withEvent:event]) {
        [self beginTracking];
        return YES;
    }
    return NO;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        [self endTrackingInside];
    } else {
        [self endTrackingOutside];
    }
    [super endTrackingWithTouch:touch withEvent:event];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self isTooltipShowing]) {
        return _tipView;
    }
    return [super hitTest:point withEvent:event];
}

// MARK: - Show/Hide
- (void)showTooltipAnimated:(BOOL)flag completion:(void(^)(void))completion {
    self.tooltipShowing = YES;
    self.selected = YES;
    
    self.tipView.textLabel.text = self.message;
    self.tipView.bounds = (CGRect){CGPointZero, self.preferredTooltipSize};
    
    CGRect bounds = self.tipView.bounds;
    bounds.size.height = [self.tipView preferredHeight];
    self.tipView.bounds = bounds;
    
    self.tipView.center = ({
        CGPoint center = CGPointZero;
        center.y = -self.tipView.bounds.size.height / 2.0;
        center.x = CGRectGetWidth(self.bounds) / 2.0;
        center;
    });
    
    CGRect windowFrame = [self.window convertRect:self.tipView.frame fromView:self];
    CGRect frame = self.tipView.frame;
    if (CGRectGetMinX(windowFrame) < self.layoutMargins.left) {
        frame.origin.x += -(CGRectGetMinX(windowFrame)) + self.layoutMargins.left;
    }
    if (CGRectGetMinY(windowFrame) < self.layoutMargins.top) {
        frame.origin.y += -(CGRectGetMinY(windowFrame)) + self.layoutMargins.top;
    }
    if (CGRectGetMaxX(windowFrame) > CGRectGetWidth(self.window.bounds)) {
        frame.origin.x -= (CGRectGetMaxX(windowFrame) - CGRectGetWidth(self.window.bounds)) + self.layoutMargins.right;
    }
    
    self.tipView.frame = self.bounds;
    self.tipView.textLabel.alpha = 0.0;
    
    if (flag) {
        [UIView animateKeyframesWithDuration:0.2 delay:0.0 options:0 animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                self.tipView.alpha = 1.0;
                self.infoLabel.text = @"×";
                self.infoLabel.textColor = self.closeIconColor;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
                self.tipView.frame = frame;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.5 animations:^{
                self.tipView.textLabel.alpha = 1.0;
            }];
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        [UIView performWithoutAnimation:^{
            self.tipView.alpha = 1.0;
            self.tipView.frame = frame;
            self.tipView.textLabel.alpha = 1.0;
            self.infoLabel.text = @"×";
            self.infoLabel.textColor = self.closeIconColor;
        }];
        if (completion) {
            completion();
        }
    }
}
- (void)hideTooltipAnimated:(BOOL)flag completion:(void(^)(void))completion {
    self.tooltipShowing = NO;
    self.selected = NO;
    
    void(^ani)(void) = ^ {
        self.infoLabel.text = @"i";
        self.tipView.alpha = 0.0;
        self.infoLabel.textColor = self.tintColor;
    };
    void(^done)(void) = ^ {
        [_tipView removeFromSuperview];
        _tipView = nil;
    };
    
    if (flag) {
        [UIView animateWithDuration:0.1 animations:ani completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
            done();
        }];
    } else {
        [UIView performWithoutAnimation:ani];
        if (completion) {
            completion();
        }
        done();
        
    }
}

@end


@implementation _MCTTooltipPop

- (CGFloat)preferredHeight {
    NSString *text = self.textLabel.text;
    
    CGRect frame = [text boundingRectWithSize:CGSizeMake(self.bounds.size.width - (LABEL_PADDING * 2.0), 300.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.textLabel.font} context:nil];
    
    
    return ceilf(frame.size.height) + (LABEL_PADDING * 2.0);
}

// MARK: - Lazy Loaders
- (UILabel *)textLabel {
    if (!_textLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 0;
        
        _textLabel = label;
        [self addSubview:label];
        
        NSDictionary *metrics = @{@"p": @(LABEL_PADDING)};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-p-[label]-p-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(label)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-p-[label]-p-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(label)]];
    }
    return _textLabel;
}

@end
