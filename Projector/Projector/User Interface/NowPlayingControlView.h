//
//  NowPlayingControlView.h
//  Projector
//
//  Created by Peter Fokos on 9/25/14.
//

#import <UIKit/UIKit.h>
#import "PCOSlider.h"
#import "PRODisplayController.h"

#define ALPHA_ANIMATION_TIME 0.25

@interface NowPlayingControlView : PCOView

@property (nonatomic, weak) UISlider *slider;
@property (nonatomic, weak) PCOButton *playButton;
@property (nonatomic, weak) PCOButton *fullScreenToggleButton;
@property (nonatomic, weak) PCOLabel *timeLabel;

- (void)toggleAlpha;
- (void)configurePlayPauseButtonForVideoPlayState:(VideoPlayState)videoPlayState;

@end
