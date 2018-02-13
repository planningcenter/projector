//
//  NowPlayingFullScreenControlView.m
//  Projector
//
//  Created by Peter Fokos on 9/26/14.
//

#define NAV_BUTTON_WIDTH 200
#define NAV_BUTTON_HEIGHT 40
#define BUTTON_LABEL_X_OFFSET 50

#import "NowPlayingFullScreenControlView.h"


@interface _NowPlayingFullScreenControlViewTopView : UIView

@end

@implementation NowPlayingFullScreenControlView

- (void)initializeDefaults {
    [super initializeDefaults];
    self.backgroundColor = RGB(28, 28, 33);
    [self.bottomView addSubview:self.slider];
    [self.bottomView addSubview:self.playButton];
    [self.bottomView addSubview:self.fullScreenToggleButton];
    [self.bottomView addSubview:self.timeLabel];
    [self.slider setThumbImage:[UIImage imageNamed:@"full-screen-scrubber"] forState:UIControlStateNormal];
    self.timeLabel.font = [UIFont defaultFontOfSize:36];
    [self.playButton setImage:[UIImage imageNamed:@"full-screen-play-btn"] forState:UIControlStateNormal];
    [self.fullScreenToggleButton setImage:[UIImage imageNamed:@"min-screen"] forState:UIControlStateNormal];
}

#pragma mark - Layout
#pragma mark -

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    
    [self.topView removeConstraints:self.topView.constraints];
    [self.bottomView removeConstraints:self.bottomView.constraints];
    [self removeConstraints:self.constraints];
    
    [super updateConstraints];
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{};
    
    NSDictionary *views = @{
                            @"top_view": self.topView,
                            @"displayView": self.displayView,
                            @"bottom_view": self.bottomView,
                            };
    
    if ([[PROAppDelegate delegate] isPad]) {
        for (NSString *format in @[
                                   @"H:|[top_view]|",
                                   @"H:|[displayView]|",
                                   @"H:|[bottom_view]|",
                                   
                                   @"V:|[top_view(==96)][displayView][bottom_view(==96)]|",
                                   ]) {
            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
            [array addObjectsFromArray:constraints];
        }
    }
    else {
        for (NSString *format in @[
                                   @"H:|[top_view]|",
                                   @"H:|[displayView]|",
                                   @"H:|[bottom_view]|",
                                   
                                   @"V:|[top_view(==60)]",
                                   @"V:|[displayView]|",
                                   @"V:[bottom_view(==60)]|",
                                   ]) {
            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
            [array addObjectsFromArray:constraints];
        }
    }
    

    [self addConstraints:array];
    [self updateConstraintsIfNeeded];
    [self updateTopViewConstraints];
    [self updateBottomViewConstraints];
    
}

- (void)updateTopViewConstraints {
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{@"h_buffer": @(10),
                              @"v_buffer": @(10),
                              @"button_width": @(NAV_BUTTON_WIDTH),
                              @"button_height": @(NAV_BUTTON_HEIGHT),
                              @"button_label_x_offset": @(BUTTON_LABEL_X_OFFSET),
                              };
    
    NSDictionary *views = @{
                            @"title_label": self.titleLabel,
                            @"next_label": self.nextLabel,
                            @"previous_label": self.previousLabel,
                            @"next_button": self.nextButton,
                            @"previous_button": self.previousButton,
                            };
    
    for (NSString *format in @[
                               @"H:|-h_buffer-[previous_button(==button_width)]",
                               @"V:[previous_button(==button_height)]",
                               
                               @"H:|-button_label_x_offset-[previous_label]",
                               @"V:[previous_label(==button_height)]",
                               
                               @"H:|[title_label]|",
                               @"V:|[title_label]|",
                               
                               @"H:[next_button(==button_width)]-h_buffer-|",
                               @"V:[next_button(==button_height)]",
                               
                               @"H:[next_label]-button_label_x_offset-|",
                               @"V:[next_label(==button_height)]",
                               
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    NSLayoutConstraint *vCenter = [NSLayoutConstraint constraintWithItem:self.previousButton
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.titleLabel
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0];
    [array addObject:vCenter];
    
    vCenter = [NSLayoutConstraint constraintWithItem:self.previousLabel
                                           attribute:NSLayoutAttributeCenterY
                                           relatedBy:NSLayoutRelationEqual
                                              toItem:self.titleLabel
                                           attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                            constant:0.0];
    [array addObject:vCenter];
    
    vCenter = [NSLayoutConstraint constraintWithItem:self.nextButton
                                           attribute:NSLayoutAttributeCenterY
                                           relatedBy:NSLayoutRelationEqual
                                              toItem:self.titleLabel
                                           attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                            constant:0.0];
    [array addObject:vCenter];
    
    vCenter = [NSLayoutConstraint constraintWithItem:self.nextLabel
                                           attribute:NSLayoutAttributeCenterY
                                           relatedBy:NSLayoutRelationEqual
                                              toItem:self.titleLabel
                                           attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                            constant:0.0];
    [array addObject:vCenter];
    
    [self addConstraints:array];
    [self updateConstraintsIfNeeded];

}

- (void)updateDisplayViewConstraints {
    
}


- (void)updateBottomViewConstraints {
    NSMutableArray *array = [NSMutableArray array];
    
    
    NSDictionary *metrics = @{
                              @"h_buffer": @(10),
                              @"v_buffer": @(10),
                              @"slider_y": @(-16),
                              @"button_height": @(NAV_BUTTON_HEIGHT),
                              };
    
    NSDictionary *views = @{
                            @"time_label": self.timeLabel,
                            @"play_button": self.playButton,
                            @"full_screen_toggle_button": self.fullScreenToggleButton,
                            @"slider": self.slider,
                            };
    
    for (NSString *format in @[
                               @"H:[time_label(==230)]",
                               @"V:|[time_label]|",
                               
                               @"H:[full_screen_toggle_button(==button_height)]-h_buffer-|",
                               @"V:[full_screen_toggle_button(==button_height)]",
                               
                               @"H:|-h_buffer-[play_button(==button_height)]",
                               @"V:[play_button(==button_height)]",
                               
                               @"H:|[slider]|",
                               @"V:|-slider_y-[slider]",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    NSLayoutConstraint *hCenterTimeLabelConstraint = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self
                                                                                  attribute:NSLayoutAttributeCenterX
                                                                                 multiplier:1.0
                                                                                   constant:0.0];
    [array addObject:hCenterTimeLabelConstraint];
    
    NSLayoutConstraint *hCenterSliderConstraint = [NSLayoutConstraint constraintWithItem:self.slider
                                                                               attribute:NSLayoutAttributeCenterX
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self
                                                                               attribute:NSLayoutAttributeCenterX
                                                                              multiplier:1.0
                                                                                constant:0.0];
    [array addObject:hCenterSliderConstraint];
    
    
    NSLayoutConstraint *vCenter = [NSLayoutConstraint constraintWithItem:self.playButton
                                           attribute:NSLayoutAttributeCenterY
                                           relatedBy:NSLayoutRelationEqual
                                              toItem:self.timeLabel
                                           attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                            constant:0.0];
    [array addObject:vCenter];
    
    vCenter = [NSLayoutConstraint constraintWithItem:self.fullScreenToggleButton
                                           attribute:NSLayoutAttributeCenterY
                                           relatedBy:NSLayoutRelationEqual
                                              toItem:self.timeLabel
                                           attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                            constant:0.0];
    [array addObject:vCenter];
    
    [self addConstraints:array];
    [self updateConstraintsIfNeeded];
}

#pragma mark -
#pragma mark - Overriding methods

- (void)configurePlayPauseButtonForVideoPlayState:(VideoPlayState)videoPlayState {
    
    switch (videoPlayState) {
        case VideoPlayStateNoVideo:
            self.playButton.hidden = YES;
            self.slider.hidden = YES;
            break;
            
        case VideoPlayStatePlay:
            self.playButton.hidden = NO;
            self.slider.hidden = NO;
            [self.playButton setImage:[UIImage imageNamed:@"full-screen-pause-btn"] forState:UIControlStateNormal];
            break;
            
        case VideoPlayStatePause:
            self.playButton.hidden = NO;
            self.slider.hidden = NO;
            [self.playButton setImage:[UIImage imageNamed:@"full-screen-play-btn"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOLabel *)titleLabel {
    if (!_titleLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor sidebarTextColor];
        label.font = [UIFont defaultFontOfSize:36];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"title label", nil);
        _titleLabel = label;
        [self.topView addSubview:label];
    }
    return _titleLabel;
}

- (PCOLabel *)nextLabel {
    if (!_nextLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor planOutputSlateColor];
        label.font = [UIFont defaultFontOfSize_18];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = NSLocalizedString(@"Next label", nil);
        _nextLabel = label;
        [self.topView addSubview:label];
    }
    return _nextLabel;
}

- (PCOLabel *)previousLabel {
    if (!_previousLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor planOutputSlateColor];
        label.font = [UIFont defaultFontOfSize_18];
        label.textAlignment = NSTextAlignmentRight;
        label.text = NSLocalizedString(@"Previous label", nil);
        _previousLabel = label;
        [self.topView addSubview:label];
    }
    return _previousLabel;
}

- (PCOButton *)nextButton {
    if (!_nextButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"full-screen-arrow-right"] forState:UIControlStateNormal];
        view.titleLabel.textAlignment = NSTextAlignmentRight;
        view.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -(NAV_BUTTON_WIDTH *0.8));
        
        _nextButton = view;
        [self.topView addSubview:view];
    }
    return _nextButton;
}

- (PCOButton *)previousButton {
    if (!_previousButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"full-screen-arrow-left"] forState:UIControlStateNormal];
        view.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, (NAV_BUTTON_WIDTH *0.8));

        _previousButton = view;
        [self.topView addSubview:view];
    }
    return _previousButton;
}

- (UIView*)topView {
    if (!_topView) {
        UIView *view = [_NowPlayingFullScreenControlViewTopView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        _topView = view;
        [self addSubview:view];
    }
    return _topView;
}

- (UIView*)displayView {
    if (!_displayView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        _displayView = view;
        [self addSubview:view];
        [self sendSubviewToBack:view];
    }
    return _displayView;
}

- (UIView*)bottomView {
    if (!_bottomView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        _bottomView = view;
        [self addSubview:view];
    }
    return _bottomView;
}

@end

@implementation _NowPlayingFullScreenControlViewTopView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIControl class]]) {
            if (CGRectContainsPoint(subview.frame, point)) {
                return subview;
            }
        }
    }
    return nil;
}

@end
