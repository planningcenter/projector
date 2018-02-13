//
//  NowPlayingDisplayViewControlView.h
//  Projector
//
//  Created by Peter Fokos on 9/29/14.
//

#import "NowPlayingControlView.h"

@interface NowPlayingDisplayViewControlView : NowPlayingControlView

@property (nonatomic, weak) UIView *shadeView;
@property (nonatomic, weak) PCOButton *lyricsButton;

- (void)setLyricsButtonToShowHide:(BOOL)isHidden;

@end
