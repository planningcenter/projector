/*!
 * PlanViewMobileInfoView.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/3/14
 */

#import "PlanViewMobileInfoView.h"

@interface PlanViewMobileInfoView ()

@end

@implementation PlanViewMobileInfoView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    UIView *stroke = [UIView newAutoLayoutView];
    stroke.backgroundColor = [UIColor blackColor];
    
    [self addSubview:stroke];
    [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:stroke offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
    [self addConstraint:[NSLayoutConstraint height:1.0 forView:stroke]];
    
    self.textLabel.text = NSLocalizedString(@"Currently Playing", nil);
    
    PCOKitLazyLoad(self.leftButton);
    PCOKitLazyLoad(self.rightButton);
    PCOKitLazyLoad(self.loopingIcon);
}

- (PCOLabel *)textLabel {
    if (!_textLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.textColor = [UIColor projectorOrangeColor];
        label.font = [UIFont defaultFontOfSize_14];
        
        _textLabel = label;
        [self addSubview:label];
        
        [self addConstraints:[NSLayoutConstraint center:label inView:self]];
    }
    return _textLabel;
}

- (PCOButton *)leftButton {
    if (!_leftButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.minimumIntrinsicContentSize = CGSizeMake(40.0, 34.0);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setImage:[UIImage templateImageNamed:@"full-screen-arrow-left"] forState:UIControlStateNormal];
        button.tintColor = HEX(0x37373E);
        
        _leftButton = button;
        [self addSubview:button];
        
        [self addConstraint:[NSLayoutConstraint centerVertical:button inView:self]];
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:8.0 edges:UIRectEdgeLeft]];
    }
    return _leftButton;
}
- (PCOButton *)rightButton {
    if (!_rightButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.minimumIntrinsicContentSize = CGSizeMake(40.0, 34.0);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [button setImage:[UIImage templateImageNamed:@"full-screen-arrow-right"] forState:UIControlStateNormal];
        button.tintColor = HEX(0x37373E);
        
        _rightButton = button;
        [self addSubview:button];
        
        [self addConstraint:[NSLayoutConstraint centerVertical:button inView:self]];
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:8.0 edges:UIRectEdgeRight]];
    }
    return _rightButton;
}

- (UIImageView *)loopingIcon {
    if (!_loopingIcon) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        view.tintColor = [UIColor projectorOrangeColor];
        view.image = [UIImage templateImageNamed:@"looping_icon"];
        _loopingIcon = view;
        view.hidden = YES;
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint centerVertical:view inView:self]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0]];
    }
    return _loopingIcon;
}

@end
