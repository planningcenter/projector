/*!
 * PlanShowOnScreenView.m
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#import "PlanShowOnScreenView.h"
#import "PCODecorationImageView.h"
#import "PRODisplayController.h"
#import "PROLogoPickerView.h"
#import "BlackScreenButton.h"

#define PlanShowOnScreenViewPadding 12.0

@interface PlanShowOnScreenView ()

@end

@implementation PlanShowOnScreenView
@synthesize alertButton = _alertButton;
@synthesize logoView = _logoView;
@synthesize blackScreenButton = _blackScreenButton;

- (void)initializeDefaults {
    [super initializeDefaults];
    
    [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.logoView offset:PlanShowOnScreenViewPadding edges:UIRectEdgeLeft | UIRectEdgeTop]];
    [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.blackScreenButton offset:PlanShowOnScreenViewPadding edges:UIRectEdgeRight | UIRectEdgeTop]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-1.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blackScreenButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:1.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.alertButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:-PlanShowOnScreenViewPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.blackScreenButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.alertButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:-PlanShowOnScreenViewPadding]];
    [self addConstraint:[NSLayoutConstraint centerHorizontal:self.alertButton inView:self]];
    [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.alertButton offset:0.0 edges:UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeBottom]];
    [self addConstraint:[NSLayoutConstraint height:40.0 forView:self.alertButton]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAlertActive) name:PRODisplayControllerDidSetAlertNotification object:nil];
    
    [self checkAlertActive];
}
- (PCOButton *)alertButton {
    if (!_alertButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.tintColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont defaultFontOfSize_12];
        [button setTitle:NSLocalizedString(@"Create Alert", nil) forState:UIControlStateNormal];
        [button setImage:[UIImage templateImageNamed:@"np_alert_text"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 14.0);
        
        [button setBackgroundColor:[UIColor projectorBlackColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor blackColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor planOutputSlateColor];
        [button addSubview:view];
        
        [button addConstraint:[NSLayoutConstraint height:PCOKitMainScreenHairLine(1.0) forView:view]];
        [button addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeTop | UIRectEdgeLeft | UIRectEdgeRight]];
        
        _alertButton = button;
        [self addSubview:button];
    }
    return _alertButton;
}
- (PROLogoPickerView *)logoView {
    if (!_logoView) {
        PROLogoPickerView *button = [PROLogoPickerView newAutoLayoutView];
        
        [button setBackgroundColor:self.backgroundColor forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor projectorBlackColor] forState:UIControlStateHighlighted];
        
        _logoView = button;
        [self addSubview:button];
    }
    return _logoView;
}

- (BlackScreenButton *)blackScreenButton {
    if (!_blackScreenButton) {
        BlackScreenButton *button = [BlackScreenButton newAutoLayoutView];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        [button setTitleColor:[UIColor modalTextLabelTextColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"Black Screen", nil) forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [button setBackgroundColor:self.backgroundColor forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor projectorBlackColor] forState:UIControlStateHighlighted];
        
        _blackScreenButton = button;
        [self addSubview:button];
    }
    return _blackScreenButton;
}

- (void)checkAlertActive {
    if ([[PRODisplayController sharedController] isAnAlertActive]) {
        self.alertButton.tintColor = [UIColor projectorOrangeColor];
        [self.alertButton setTitleColor:[UIColor projectorOrangeColor] forState:UIControlStateNormal];
        [self.alertButton setTitle:NSLocalizedString(@"Dismiss Alert", nil) forState:UIControlStateNormal];
    } else {
        self.alertButton.tintColor = [UIColor whiteColor];
        [self.alertButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.alertButton setTitle:NSLocalizedString(@"Create Alert", nil) forState:UIControlStateNormal];
    }
}

- (void)setLogoIsCurrent:(BOOL)logoIsCurrent {
    _logoIsCurrent = logoIsCurrent;
    [self updateState];
}
- (void)setLogoIsNext:(BOOL)logoIsNext {
    _logoIsNext = logoIsNext;
    [self updateState];
}
- (void)setBlackIsCurrent:(BOOL)blackIsCurrent {
    _blackIsCurrent = blackIsCurrent;
    [self updateState];
}
- (void)setBlackIsNext:(BOOL)blackIsNext {
    _blackIsNext = blackIsNext;
    [self updateState];
}

- (void)updateState {
    self.logoView.showPlayButton = NO;
    self.blackScreenButton.showPlayButton = NO;
    if (self.logoIsCurrent) {
        self.logoView.currentColor = [UIColor currentItemGreenColor];
    } else if (self.logoIsNext) {
        self.logoView.currentColor = [UIColor nextUpItemBlueColor];
        self.logoView.showPlayButton = YES;
    } else {
        self.logoView.currentColor = nil;
    }
    if (self.blackIsCurrent) {
        self.blackScreenButton.currentColor = [UIColor currentItemGreenColor];
    } else if (self.blackIsNext) {
        self.blackScreenButton.currentColor = [UIColor nextUpItemBlueColor];
        self.blackScreenButton.showPlayButton = YES;
    } else {
        self.blackScreenButton.currentColor = nil;
    }
}

@end
