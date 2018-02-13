/*!
 * PlanOutputCurrentBottomBar.m
 *
 *
 * Created by Skylar Schipper on 4/16/14
 */

#import "PlanOutputCurrentBottomBar.h"
#import "PlanOutputViewController.h"

@interface PlanOutputCurrentBottomBar ()

@property (nonatomic, weak) PCOView *nameView;

@end

@implementation PlanOutputCurrentBottomBar

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 50.0);
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    self.tintColor = [UIColor planOutputCurrentBarTintColor];
    
    PCOKitLazyLoad(self.lineView);
    PCOKitLazyLoad(self.nameLabel);
    PCOKitLazyLoad(self.rightArrowButton);
    PCOKitLazyLoad(self.leftArrowButton);
    PCOKitLazyLoad(self.loopingIcon);
}

- (PCOView *)lineView {
    if (!_lineView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor projectorOrangeColor];
        
        _lineView = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
        [self addConstraint:[NSLayoutConstraint height:1.0 forView:view]];
    }
    return _lineView;
}

- (PCOButton *)rightArrowButton {
    if (!_rightArrowButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        [button setImage:[UIImage templateImageNamed:@"np_circle_r_arrow"] forState:UIControlStateNormal];
        
        [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        [button addTarget:self action:@selector(rightArrowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
   
        [self addSubview:button];
        _rightArrowButton = button;
        
        [self addConstraint:[NSLayoutConstraint centerVertical:button inView:self]];
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:PlanOutputViewControllerPadding edges:UIRectEdgeRight]];
    }
    return _rightArrowButton;
}
- (PCOButton *)leftArrowButton {
    if (!_leftArrowButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        [button setImage:[UIImage templateImageNamed:@"np_circle_l_arrow"] forState:UIControlStateNormal];
        
        [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [button setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

        [button addTarget:self action:@selector(leftArrowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        _leftArrowButton = button;
        
        [self addConstraint:[NSLayoutConstraint centerVertical:button inView:self]];
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:PlanOutputViewControllerPadding edges:UIRectEdgeLeft]];
    }
    return _leftArrowButton;
}
- (PCOView *)nameView {
    if (!_nameView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        
        _nameView = view;
        [self addSubview:view];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.leftArrowButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:PlanOutputViewControllerPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.rightArrowButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-PlanOutputViewControllerPadding]];
    }
    return _nameView;
}


- (PCOLabel *)nameLabel {
    if (!_nameLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.textColor = [UIColor projectorOrangeColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont defaultFontOfSize_16];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _nameLabel = label;
        [self.nameView addSubview:label];
        
        [self.nameView addConstraint:[NSLayoutConstraint centerVertical:label inView:self.nameView]];
        
        [self.nameView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.nameView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.loopingIcon.image.size.width+PlanOutputViewControllerPadding]];
        [self.nameView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.loopingIcon attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-PlanOutputViewControllerPadding]];
    }
    return _nameLabel;
}

- (UIImageView *)loopingIcon {
    if (!_loopingIcon) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        view.tintColor = [UIColor projectorOrangeColor];
        view.image = [UIImage templateImageNamed:@"looping_icon"];
        _loopingIcon = view;
        view.hidden = YES;
        [self.nameView addSubview:view];
        [self.nameView addConstraint:[NSLayoutConstraint centerVertical:view inView:self.nameView]];
        [self.nameView addConstraints:[NSLayoutConstraint size:view.image.size forView:view]];
        [self.nameView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.nameView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    }
    return _loopingIcon;
}

#pragma mark -
#pragma mark - Action Methods

- (void)leftArrowButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(playNextSlide)]) {
        [self.delegate playNextSlide];
    }
}

- (void)rightArrowButtonAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(playPreviousSlide)]) {
        [self.delegate playPreviousSlide];
    }
}

@end
