/*!
 * PRODisplayView.h
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#ifndef PRODisplayView_h
#define PRODisplayView_h

@import UIKit;
@import AVFoundation;

#import "PCOView.h"
#import "PRODisplayItem.h"
#import "PROAlertView.h"
#import "PRODisplayViewActionButton.h"

typedef NS_ENUM(NSInteger, PRODisplayViewSlideAnimation) {
    PRODisplayViewAnimateNone          = -1,
    PRODisplayViewAnimateCrossFade     = 0,
};

static NSUInteger const PRODisplayViewPrioritySecondScreen   = 1000;
static NSUInteger const PRODisplayViewPriorityHighLiveScreen = 900;
static NSUInteger const PRODisplayViewPriorityLiveScreen     = 800;
static NSUInteger const PRODisplayViewPriorityScreen         = 500;
static NSUInteger const PRODisplayViewPriorityUpNext         = 100;

@interface PRODisplayView : PCOView

@property (nonatomic) PRODisplayViewSlideAnimation backgroundAnimation;

@property (nonatomic) NSUInteger priority;

@property (nonatomic, assign, getter = isStaticView) BOOL staticView;

@property (nonatomic) BOOL hideLyrics;

@property (nonatomic, weak) UIView *controlsView;

@property (nonatomic, strong) PRODisplayItem *item;
- (void)setItem:(PRODisplayItem *)item animated:(BOOL)animated;
- (void)setItem:(PRODisplayItem *)item animationType:(PRODisplayViewSlideAnimation)animationType;
- (void)setItem:(PRODisplayItem *)item animationType:(PRODisplayViewSlideAnimation)animationType completion:(void(^)(BOOL finished))completion;

+ (void)setDefaultAnimationDuration:(NSTimeInterval)defaultAnimationDuration;
+ (NSTimeInterval)defaultAnimationDuration;

@property (nonatomic, readonly) BOOL isPrimary;
@property (nonatomic, readonly) BOOL isUpNext;

- (void)displayBackground:(PRODisplayItemBackground *)background;
- (void)clearBackground;

#pragma mark -
#pragma mark - Alert
- (void)displayAlert:(PROAlertView *)alertView;
- (BOOL)isAlertActive;

- (AVPlayer *)backgroundPlayer;
- (void)setBackgroundPlayer:(AVPlayer *)player;

@property (nonatomic, weak, readonly) AVPlayerLayer *playerLayer;

- (void)videoPlay;
- (void)videoPause;
- (void)videoSeekToTimeInSeconds:(NSInteger)seconds;
- (BOOL)videoExists;
- (BOOL)videoPlaying;
- (BOOL)videoPaused;
- (CGFloat)videoDurationInSeconds;
- (CGFloat)videoPositionInSeconds;

// MARK: - Action Buttons
@property (nonatomic) BOOL showActionButtons;

@property (nonatomic) CGFloat actionButtonsTopOffset;

- (PRODisplayViewActionButton *)actionAlertButton;
- (PRODisplayViewActionButton *)actionLogoButton;
- (PRODisplayViewActionButton *)actionBlackButton;

@property (nonatomic, weak) UILabel *recLabel;
@property (nonatomic, weak) PCOButton *cameraButton;

- (void)removeVideoPlayerTimeObserver;

@end

PCO_EXTERN_STRING PRODisplayViewVideoPlaybackTimeDidChangeNotification;

#endif
