/*!
 * LeftSidebarFooterView.m
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#import "LeftSidebarFooterView.h"

#import <MCTImageKit/MCTImageKit.h>

static CGFloat const LeftSidebarFooterViewPadding = 8.0;

@interface LeftSidebarFooterView ()

@end

@implementation LeftSidebarFooterView

- (void)initializeDefaults {
    [super initializeDefaults];

    self.backgroundColor = HEX(0x242426);
}

- (PCOButton *)logoutButton {
    if (!_logoutButton) {
        PCOButton *btn = [PCOButton newAutoLayoutView];
        btn.titleLabel.font = [UIFont defaultFontOfSize_16];
        [btn setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
        
        [btn setBackgroundColor:HEX(0x38383c) forState:UIControlStateNormal];
        [btn setBackgroundColor:HEX(0x28282c) forState:UIControlStateHighlighted];
        
        [btn setTitleColor:[UIColor sidebarTextColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [btn setImage:[UIImage imageNamed:@"lock-icon"] forState:UIControlStateNormal];
        
        btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 22.0);
        btn.layer.cornerRadius = 4.0;
        btn.layer.borderColor = [HEX(0x181819) CGColor];
        btn.layer.borderWidth = PCOKitMainScreenHairLine(1.0);
        
        _logoutButton = btn;
        [self addSubview:btn];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:btn offset:LeftSidebarFooterViewPadding edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
        [self addConstraint:[NSLayoutConstraint height:30.0 forView:btn]];
    }
    return _logoutButton;
}
- (PCOButton *)helpButton {
    if (!_helpButton) {
        PCOButton *btn = [PCOButton newAutoLayoutView];
        btn.titleLabel.font = [UIFont defaultFontOfSize_16];
        [btn setTitle:NSLocalizedString(@"Help", nil) forState:UIControlStateNormal];
        
        [btn setBackgroundColor:HEX(0x38383c) forState:UIControlStateNormal];
        [btn setBackgroundColor:HEX(0x28282c) forState:UIControlStateHighlighted];
        
        [btn setTitleColor:[UIColor sidebarTextColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [btn setImage:[UIImage imageNamed:@"question-icon"] forState:UIControlStateNormal];
        
        btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 22.0);
        btn.layer.cornerRadius = 4.0;
        btn.layer.borderColor = [HEX(0x181819) CGColor];
        btn.layer.borderWidth = PCOKitMainScreenHairLine(1.0);
        
        _helpButton = btn;
        [self addSubview:btn];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:btn offset:LeftSidebarFooterViewPadding edges:UIRectEdgeLeft | UIRectEdgeTop]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoutButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:btn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:LeftSidebarFooterViewPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-(PCOKitHalf(LeftSidebarFooterViewPadding))]];
    }
    return _helpButton;
}
- (PCOButton *)settingsButton {
    if (!_settingsButton) {
        PCOButton *btn = [PCOButton newAutoLayoutView];
        btn.titleLabel.font = [UIFont defaultFontOfSize_16];
        [btn setTitle:NSLocalizedString(@"Settings", nil) forState:UIControlStateNormal];
        
        [btn setBackgroundColor:HEX(0x38383c) forState:UIControlStateNormal];
        [btn setBackgroundColor:HEX(0x28282c) forState:UIControlStateHighlighted];
        
        [btn setTitleColor:[UIColor sidebarTextColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        [btn setImage:[UIImage imageNamed:@"sidebar-settings-icon"] forState:UIControlStateNormal];
        
        btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 22.0);
        btn.layer.cornerRadius = 4.0;
        btn.layer.borderColor = [HEX(0x181819) CGColor];
        btn.layer.borderWidth = PCOKitMainScreenHairLine(1.0);
        
        _settingsButton = btn;
        [self addSubview:btn];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:btn offset:LeftSidebarFooterViewPadding edges:UIRectEdgeRight | UIRectEdgeTop]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.logoutButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:btn attribute:NSLayoutAttributeBottom multiplier:1.0 constant:LeftSidebarFooterViewPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:(PCOKitHalf(LeftSidebarFooterViewPadding))]];
    }
    return _settingsButton;
}

#pragma mark -
#pragma mark - Layout
- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 94.0);
}

@end
