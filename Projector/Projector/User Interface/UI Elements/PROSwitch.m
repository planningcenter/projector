/*!
 * PROSwitch.m
 * MCTSwitch
 *
 *
 * Created by Skylar Schipper on 11/11/14
 */

#import "PROSwitch.h"

#define PROSwitchHEX(hex) [[UIColor alloc] initWithRed:(((hex >> 16) & 0xFF) / 255.0) green:(((hex >> 8) & 0xFF) / 255.0) blue:((hex & 0xFF) / 255.0) alpha:1.0]
#define PROSwitchWidth 60.0
#define PROSwitchHeight 32.0
#define PROSwitchPadding 5.0

#define PROSwitchOnOffset ((PROSwitchHeight / 2.0) - PROSwitchPadding + 3.0)
#define PROSwitchOffOffset -(PROSwitchOnOffset)

#define PROSwitchOnTrackingOffset (PROSwitchOnOffset - 3.0)
#define PROSwitchOffTrackingOffset PROSwitchOffOffset + 3.0

#define PROSwitchResetOffset() if ([self isOn]) { self.thumbXCenter.constant = PROSwitchOnOffset; } else { self.thumbXCenter.constant = PROSwitchOffOffset; }

@interface _PROSwitchThumbView : UIView @end

@interface PROSwitch ()

@property (nonatomic, weak) _PROSwitchThumbView *thumbView;
@property (nonatomic, weak) NSLayoutConstraint *thumbXCenter;

@end

@implementation PROSwitch

// MARK: - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        [self finalizeInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self finalizeInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:(CGRect){frame.origin, {PROSwitchWidth, PROSwitchHeight}}];
    if (self) {
        [self finalizeInit];
    }
    return self;
}
- (void)finalizeInit {
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    self.layer.cornerRadius = floorf(self.intrinsicContentSize.height / 2.0);
    self.layer.masksToBounds = YES;
    
    _offThumbColor = PROSwitchHEX(0x626270);
    _offBackgroundColor = PROSwitchHEX(0x19191F);
    _onBackgroundColor = PROSwitchHEX(0xFF953B);
    _onThumbColor = PROSwitchHEX(0xFFFFFF);
    
    [self setOn:YES animated:NO sendEvent:NO];
}

// MARK: - Color Helpers
- (void)setOffBackgroundColor:(UIColor *)offBackgroundColor {
    _offBackgroundColor = offBackgroundColor;
    [self updateColorsForCurrentState];
}
- (void)setOffThumbColor:(UIColor *)offThumbColor {
    _offThumbColor = offThumbColor;
    [self updateColorsForCurrentState];
}
- (void)setOnBackgroundColor:(UIColor *)onBackgroundColor {
    _onBackgroundColor = onBackgroundColor;
    [self updateColorsForCurrentState];
}
- (void)setOnThumbColor:(UIColor *)onThumbColor {
    _onThumbColor = onThumbColor;
    [self updateColorsForCurrentState];
}

- (void)updateColorsForCurrentState {
    if (![self isOn]) {
        self.backgroundColor = self.offBackgroundColor;
        self.thumbView.backgroundColor = self.offThumbColor;
    } else {
        self.backgroundColor = self.onBackgroundColor;
        self.thumbView.backgroundColor = self.onThumbColor;
    }
}

// MARK: - Layout
- (CGSize)intrinsicContentSize {
    return CGSizeMake(PROSwitchWidth, PROSwitchHeight);
}

// MARK: - Lazy Loaders
- (_PROSwitchThumbView *)thumbView {
    if (!_thumbView) {
        _PROSwitchThumbView *view = [[_PROSwitchThumbView alloc] initWithFrame:CGRectZero];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.layer.cornerRadius = floorf(view.intrinsicContentSize.height / 2.0);
        view.layer.masksToBounds = YES;
        view.userInteractionEnabled = NO;
        
        _thumbView = view;
        [self addSubview:view];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
        self.thumbXCenter = centerX;
        
        [self addConstraint:centerX];
    }
    return _thumbView;
}

// MARK: - On State
- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}
- (void)setOn:(BOOL)on animated:(BOOL)animated {
    [self setOn:on animated:animated sendEvent:NO];
}
- (void)setOn:(BOOL)on animated:(BOOL)animated sendEvent:(BOOL)sendEvent {
    _on = on;
    
    if (sendEvent) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    if (!self.thumbView) {
        NSLog(@"Failed to load thumb, This should never happen %s",__FILE__);
    }
    
    PROSwitchResetOffset();
    
    if (animated) {
        [UIView animateKeyframesWithDuration:0.2 delay:0.0 options:0 animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
                [self layoutIfNeeded];
            }];
            [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
                self.thumbView.transform = CGAffineTransformIdentity;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
                [self updateColorsForCurrentState];
            }];
        } completion:nil];
    } else {
        [UIView performWithoutAnimation:^{
            self.thumbView.transform = CGAffineTransformIdentity;
            [self layoutIfNeeded];
            [self updateColorsForCurrentState];
        }];
    }
}

- (void)beginTracking {
    self.thumbView.transform = CGAffineTransformIdentity;
    
    if ([self isOn]) {
        self.thumbXCenter.constant = PROSwitchOnTrackingOffset;
    } else {
        self.thumbXCenter.constant = PROSwitchOffTrackingOffset;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.thumbView.transform = CGAffineTransformMakeScale(1.2, 1.0);
        [self layoutIfNeeded];
    }];
}
- (void)endTrackingInside {
    [self setOn:![self isOn] animated:YES sendEvent:YES];
}
- (void)endTrackingOutside {
    PROSwitchResetOffset();
    
    [UIView animateWithDuration:0.1 animations:^{
        self.thumbView.transform = CGAffineTransformIdentity;
        [self layoutIfNeeded];
    }];
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

@end


@implementation _PROSwitchThumbView

- (CGSize)intrinsicContentSize {
    return CGSizeMake(PROSwitchHeight - PROSwitchPadding, PROSwitchHeight - PROSwitchPadding);
}

@end
