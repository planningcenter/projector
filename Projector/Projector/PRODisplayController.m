/*!
 * PRODisplayController.m
 *
 *
 * Created by Skylar Schipper on 5/6/14
 */

@import AVFoundation;

#import "PRODisplayController.h"
#import "OSDCrypto.h"
#import "LoopingPlaylistManager.h"
#import "ProjectorP2P_SessionManager.h"
#import "NSString+FileTypeAdditions.h"
#import "PRORecordingController.h"
#import "PROSlideManager.h"
#import "PCOCustomSlide.h"
#import "PCOAttachment+ProjectorAdditions.h"
#import "PCOPlanItemMedia.h"
#import "PCOMedia.h"
#import "PROLogoDisplayItem.h"
#import "PROBlackItem.h"

id static _sharedPRODisplayController = nil;

#define NSEC_PER_SEC 1000000000ull

@interface PRODisplayController ()

@property (nonatomic, strong) NSHashTable *viewHash;
@property (nonatomic, weak, readwrite) PRODisplayView *liveView;

@property (nonatomic, strong) NSString *currentBackgroundHash;

@end

@implementation PRODisplayController

- (void)refreshAllViews {
    [self updateLiveView];
}

#pragma mark -
#pragma mark -
- (NSHashTable *)viewHash {
    if (!_viewHash) {
        _viewHash = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:4];
    }
    return _viewHash;
}
- (NSArray *)allViews {
    return [self.viewHash allObjects];
}
- (void)registerView:(PRODisplayView *)view {
    view.hideLyrics = !self.displayLyricsOn;
    [self.viewHash addObject:view];
    [self updateLiveView];
}
- (void)removeView:(PRODisplayView *)view {
    [self.viewHash removeObject:view];
    [self updateLiveView];
}

- (void)updateLiveView {
    PRODisplayView *view = self.liveView;
    _liveView = nil;
    
    AVPlayer *player = [view backgroundPlayer];
    
    if (self.liveView != view && self.liveView.item == nil) {
        [self.liveView setItem:view.item];
        if (self.liveView.priority > view.priority) {
            [view setBackgroundPlayer:nil];
            [view displayBackground:view.item.background];
            [self.liveView displayBackground:view.item.background];
        }
    }
    
    if (self.liveView != view) {
        [view removeVideoPlayerTimeObserver];
        view.playerLayer.player = nil;
        if ([self.liveView backgroundPlayer] != player) {
            [self.liveView setBackgroundPlayer:player];
        }
    }
    
    
    for (UIView *_v in [self allViews]) {
        [_v setNeedsDisplay];
    }
}
- (PRODisplayView *)liveView {
    if (!_liveView) {
        _liveView = [[[self allViews] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO]]] firstObject];
    }
    return _liveView;
}

#pragma mark -
#pragma mark - Singleton
+ (instancetype)sharedController {
	@synchronized (self) {
        if (!_sharedPRODisplayController) {
            _sharedPRODisplayController = [[[self class] alloc] init];
            [_sharedPRODisplayController setDisplayLyricsOn:YES];
        }
        return _sharedPRODisplayController;
    }
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)returnFromBackground {
    if ([self displayHasVideo]) {
        if ([self displayVideoIsPaused]) {
            [self displayVideoPlay];
        }
    }
}

#pragma mark -
#pragma mark - Helpers

- (VideoPlayState)currentSlideVideoPlayState {
    if (![self displayHasVideo]) {
        return VideoPlayStateNoVideo;
    }
    if ([self displayVideoPlaying]) {
        return VideoPlayStatePlay;
    }
    return VideoPlayStatePause;
}

- (CGSize)sizeOfCurrentItem {
    return self.liveView.frame.size;
}

- (UIImage *)imageOfCurrentItem {
    CGFloat borderWidth = self.liveView.layer.borderWidth;
    BOOL controlViewHidden = self.liveView.controlsView.hidden;
    BOOL recLabelHidden = self.liveView.recLabel.hidden;
    self.liveView.recLabel.hidden = YES;
    self.liveView.layer.borderWidth = 0.0;
    self.liveView.controlsView.hidden = YES;
    if (self.liveView.showActionButtons) {
        self.liveView.actionAlertButton.hidden = YES;
        self.liveView.actionBlackButton.hidden = YES;
        self.liveView.actionLogoButton.hidden = YES;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.liveView.frame.size, YES, 1.0);
    [self.liveView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (self.liveView.showActionButtons) {
        self.liveView.actionAlertButton.hidden = NO;
        self.liveView.actionBlackButton.hidden = NO;
        self.liveView.actionLogoButton.hidden = NO;
    }
    self.liveView.recLabel.hidden = recLabelHidden;
    self.liveView.layer.borderWidth = borderWidth;
    self.liveView.controlsView.hidden = controlViewHidden;
    
    return viewImage;
}


#pragma mark -
#pragma mark - Alert
- (void)displayAlert:(PROAlertView *)alertView {
    for (PRODisplayView *view in [self allViews]) {
        [view displayAlert:alertView];
    }
    NSDictionary *userInfo = nil;
    if (alertView) {
        userInfo = @{kPRODisplayControllerAlertView: alertView};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PRODisplayControllerDidSetAlertNotification object:self userInfo:userInfo];
}
- (BOOL)isAnAlertActive {
    for (PRODisplayView *view in [self allViews]) {
        if ([view isAlertActive]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark - Current Item
- (void)displayCurrentItem:(PRODisplayItem *)item {
    BOOL shouldHideLyrics = NO;
    if ([[ProjectorP2P_SessionManager sharedManager] currentClientMode] ==  P2PClientModeNoLyrics) {
        shouldHideLyrics = YES;
    }
    else {
        self.displayLyricsOn = YES;
    }
    [self displayItemBackground:item];
    for (PRODisplayView *view in [self allViews]) {
        if (![view isUpNext]) {
            if (view.hideLyrics != shouldHideLyrics) {
                view.hideLyrics = shouldHideLyrics;
            }
            view.item = item;
        }
    }
    [[PRORecordingController sharedController] currentItemDidChange:item];
}
- (void)displayUpNextItem:(PRODisplayItem *)item {
    [self displayUpNextItemBackground:item];
    for (PRODisplayView *view in [self allViews]) {
        if ([view isUpNext]) {
            view.hideLyrics = NO;
            view.item = item;
        }
    }
}

- (void)forceItemReload:(PRODisplayItem *)item {
    [self forceBackgroundRefresh];
    [self displayCurrentItem:item];
}

#pragma mark -
#pragma mark - Background
- (void)displayItemBackground:(PRODisplayItem *)item {
    PRODisplayItemBackground *background = item.background;
    NSInteger currentPlanItemIndex = item.indexPath.section;
    BOOL confidenceModeOn = [[ProjectorP2P_SessionManager sharedManager] useConfidenceModeAtPlanItemIndex:currentPlanItemIndex];
    if (!confidenceModeOn && self.currentBackgroundHash && [self.currentBackgroundHash isEqualToString:[background primaryURLHash]] && ![background shouldForceBackgroundRefresh]) {
        return;
    }
    [self clearBackground];
    if (!confidenceModeOn) {
        self.currentBackgroundHash = [background primaryURLHash];
    }
    else {
        _currentBackgroundHash = nil;
    }
    for (PRODisplayView *view in [self allViews]) {
        if (![view isUpNext] && !confidenceModeOn) {
            [view displayBackground:background];
            if (view == self.liveView) {
                [self displayVideoPlay];
            }
        }
    }
}
- (void)displayUpNextItemBackground:(PRODisplayItem *)item {
    PRODisplayItemBackground *background = item.background;
    NSInteger currentPlanItemIndex = item.indexPath.section;
    BOOL confidenceModeOn = [[ProjectorP2P_SessionManager sharedManager] useConfidenceModeAtPlanItemIndex:currentPlanItemIndex];
    for (PRODisplayView *view in [self allViews]) {
        if ([view isUpNext] && !confidenceModeOn) {
            [view displayBackground:background];
            if (view == self.liveView) {
                [self displayVideoPlay];
            }
        }
    }
}
- (void)clearBackground {
    for (PRODisplayView *view in [self allViews]) {
        [view clearBackground];
    }
}
- (void)forceBackgroundRefresh {
    _currentBackgroundHash = nil;
}

#pragma mark -
#pragma mark - Video Controls

- (BOOL)displayHasVideo {
    return [self.liveView videoExists];
}

- (BOOL)displayVideoPlaying {
    return [self.liveView videoPlaying];
}

- (BOOL)displayVideoIsPaused {
    return [self.liveView videoPaused];
}

- (CGFloat)displayVideoDurationInSeconds {
    return [self.liveView videoDurationInSeconds];
}

- (CGFloat)displayVideoPositionInSeconds {
    return [self.liveView videoPositionInSeconds];
}

- (CGFloat)displayVideoPositionZeroToOne {
    CGFloat ratio = [self displayVideoPositionInSeconds] / [self displayVideoDurationInSeconds];
    return ratio ;
}

- (NSString *)displayVideoDurationFormattedString {
    CGFloat videoLength = [self displayVideoDurationInSeconds];
    return [self formattedStringForTime:videoLength];
}

- (NSString *)displayVideoPostionFormattedString {
    return [self formattedStringForTime:[self displayVideoPositionInSeconds]];
}

- (NSString *)displayVideoTimeRemainingFormattedString {
    CGFloat position = [self displayVideoPositionInSeconds];
    CGFloat remaining = ([self displayVideoDurationInSeconds] - position);
    return [self formattedStringForTime:remaining];
}

- (NSString *)formattedStringForTime:(CGFloat)time {
    NSInteger hours = time / (60 * 60);
    time = fmodf(time, (60 * 60));
    NSInteger minutes = time / 60;
    time = fmodf(time, 60);
    NSInteger seconds = time;
    NSInteger hundreths = time * 100;
    if (seconds > 0) {
        hundreths = fmod(time, (double)seconds) * 100;
    }
    
    NSString *formattedString = [NSString stringWithFormat:@"%02td:%02td:%02td:%02td", hours, minutes, seconds, hundreths];
    return formattedString;
}

- (void)displayVideoPlay {
    [self.liveView videoPlay];
}

- (void)displayVideoPause {
    [self.liveView videoPause];
}

- (void)displayVideoPostionReset {
    [self displayVideoScrubToPositionInSeconds:0.0];
}

- (void)displayVideoScrubToPositionInSeconds:(CGFloat)seconds {
    [self.liveView videoSeekToTimeInSeconds:seconds];
    [[ProjectorP2P_SessionManager sharedManager] serverSendScrubVideo:seconds];
}

- (void)displayShowLyrics {
    self.displayLyricsOn = YES;
    for (PRODisplayView *view in [self allViews]) {
        [view setHideLyrics:NO];
    }
}

- (void)displayHideLyrics {
    self.displayLyricsOn = NO;
    for (PRODisplayView *view in [self allViews]) {
        [view setHideLyrics:YES];
    }
}

- (BOOL)shouldSlideBackgroundVideoLoop {
    if ([self.liveView.item isKindOfClass:[PROBlackItem class]]) {
        return NO;
    }
    else if ([self.liveView.item isKindOfClass:[PROLogoDisplayItem class]]) {
        return YES;
    }

    PCOPlan *plan = [[PROSlideManager sharedManager] plan];
    PCOItem *planItem = [[plan orderedItems] objectAtIndex:self.liveView.item.indexPath.section];
    
    if ([plan orderedItems].count > 0 && (NSInteger)[plan orderedItems].count > self.liveView.item.indexPath.section) {
        NSArray *customSlides = [planItem orderedCustomSlides];
        PROSlide *slide = [[PROSlideManager sharedManager] slideForIndexPath:self.liveView.item.indexPath];
        NSInteger orderPosition = slide.orderPosition;
        if ([customSlides count] > 0) {
            PCOCustomSlide *slide = [[customSlides filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"order == %@",@(orderPosition)]] lastObject];
            if (slide.backgroundAttachmentId) {
                NSNumber *linkedObjectId = slide.selectedBackgroundAttachment.linkedObjectId;
                if (linkedObjectId) {
                    PCOPlanItemMedia *media = [[[planItem orderedPlanItemMedias] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"media.remoteId == %@", linkedObjectId]] lastObject];
                    if (media && ([media.media.type isEqualToString:@"Video"] || [media.media.type isEqualToString:@"Countdown"])) {
                        _currentBackgroundHash = nil;
                        return NO;
                    }
                    return YES;
                }
                
            }
            else {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)videoFinishedShouldItLoop {
    if ([[LoopingPlaylistManager sharedPlaylistManager] isCurrentItemLooping]) {
        if ([[LoopingPlaylistManager sharedPlaylistManager] doesCurrentItemHaveCustomSlides]) {
            BOOL result = [self shouldSlideBackgroundVideoLoop];
            [[LoopingPlaylistManager sharedPlaylistManager] forceStartNextSlide];
            return result;
        }
        return YES;
    }
    return [self shouldSlideBackgroundVideoLoop];
}

@end

_PCO_EXTERN_STRING PRODisplayControllerDidSetAlertNotification = @"PRODisplayControllerDidSetAlertNotification";
_PCO_EXTERN_STRING kPRODisplayControllerAlertView = @"alertView";
