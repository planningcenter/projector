//
//  NowPlayingPlanOutputControlView.m
//  Projector
//
//  Created by Peter Fokos on 9/26/14.
//

#import "NowPlayingPlanOutputControlView.h"

@implementation NowPlayingPlanOutputControlView

- (void)initializeDefaults {
    [super initializeDefaults];
    [self.playButton setImage:[UIImage imageNamed:@"min-screen-play-btn"] forState:UIControlStateNormal];
    [self.fullScreenToggleButton setImage:[UIImage imageNamed:@"full-screen-control"] forState:UIControlStateNormal];
}

#pragma mark - Layout
#pragma mark -

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    
    [self removeConstraints:self.constraints];
    
    [super updateConstraints];
    
    NSMutableArray *array = [NSMutableArray array];
    
    
    CGFloat sliderWidth = 200;
    
    NSDictionary *metrics = @{@"slider_width": @(sliderWidth),
                              @"button_size": @(40),
                              @"h_buffer": @(10),
                              @"v_buffer": @(10),
                              };
    
    NSDictionary *views = @{
                            @"play_button": self.playButton,
                            @"full_screen_toggle_button": self.fullScreenToggleButton,
                            @"slider": self.slider,
                            @"line_view": self.lineView,
                            };
    
    for (NSString *format in @[
                               
                               @"H:|-h_buffer-[play_button(==button_size)]",
                               @"V:[play_button(==button_size)]",
                               
                               @"H:[full_screen_toggle_button(==button_size)]-h_buffer-|",
                               @"V:[full_screen_toggle_button(==button_size)]",
                               
                               @"H:[slider(==slider_width)]",
                               @"V:|[slider]|",
                               
                               @"H:|[line_view]|",
                               @"V:[line_view(==1)]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    
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
                                                                  toItem:self.slider
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0];
    [array addObject:vCenter];

    vCenter = [NSLayoutConstraint constraintWithItem:self.fullScreenToggleButton
                                           attribute:NSLayoutAttributeCenterY
                                           relatedBy:NSLayoutRelationEqual
                                              toItem:self.slider
                                           attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                            constant:0.0];
    [array addObject:vCenter];

    [self addConstraints:array];
    [self updateConstraintsIfNeeded];
}

#pragma mark - Lazy loaders
#pragma mark -


- (PCOView *)lineView {
    if (!_lineView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor projectorOrangeColor];
        
        _lineView = view;
        [self addSubview:view];
    }
    return _lineView;
}

#pragma mark - Overriding methods
#pragma mark -


- (void)toggleAlpha {
    CGFloat newAlpha;
    if (self.alpha > 0.0) {
        newAlpha = 0.0;
    }
    else {
        newAlpha = 1.0;
    }
    [UIView animateWithDuration:ALPHA_ANIMATION_TIME animations:^{
        self.alpha = newAlpha;
    }];
}

- (void)configurePlayPauseButtonForVideoPlayState:(VideoPlayState)videoPlayState {
    
    switch (videoPlayState) {
        case VideoPlayStateNoVideo:
            self.playButton.hidden = YES;
            self.slider.hidden = YES;
            break;
            
        case VideoPlayStatePlay:
            self.playButton.hidden = NO;
            self.slider.hidden = NO;
            [self.playButton setImage:[UIImage imageNamed:@"min-screen-pause-btn"] forState:UIControlStateNormal];
            break;
            
        case VideoPlayStatePause:
            self.playButton.hidden = NO;
            self.slider.hidden = NO;
            [self.playButton setImage:[UIImage imageNamed:@"min-screen-play-btn"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

@end
