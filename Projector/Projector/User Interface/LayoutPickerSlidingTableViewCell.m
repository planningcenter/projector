/*!
 * LayoutPickerSlidingTableViewCell.m
 *
 *
 * Created by Skylar Schipper on 5/14/14
 */

#import "LayoutPickerSlidingTableViewCell.h"

#import "PROSidebarDetailsCell.h"

#import "PROAppDelegate.h"

#import "PROSlideTextLabel.h"
#import "PROSlideLayout.h"
#import "PCOSlideLayout.h"

static CGFloat const LayoutPickerSlidingOffset = 60.0;

@interface LayoutPickerSlidingTableViewCell () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) PCOView *slidingView;

@property (nonatomic, weak) PCOButton *applyButton;
@property (nonatomic, weak) PCOButton *editButton;
@property (nonatomic, weak) PCOButton *deleteButton;

@property (nonatomic, weak) NSLayoutConstraint *centerConstraint;

@property (nonatomic, weak) NSLayoutConstraint *editWidthConstraint;
@property (nonatomic, weak) NSLayoutConstraint *deleteWidthConstraint;
@property (nonatomic, weak) PCOView *layoutPreview;
@property (nonatomic, weak) PROSlideTextLabel *layoutTextLabel;

@end

@implementation LayoutPickerSlidingTableViewCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [PROSidebarDetailsCell configureCell:self];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.applyButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:LayoutPickerSlidingOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.editButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.applyButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:1.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.editButton
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:1.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    NSLayoutConstraint *eWidth = [NSLayoutConstraint constraintWithItem:self.editButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:50.0];
    eWidth.priority = UILayoutPriorityDefaultHigh;
    
    NSLayoutConstraint *dWidth = [NSLayoutConstraint constraintWithItem:self.deleteButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:50.0];
    
    self.deleteWidthConstraint = dWidth;
    self.editWidthConstraint = eWidth;
    
    [self addConstraint:eWidth];
    [self addConstraint:dWidth];
    
    UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_slidingPannerAction:)];
    panner.delegate = self;
    [self.slidingView addGestureRecognizer:panner];
    
    self.enabled = YES;
    
    [self hideButtonsAnimated:NO completion:nil];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self hideButtonsAnimated:NO completion:nil];
    
    [_layoutTextLabel removeFromSuperview];
    _layoutTextLabel = nil;
    
    _applyButton.hidden = NO;
    _editButton.hidden = NO;
    _deleteButton.hidden = NO;
}

- (void)prepareForDismiss {
    _applyButton.hidden = YES;
    _editButton.hidden = YES;
    _deleteButton.hidden = YES;
}

- (BOOL)isOpened {
    return (self.centerConstraint.constant != 0.0);
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    CGFloat width = LayoutPickerSlidingOffset + 14.0;
    
    self.editWidthConstraint.constant = width;
    
    if (enabled) {
        [self.editButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
        self.deleteWidthConstraint.constant = width;
    } else {
        [self.editButton setTitle:NSLocalizedString(@"Copy & Edit", nil) forState:UIControlStateNormal];
        self.deleteWidthConstraint.constant = 0.0;
    }
    
    
    [self setNeedsLayout];
}

- (void)setLayout:(PCOSlideLayout *)layout {
    _layout = layout;
    
    self.layoutPreview.backgroundColor = layout.backgroundColor;
    welf();
    self.layoutTextLabel.boundsChangedHandler = ^(PROSlideTextLabel *label, CGRect bounds) {
        PROSlideLayout *slideLayout = [[PROSlideLayout alloc] initWithLayout:welf.layout.lyricTextLayout];
        label.maxNumberOfLines = [welf.layout.lyricTextLayout.defaultLinesPerSlide integerValue];
        [slideLayout configureTextLabel:label];
    };
    
}

// MARK: - Lazy Loader
- (PCOButton *)applyButton {
    if (!_applyButton) {
        UIColor *color = pco_kit_RGB(38.0,92.0,152.0);
        
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        button.titleLabel.lineBreakMode = NSLineBreakByClipping;
        button.backgroundColor = color;
        [button setBackgroundColor:[color darkerColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(p_applyAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:NSLocalizedString(@"Apply", nil) forState:UIControlStateNormal];
        
        _applyButton = button;
        [self.contentView insertSubview:button atIndex:0];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
    }
    return _applyButton;
}
- (PCOButton *)editButton {
    if (!_editButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        button.titleLabel.lineBreakMode = NSLineBreakByClipping;
        button.backgroundColor = [UIColor sidebarRoundButtonsOffColor];
        [button setBackgroundColor:[[UIColor sidebarRoundButtonsOffColor] darkerColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(p_editAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        button.intrinsicContentSizeInsets = UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0);
        
        _editButton = button;
        [self.contentView insertSubview:button atIndex:0];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
    }
    return _editButton;
}
- (PCOButton *)deleteButton {
    if (!_deleteButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        button.titleLabel.lineBreakMode = NSLineBreakByClipping;
        button.backgroundColor = [UIColor projectorDeleteColor];
        [button setBackgroundColor:[[UIColor projectorDeleteColor] darkerColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(p_deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
        
        _deleteButton = button;
        [self.contentView insertSubview:button atIndex:0];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
    }
    return _deleteButton;
}
- (PCOView *)slidingView {
    if (!_slidingView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = HEX(0x201F23);
        
        _slidingView = view;
        [self.contentView addSubview:view];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0
                                                                       constant:0.0];
        self.centerConstraint = constraint;
        [self.contentView addConstraint:constraint];
    }
    return _slidingView;
}
- (PCOLabel *)titleLabel {
    if (!_titleLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        
        _titleLabel = label;
        [self.slidingView addSubview:label];
        
        [self.slidingView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.layoutPreview
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:self.layoutMargins.left]];
        [self.slidingView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.slidingView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:-self.layoutMargins.left]];
        [self.slidingView addConstraint:[NSLayoutConstraint centerVertical:label inView:self.slidingView]];
    }
    return _titleLabel;
}

- (PCOView *)layoutPreview {
    if (!_layoutPreview) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        view.clipsToBounds = YES;
        
        _layoutPreview = view;
        [self.slidingView addSubview:view];
        [self.slidingView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.slidingView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:self.separatorInset.left + self.layoutMargins.left]];
        [self.slidingView addConstraint:[NSLayoutConstraint centerVertical:view inView:self.slidingView]];
        [self.slidingView addConstraint:[NSLayoutConstraint width:72.0 forView:view]];
        [self.slidingView addConstraint:[NSLayoutConstraint height:41.0 forView:view]];
    }
    return _layoutPreview;
}

- (PROSlideTextLabel *)layoutTextLabel {
    if (!_layoutTextLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = NO;
        label.text = [PROSlideTextLabel sampleLyricText];
        
        _layoutTextLabel = label;
        [self.layoutPreview addSubview:label];
        [self.layoutPreview addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:0.0 edges:UIRectEdgeAll]];
    }
    return _layoutTextLabel;
}


// MARK: - Show/Hide
- (void)p_slidingPannerAction:(UIPanGestureRecognizer *)panner {
    CGPoint offset = [panner translationInView:self.contentView];
    [panner setTranslation:CGPointZero inView:self.contentView];
    
    switch (panner.state) {
        case UIGestureRecognizerStateChanged: {
            self.centerConstraint.constant += offset.x;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (self.centerConstraint.constant > -80.0) {
                [self hideButtonsAnimated:YES completion:nil];
            } else {
                [self showButtonsAnimated:YES completion:nil];
            }
            return;
            break;
        }
        case UIGestureRecognizerStateBegan: {
            if ([self.delegate respondsToSelector:@selector(slidingDidBegin:)]) {
                [self.delegate slidingDidBegin:self];
            }
            break;
        }
        default:
            break;
    }
    
    if (self.centerConstraint.constant > 0.0) {
        self.centerConstraint.constant = 0.0;
    }
    CGFloat xOffset = -(CGRectGetWidth(self.contentView.bounds) - LayoutPickerSlidingOffset);
    if (xOffset > self.centerConstraint.constant) {
        self.centerConstraint.constant = xOffset;
    }
    
    [self setNeedsLayout];
}
- (void)showButtonsAnimated:(BOOL)animated completion:(void(^)(void))completion {
    CGFloat xOffset = -(CGRectGetWidth(self.contentView.bounds) - LayoutPickerSlidingOffset);
    self.centerConstraint.constant = xOffset;
    
    void(^ani)(void) = ^ {
        [self layoutIfNeeded];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:ani completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        [UIView performWithoutAnimation:ani];
        if (completion) {
            completion();
        }
    }
}
- (void)hideButtonsAnimated:(BOOL)animated completion:(void(^)(void))completion {
    self.centerConstraint.constant = 0.0;
    
    void(^ani)(void) = ^ {
        [self layoutIfNeeded];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:ani completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        [UIView performWithoutAnimation:ani];
        if (completion) {
            completion();
        }
    }
}

// MARK: - Actions
- (void)p_editAction:(id)sender {
    [self.delegate editLayoutButtonAction:self];
}
- (void)p_deleteAction:(id)sender {
    [self.delegate deleteLayoutButtonAction:self];
}
- (void)p_applyAction:(id)sender {
    [self.delegate applyLayoutButtonAction:self];
}

// MARK: - Gesture Action
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && gestureRecognizer.view == self.slidingView) {
        UIPanGestureRecognizer *panner = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panner velocityInView:panner.view];
        if (self.centerConstraint.constant < 0.0) {
            return PCOKitPannerShouldPanForDirection(velocity, PCOViewEdgeRight);
        }
        return PCOKitPannerShouldPanForDirection(velocity, PCOViewEdgeLeft);
    }
    return YES;
}

@end
