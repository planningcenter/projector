/*!
 * PRODisplayController.h
 *
 *
 * Created by Skylar Schipper on 5/6/14
 */

#ifndef PRODisplayController_h
#define PRODisplayController_h

#import "PRODisplayView.h"

typedef NS_ENUM(NSUInteger, VideoPlayState) {
    VideoPlayStateNoVideo          = 0,
    VideoPlayStatePlay             = 1,
    VideoPlayStatePause            = 2,
};

@interface PRODisplayController : NSObject

+ (instancetype)sharedController;

- (void)refreshAllViews;

- (NSArray *)allViews;
- (void)registerView:(PRODisplayView *)view;
- (void)removeView:(PRODisplayView *)view;

@property (nonatomic, weak, readonly) PRODisplayView *liveView;
@property (nonatomic) BOOL displayLyricsOn;

#pragma mark -
#pragma mark - Alert
- (void)displayAlert:(PROAlertView *)alertView;
- (BOOL)isAnAlertActive;

- (void)displayCurrentItem:(PRODisplayItem *)item;
- (void)displayUpNextItem:(PRODisplayItem *)item;
- (void)forceItemReload:(PRODisplayItem *)item;

- (void)clearBackground;

- (BOOL)displayHasVideo;
- (BOOL)displayVideoPlaying;
- (BOOL)displayVideoIsPaused;

- (CGFloat)displayVideoDurationInSeconds;
- (CGFloat)displayVideoPositionInSeconds;
- (CGFloat)displayVideoPositionZeroToOne;

- (NSString *)displayVideoDurationFormattedString;
- (NSString *)displayVideoPostionFormattedString;
- (NSString *)displayVideoTimeRemainingFormattedString;

- (void)displayVideoPlay;
- (void)displayVideoPause;

- (void)displayVideoPostionReset;
- (void)displayVideoScrubToPositionInSeconds:(CGFloat)seconds;

- (void)displayShowLyrics;
- (void)displayHideLyrics;

- (BOOL)videoFinishedShouldItLoop;

- (VideoPlayState)currentSlideVideoPlayState;

- (CGSize)sizeOfCurrentItem;
- (UIImage *)imageOfCurrentItem;

@end

PCO_EXTERN_STRING PRODisplayControllerDidSetAlertNotification;

PCO_EXTERN_STRING kPRODisplayControllerAlertView;

#endif
