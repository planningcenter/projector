//
//  NowPlayingDisplayViewControlView.m
//  Projector
//
//  Created by Peter Fokos on 9/29/14.
//

#define SHADE_VIEW_ALPHA 0.3

#import "NowPlayingDisplayViewControlView.h"

@implementation NowPlayingDisplayViewControlView

- (void)initializeDefaults {
    [super initializeDefaults];
    self.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self sendSubviewToBack:self.timeLabel];
    [self sendSubviewToBack:self.shadeView];
    [self bringSubviewToFront:self.lyricsButton];
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
                            @"time_label": self.timeLabel,
                            @"shade_view": self.shadeView,
                            @"lyrics_button": self.lyricsButton,
                            };
    
    for (NSString *format in @[
                                @"H:[time_label(==120)]|",
                                @"V:[time_label(==18)]",
                                
                                @"H:|[shade_view]|",
                                @"V:[shade_view(==30)]|",
                                
                                @"H:|-h_buffer-[lyrics_button(==100)]",
                                @"V:[lyrics_button(==button_size)]",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    
    NSLayoutConstraint *vCenter = [NSLayoutConstraint constraintWithItem:self.lyricsButton
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.shadeView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0];
    [array addObject:vCenter];

    vCenter = [NSLayoutConstraint constraintWithItem:self.timeLabel
                                           attribute:NSLayoutAttributeCenterY
                                           relatedBy:NSLayoutRelationEqual
                                              toItem:self.shadeView
                                           attribute:NSLayoutAttributeCenterY
                                          multiplier:1.0
                                            constant:0.0];
    [array addObject:vCenter];

    [self addConstraints:array];
    [self updateConstraintsIfNeeded];
}

- (UIView*)shadeView {
    if (!_shadeView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = SHADE_VIEW_ALPHA;
        _shadeView = view;
        [self addSubview:view];
    }
    return _shadeView;
}

- (PCOButton *)lyricsButton {
    if (!_lyricsButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        view.titleLabel.font = [UIFont defaultFontOfSize_12];
        [view setTitle:NSLocalizedString(@"Hide Lyrics", nil) forState:UIControlStateNormal];
        _lyricsButton = view;
        [self addSubview:view];
    }
    return _lyricsButton;
}

- (void)toggleAlpha {
    CGFloat newAlpha;
    if (self.timeLabel.alpha > 0.0) {
        newAlpha = 0.0;
    }
    else {
        newAlpha = 1.0;
    }
    [UIView animateWithDuration:ALPHA_ANIMATION_TIME animations:^{
        self.timeLabel.alpha = newAlpha;
        self.lyricsButton.alpha = newAlpha;
        self.shadeView.alpha = (newAlpha * SHADE_VIEW_ALPHA);
    }];
}

-(void)setLyricsButtonToShowHide:(BOOL)isHidden {
    if (isHidden) {
        [self.lyricsButton setTitle:NSLocalizedString(@"Show Lyrics", nil) forState:UIControlStateNormal];
    }
    else {
        [self.lyricsButton setTitle:NSLocalizedString(@"Hide Lyrics", nil) forState:UIControlStateNormal];
    }
}


@end
