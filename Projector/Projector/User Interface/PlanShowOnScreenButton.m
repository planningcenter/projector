/*!
 * PlanShowOnScreenButton.m
 *
 *
 * Created by Skylar Schipper on 7/14/14
 */

#import "PlanShowOnScreenButton.h"

@interface PlanShowOnScreenButton ()

@property (nonatomic, weak) PCOView *logoView;

@property (nonatomic, weak) UIImageView *playButton;

@end

@implementation PlanShowOnScreenButton

- (void)initializeDefaults {
    [super initializeDefaults];
    
    welf();
    [[NSNotificationCenter defaultCenter] addObserverForName:kProjectorDefaultAspectRatioSetting object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [welf setNeedsLayout];
        [welf setNeedsDisplay];
    }];
    
    PCOKitLazyLoad(self.aspectImageView);
}

- (PCOButton *)innerButton {
    if (!_innerButton) {
        UIColor *color = pco_kit_RGB(124,123,139);
        
        PCOButton *button = [[PCOButton alloc] initWithFrame:CGRectZero];
        button.titleLabel.font = [UIFont defaultFontOfSize_12];
        button.userInteractionEnabled = NO;
        
        [button setTitle:NSLocalizedString(@"Update Logo", nil) forState:UIControlStateNormal];
        [button setTitleColor:color forState:UIControlStateNormal];
        
        [button setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor blackColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        _innerButton = button;
        [self addSubview:button];
    }
    return _innerButton;
}
- (PCOView *)logoView {
    if (!_logoView) {
        PCOView *view = [[PCOView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = NO;
        
        _logoView = view;
        [self addSubview:view];
    }
    return _logoView;
}
- (UIImageView *)aspectImageView {
    if (!_aspectImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeProjectorPreferred;
        
        [imageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [imageView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [imageView setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        
        _aspectImageView = imageView;
        [self.logoView addSubview:imageView];
    }
    return _aspectImageView;
}
- (UIImageView *)playButton {
    if (!_playButton) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectZero];
        view.image = [UIImage imageNamed:@"blue-play-btn"];
        view.hidden = !self.showPlayButton;
        
        _playButton = view;
        [self.aspectImageView addSubview:view];
    }
    return _playButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat padding = 8.0;
    
    self.innerButton.frame = ({
        CGRect frame = CGRectZero;
        frame.size.width = CGRectGetWidth(self.bounds) - (padding * 2);
        frame.size.height = 30.0;
        frame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(frame) - padding;
        frame.origin.x = padding;
        frame;
    });
    
    self.logoView.frame = ({
        CGRect frame;
        frame.origin = CGPointZero;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.size.height = CGRectGetMinY(self.innerButton.frame);
        UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(padding, padding, padding, padding));
    });
    
    self.aspectImageView.frame = ({
        PCOKitRectThatFitsSizeWithAspect(self.logoView.bounds.size, ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]));
    });
    
    self.playButton.frame = ({
        CGFloat size = 32.0;
        CGRect frame = CGRectZero;
        frame.origin.x = PCOKitRectGetHalfWidth(self.aspectImageView.frame) - (size / 2.0);
        frame.origin.y = PCOKitRectGetHalfHeight(self.aspectImageView.frame) - (size / 2.0);
        frame.size.width = size;
        frame.size.height = size;
        CGRectIntegral(frame);
    });
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [self.innerButton setTitle:title forState:state];
}

- (void)setCurrentColor:(UIColor *)currentColor {
    _currentColor = currentColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!self.currentColor) {
        return;
    }
    
    [self.currentColor set];
    
    CGRect frame = [self convertRect:self.aspectImageView.frame fromView:self.aspectImageView.superview];
    
    CGFloat insets = -2.0;
    
    [[UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(insets, insets, insets, insets))] fill];
}

- (void)setShowPlayButton:(BOOL)showPlayButton {
    _showPlayButton = showPlayButton;
    self.playButton.hidden = !showPlayButton;
}

@end
