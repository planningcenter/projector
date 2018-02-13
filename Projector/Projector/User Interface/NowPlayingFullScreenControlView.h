//
//  NowPlayingFullScreenControlView.h
//  Projector
//
//  Created by Peter Fokos on 9/26/14.
//

#import "NowPlayingControlView.h"

@interface NowPlayingFullScreenControlView : NowPlayingControlView

@property (nonatomic, weak) PCOLabel *titleLabel;
@property (nonatomic, weak) PCOLabel *nextLabel;
@property (nonatomic, weak) PCOLabel *previousLabel;
@property (nonatomic, weak) PCOButton *nextButton;
@property (nonatomic, weak) PCOButton *previousButton;
@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *displayView;
@property (nonatomic, weak) UIView *bottomView;

@end
