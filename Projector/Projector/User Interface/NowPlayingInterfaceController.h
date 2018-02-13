//
//  NowPlayingInterfaceController.h
//  Projector
//
//  Created by Peter Fokos on 12/9/14.
//

#import <Foundation/Foundation.h>
#import "NowPlayingPlanOutputControlView.h"
#import "NowPlayingDisplayViewControlView.h"
#import "PROKeyboardInputHandler.h"
#import "ProjectorP2P_SessionManager.h"
#import "PROFullScreenCurrentViewController.h"

@class PRODisplayView;

@protocol NowPlayingInterfaceControllerDelegate <NSObject>

- (UIView *)nowPlayingControlViewContainerView;
- (PRODisplayView *)displayViewControlViewContainerView;
- (UIView *)nextContainerView;
- (UIView *)mainView;

- (void)playSlideAtIndex:(NSInteger)slideIndex withPlanItemIndex:(NSInteger)planItemIndex andScrubPosition:(float)scrubPosition shouldPause:(BOOL)shouldPause;
- (void)playPreviousSlide;
- (void)playNextSlide;
- (void)playBlackScreen;
- (void)playLogo;

- (void)showFullScreen;
- (NSString *)currentItemTitleText;
- (NSString *)previousItemTitleText;
- (NSString *)nextItemTitleText;

- (NSIndexPath *)currentIndexPath;
- (BOOL)shouldPresentLogoPicker;

@required

@end

@interface NowPlayingInterfaceController : NSObject <UIGestureRecognizerDelegate, PCOKeyboarInputHandlerDelegate, ProjectorP2P_SessionManagerDelegate, PROFullScreenCurrentViewControllerDelegate>

@property (nonatomic, assign) id<NowPlayingInterfaceControllerDelegate> delegate;

@property (nonatomic, weak) NowPlayingControlView *nowPlayingControlView;
@property (nonatomic, weak) NowPlayingDisplayViewControlView *displayViewControlView;

- (void)configureNowPlayingInterface;
- (void)configureNowPlayingDisplay;
- (void)configureNowPlayingTimeLabel;
- (void)configurePlayPauseButton;

- (void)executeShowLyrics;
- (void)executeClearLyrics;

@end
