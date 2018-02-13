//
//  ProjectorP2P_SessionManager.h
//  Projector
//
//  Created by Peter Fokos on 6/17/14.
//

#import <Foundation/Foundation.h>
#import "P2P_SessionManager.h"
#import "PROPlanContainerViewController.h"

#define PROJECTOR_P2P_PRODUCT_NAME @"Projector"

typedef NS_ENUM(NSInteger, P2PCommand) {
    P2PCommandLoadThisPlan          = 111,
    P2PCommandServerAltPeerId       = 112,
    P2PCommandSessionClosing        = 113,
    P2PCommandRefreshPlan           = 114,
    
    P2PCommandPlayThisSlide         = 222,
    P2PCommandPlayLogo              = 223,
    P2PCommandPlayBlackScreen       = 224,
    P2PCommandPlayHideLyrics        = 225,
    P2PCommandPlayShowLyrics        = 226,
    
    P2PCommandPlayVideo             = 227,
    P2PCommandPauseVideo            = 228,
    P2PCommandStopVideo             = 229,
    P2PCommandScrubVideo            = 230,

    P2PCommandShowTextAlert         = 231,
    P2PCommandShowNumberAlert       = 232,
    P2PCommandHideAlert             = 233,

    P2PCommandServerPlanItemChanged = 333,
    P2PCommandClientPlanItemChanged = 334,
    P2PCommandGeneralLayoutCHanged  = 444,

    P2PCommandRequestPlay           = 555,

    P2PCommandLiveControlledByUserId        = 600,
    P2PCommandLiveClearControlledByUserId   = 601,
};


typedef NS_ENUM(NSInteger, P2PClientMode) {
    P2PClientModeNone           = 0,
    P2PClientModeMirror         = 1,
    P2PClientModeConfidence     = 2,
    P2PClientModeNoLyrics       = 3,
};

@protocol ProjectorP2P_SessionManagerDelegate <NSObject>

@optional

- (void)sessionClosing;

- (void)playSlideAtIndex:(NSInteger)slideIndex
       withPlanItemIndex:(NSInteger)planItemIndex
        andScrubPosition:(float)scrubPosition
             shouldPause:(BOOL)shouldPause;

- (void)playLogo;
- (void)playBlackScreen;
- (void)hideLyrics;
- (void)showLyrics;
- (void)showAlertText:(NSString *)alertText;
- (void)hideAlertText;
- (void)refreshPlan;
- (void)playVideo;
- (void)pauseVideo;
- (void)scrubVideo:(float)scrubPosition;
- (NSArray *)playStatus;

@end

@interface ProjectorP2P_SessionManager : P2P_SessionManager <PROContainerViewControllerEventListener>

@property (nonatomic) P2PClientMode clientMode;

- (void)addDelegate:(id<ProjectorP2P_SessionManagerDelegate>)delegate;
- (void)removeDelegate:(id<ProjectorP2P_SessionManagerDelegate>)delegate;

- (void)serverSendSessionClosing;
- (void)serverSendUseAltServerPeerId:(NSString *)peerId;
- (void)serverSendPlayLogo;
- (void)serverSendPlayBlackScreen;
- (void)serverSendPlanItemChanged:(PCOItem *)anItem;
- (void)serverSendGeneralLayoutChanged;
- (void)serverSendHideLyrics;
- (void)serverSendShowLyrics;
- (void)serverSendShowTextAlert:(NSString *)alertText;
- (void)serverSendShowNumberAlert:(NSString *)alertText;
- (void)serverSendHideAlert;

- (void)serverSendPlayVideo;
- (void)serverSendPauseVideo;
- (void)serverSendScrubVideo:(float)value;

- (void)serverSendRefreshPlan:(NSUInteger)refreshType;

- (void)severSendingPlanToPlay:(NSString *)displayName;

- (void)serverSendLiveControlledByUserId;
- (void)serverSendLiveClearControlledByUserId;

- (UIColor *)navBarColorForP2PSessionState;
- (UIColor *)navBarTintColorForP2PSessionState;

- (P2PClientMode)currentClientMode;
- (BOOL)useConfidenceModeAtPlanItemIndex:(NSInteger)index;

+ (ProjectorP2P_SessionManager *)sharedManager;

@end

PCO_EXTERN_STRING USER_DEFAULT_P2P_CLIENT_MODE;
PCO_EXTERN_STRING USER_DEFAULT_P2P_LAST_SERVER_DISPLAY_PEERID;

PCO_EXTERN_STRING P2P_PICK_PLAN_ITEM_COMMAND_NOTIFICATION;
PCO_EXTERN_STRING P2P_SHOW_THIS_PAGE_COMMAND_NOTIFICATION;
PCO_EXTERN_STRING P2P_SEND_SHOW_THIS_PAGE_COMMAND_NOTIFICATION;
PCO_EXTERN_STRING P2P_GOTO_THIS_PAGE_COMMAND_NOTIFICATION;
PCO_EXTERN_STRING P2P_REFRESH_PLAN_COMMAND_NOTIFICATION;
PCO_EXTERN_STRING P2P_CLOSE_PDF_VIEW_COMMAND_NOTIFICATION;
PCO_EXTERN_STRING P2P_LOAD_THIS_PLAN_COMMAND_NOTIFICATION;
PCO_EXTERN_STRING P2P_CLIENT_MODE_CHANGED_NOTIFICATION;
