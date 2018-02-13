/*!
 * PlanViewMobileGridTopBarView.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/3/14
 */

#import "PlanViewMobileGridTopBarView.h"

@interface PlanViewMobileGridTopBarView ()



@end

@implementation PlanViewMobileGridTopBarView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor mobilePlanViewStrokeColor];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                            @"H:|[alert]-1-[logo(==alert)]-1-[black(==logo)]|",
                                                                            @"V:|[alert]|",
                                                                            @"V:|[logo]|",
                                                                            @"V:|[black]|"
                                                                            ]
                                                                  metrics:nil
                                                                    views:@{
                                                                            @"alert": self.alertButton,
                                                                            @"logo": self.logoButton,
                                                                            @"black": self.blackButton
                                                                            }]];
}


// MARK: - Lazy Loaders
- (PCOButton *)alertButton {
    if (!_alertButton) {
        PCOButton *button = [self _defaultButton];
        [button setTitle:NSLocalizedString(@"Create Alert", nil) forState:UIControlStateNormal];
        [button setImage:[UIImage templateImageNamed:@"np_alert_text"] forState:UIControlStateNormal];
        
        [self addSubview:button];
        _alertButton = button;
    }
    return _alertButton;
}
- (PCOButton *)logoButton {
    if (!_logoButton) {
        PCOButton *button = [self _defaultButton];
        [button setTitle:NSLocalizedString(@"Logo", nil) forState:UIControlStateNormal];
        [button setImage:[UIImage templateImageNamed:@"camera-icon"] forState:UIControlStateNormal];
        
        [self addSubview:button];
        _logoButton = button;
    }
    return _logoButton;
}
- (PCOButton *)blackButton {
    if (!_blackButton) {
        PCOButton *button = [self _defaultButton];
        [button setTitle:NSLocalizedString(@"Black Screen", nil) forState:UIControlStateNormal];
        [button setImage:[UIImage templateImageNamed:@"screen-icon"] forState:UIControlStateNormal];
        
        [self addSubview:button];
        _blackButton = button;
    }
    return _blackButton;
}

- (PCOButton *)_defaultButton {
    PCOButton *button = [PCOButton newAutoLayoutView];
    button.adjustsImageWhenHighlighted = NO;
    button.backgroundColor = [UIColor mobileGridViewBackgroundColor];
    [button setBackgroundColor:[UIColor projectorBlackColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor mobilePlanViewTopBarTintColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor mobilePlanViewTopBarTintColor];
    button.titleLabel.font = [UIFont defaultFontOfSize_12];
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 8.0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 0.0);
    
    return button;
}

@end
