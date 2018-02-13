//
//  NowPlayingControlView.m
//  Projector
//
//  Created by Peter Fokos on 9/25/14.
//

#import "NowPlayingControlView.h"

@implementation NowPlayingControlView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    [self toggleAlpha];
}

- (PCOLabel *)timeLabel {
    if (!_timeLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor planOutputSlateColor];
        label.font = [UIFont defaultFontOfSize_16];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"00:00:00:00";
        label.clipsToBounds = YES;
        [self addSubview:label];
        _timeLabel = label;
    }
    return _timeLabel;
}

- (PCOButton *)playButton {
    if (!_playButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self addSubview:view];
        _playButton = view;
    }
    return _playButton;
}

- (PCOButton *)fullScreenToggleButton {
    if (!_fullScreenToggleButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self addSubview:view];
        _fullScreenToggleButton = view;
    }
    return _fullScreenToggleButton;
}

- (UISlider *)slider {
    if (!_slider) {
        UISlider *slider = [UISlider newAutoLayoutView];
        slider.backgroundColor = [UIColor clearColor];
        [slider setThumbImage:[UIImage imageNamed:@"min-screen-scrubber"] forState:UIControlStateNormal];
        [slider setMinimumTrackTintColor:RGB(255, 160, 55)];
        [slider setMaximumTrackTintColor:RGB(255, 255, 255)];
        [self addSubview:slider];
        _slider = slider;
    }
    return _slider;
}

- (void)configurePlayPauseButtonForVideoPlayState:(VideoPlayState)videoPlayState {
    
}

- (void)toggleAlpha {
    
}

@end
