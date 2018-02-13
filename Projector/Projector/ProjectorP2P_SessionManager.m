//
//  ProjectorP2P_SessionManager.m
//  Projector
//
//  Created by Peter Fokos on 6/17/14.
//

#import "ProjectorP2P_SessionManager.h"
#import "PCOServiceType.h"
#import "PROStateSaver.h"
#import "P2P_Device.h"
#import "PRODisplayItem.h"
#import "PROBlackItem.h"
#import "PROLogoDisplayItem.h"
#import "PRODisplayController.h"
#import "PROEndOfPlanItem.h"
#import "PROSlideManager.h"
#import "PCOLiveController.h"
#import "PROUIOptimization.h"
#import "MCTReachability.h"

#define SESSION_TYPE_NIL @""
#define SESSION_TYPE_SERVER             @"server"
#define SESSION_TYPE_CLIENT             @"client"
#define SESSION_TYPE_SEARCHING_CLIENT   @"searchingClient"

static ProjectorP2P_SessionManager *sharedManager = nil;

@interface ProjectorP2P_SessionManager () {
    BOOL needToLoadPlanUponNotification;
    NSNumber *remoteIdOfPlanToLoad;
    NSNumber *serviceTypeIdOfPlanToLoad;
    
    BOOL needToPositionScrubber;
    float scrubPosition;
    BOOL shouldPause;

}

@property (nonatomic, strong) NSHashTable *delegateHashTable;

@end

@implementation ProjectorP2P_SessionManager

#pragma mark - Singleton implementation

+ (ProjectorP2P_SessionManager *)sharedManager {
	@synchronized (self) {
		if (sharedManager == nil) {
			sharedManager = [[self alloc] init];
		}
	}
	
	return sharedManager;
}

#pragma mark - Init and Delegate Methods

- (id)init {
	if ((self = [super init]))
	{
        self.productName = PROJECTOR_P2P_PRODUCT_NAME;
        self.clientMode = [[[PROStateSaver sharedState] sessionClientMode] integerValue];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(planUpdated:) name:PCOPlanUpdatedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertDidChange:) name:PRODisplayControllerDidSetAlertNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreSavedSession) name:MCTReachabilityStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged:) name:ProjectorSettingsDidChangeNotification object:nil];
	}
    return self;
}

- (NSHashTable *)delegateHashTable {
    if (!_delegateHashTable) {
        _delegateHashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegateHashTable;
}

- (void)addDelegate:(id<ProjectorP2P_SessionManagerDelegate>)delegate {
    if (delegate) {
        [self.delegateHashTable addObject:delegate];
    }
}

- (void)removeDelegate:(id<ProjectorP2P_SessionManagerDelegate>)delegate {
    if (delegate) {
        [self.delegateHashTable removeObject:delegate];
    }
}

- (void)performSafe:(SEL)checkSelector forDelegates:(void(^)(id<ProjectorP2P_SessionManagerDelegate> delegate))perform {
    for (id<ProjectorP2P_SessionManagerDelegate>del in self.delegateHashTable ) {
        if (checkSelector == NULL) {
            perform(del);
        } else if ([del respondsToSelector:checkSelector]) {
            perform(del);
        }
    }
}

#pragma mark - Connection Methods

- (void)createNewServerSession {
    [super createNewServerSession];
    // product specific
    needToLoadPlanUponNotification = NO;
    [self saveActiveSession];
}

- (void)createNewClientSession {
    [super createNewClientSession];
    needToLoadPlanUponNotification = NO;
    [[PCOLiveController sharedController] setSessionServerUserId:nil];
}

- (void)connectToServer:(P2P_Device *)device {
    [super connectToServer:device];
    // product specific
    [self saveActiveSession];
}

- (void)disconnectFromServer:(P2P_Device *)device {
    [self clearSavedActiveSession];
    [[PCOLiveController sharedController] setSessionServerUserId:nil];
    [super disconnectFromServer:device];
}

- (void)closeServerSession {
    [self serverSendSessionClosing];
    [super closeServerSession];
    [self clearSavedActiveSession];
}

- (void)closeSessionManager {
    [super closeSessionManager];
    // product specific code here
    [self serverSendSessionClosing];
}

#pragma mark - Notification Methods

- (void)settingsChanged:(NSNotification *)notif {
    [networkManager restartNetworkProtocolManagers];
}

- (void)planUpdated:(NSNotification *)notif {
    if ([networkManager isClient])
    {
    }
}

- (void)alertDidChange:(NSNotification *)notif {
    NSDictionary *dict = notif.userInfo;
    PROAlertView *alertView = [dict objectForKey:kPRODisplayControllerAlertView];
    if ([[PRODisplayController sharedController] isAnAlertActive]) {
        [self serverSendShowTextAlert:alertView.alertText];
    } else {
        [self serverSendHideAlert];
    }
}

- (void)appDidEnterBackground {
    [self saveActiveSession];
    [networkManager applicationDidEnterBackground:self.connectedServerDevice];
}

- (void)appDidBecomeActive {
    [self restoreSavedSession];
}

#pragma mark - Session Restoration Methods

- (void)saveActiveSession {
    [self clearSavedActiveSession];
    P2PEventLog(@"SAVE ACTIVE SESSION");
    [[PROStateSaver sharedState] setSessionType:SESSION_TYPE_SEARCHING_CLIENT];
    if ([self isConnectedClient]) {
        [[PROStateSaver sharedState] setSessionType:SESSION_TYPE_CLIENT];
        [[PROStateSaver sharedState] setSessionConnectedToServerNamed:self.connectedServerDevice.name];
    }
    else if ([self isServer]) {
        [[PROStateSaver sharedState] setSessionType:SESSION_TYPE_SERVER];
        
    }
}

- (void)restoreSavedSession {
    if ([PCOServer networkReachable] && [PCOOrganization current]) {
        P2PEventLog(@"RESTORE SAVED SESSION");
        NSString *sessionType = [[PROStateSaver sharedState] sessionType];
        if ([sessionType isEqualToString:SESSION_TYPE_SERVER]) {
            [networkManager restartServerIfStopped];
        }
    }
}

- (void)clearSavedActiveSession {
    P2PEventLog(@"CLEARING SAVED ACTIVE SESSION");
    [[PROStateSaver sharedState] setSessionType:SESSION_TYPE_NIL];
    [[PROStateSaver sharedState] setSessionConnectedToServerNamed:SESSION_TYPE_NIL];
}

#pragma mark - Public Server Send Command Methods

- (void)serverSendSessionClosing {
    if ([networkManager isServer]) {
        
        NSArray *array = @[@(P2PCommandSessionClosing),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Close Session: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendUseAltServerPeerId:(NSString *)peerId {
    if ([networkManager sessionActive]) {
        
        __block NSArray *data = nil;
        [self performSafe:@selector(playStatus) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
            data = [delegate playStatus];
            if ([data count] == 4) {
                NSArray *array = @[@(P2PCommandServerAltPeerId),
                                   peerId,
                                   data[0],
                                   data[1],
                                   data[2],
                                   data[3],
                                   [self uniqueIdForMessage]];
                
                P2PEventLog(@"Sending Use Alt Server Peer ID: %@", array);
                clientCommand = NO;
                [self serverSendData:array];
            }
        }];
    }
}

- (void)severSendingPlanToPlay:(NSString *)displayName {
    NSNumber *planId = [[[PROSlideManager sharedManager] plan] remoteId];
    PCOOrganization *organization = [PCOOrganization current];
    NSDictionary *planData = @{@"live": PCOSafe([PCOUserData current].userId)};

    NSArray *array = @[@(P2PCommandLoadThisPlan),
                       PCOSafe(planId),
                       PCOSafe(organization.organizationId),
                       PCOSafe(organization.name),
                       PCOSafe(planData),
                       [self uniqueIdForMessage]];
    
    P2PEventLog(@"Sending Load Plan: %@ to displayname: %@", array, displayName);
    
    [self serverSendData:array toDisplayName:displayName];
}

- (void)serverSendPlayVideo {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandPlayVideo),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Play Video: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendPauseVideo {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandPauseVideo),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Pause Video: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendScrubVideo:(float)value {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandScrubVideo),
                           PCOSafe(@(value)),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Scrub Video: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendHideLyrics {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandPlayHideLyrics),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Hide Lyrics: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendShowLyrics {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandPlayShowLyrics),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Show Lyrics: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendShowTextAlert:(NSString *)alertText {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandShowTextAlert),
                           PCOSafe(alertText),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Show Text Alert: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendShowNumberAlert:(NSString *)alertText {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandShowNumberAlert),
                           PCOSafe(alertText),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Show Number Alert: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendHideAlert {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandHideAlert),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Hide Alert: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendLiveControlledByUserId {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandLiveControlledByUserId),
                           PCOSafe([PCOUserData current].userId),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Live Controlled by User Id: %@", array);
        
        [self serverSendData:array];
        [[PCOLiveController sharedController] setSessionServerUserId:[PCOUserData current].userId];
    }
}

- (void)serverSendLiveClearControlledByUserId {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandLiveClearControlledByUserId),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Clear Live Controlled: %@", array);
        
        [self serverSendData:array];
        [[PCOLiveController sharedController] setSessionServerUserId:nil];
    }
}

- (void)serverSendPlayLogo {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandPlayLogo),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Play Logo: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendPlayBlackScreen {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandPlayBlackScreen),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Play Black Screen: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendPlanItemChanged:(PCOItem *)anItem {
    if ([self isInControl]) {
		if ([self isServer])
		{
            NSArray *array = @[@(P2PCommandServerPlanItemChanged),
                               [self uniqueIdForMessage]];
			[self serverSendData:array];
		}
        else
		{
            NSArray *array = @[@(P2PCommandClientPlanItemChanged),
                               [self uniqueIdForMessage]];
			[self clientSendData:array];
		}
    }
}

- (void)serverSendRefreshPlan:(NSUInteger)refreshType {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandRefreshPlan),
                           PCOSafe(@(refreshType)),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending Refresh Plan: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendGeneralLayoutChanged {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandGeneralLayoutCHanged),
                           [self uniqueIdForMessage]];
        
        P2PEventLog(@"Sending General Layout Changed: %@", array);
        
        [self serverSendData:array];
    }
}

- (void)serverSendPlaySlideAtIndex:(NSInteger)slideIndex itemIndex:(NSInteger)itemIndex isPaused:(BOOL)paused scrubPosition:(float)value {
    if ([self isInControl]) {
        NSArray *array = @[@(P2PCommandPlayThisSlide),
                           PCOSafe(@(slideIndex)),
                           PCOSafe(@(itemIndex)),
                           PCOSafe(@(paused)),
                           PCOSafe(@(value)),
                           [self uniqueIdForMessage]];

        P2PEventLog(@"Sending Play Slide: %@", array);
        [self serverSendData:array];
    }
}

#pragma mark - Public Client Send Command Methods

- (void)processP2PCommand:(NSArray *)array from:(NSString *)peerId {
    
    if ([peerId isEqualToString:self.peerId]) {
        return;
    }
    NSInteger command = [[array objectAtIndex:0] intValue];
    
    if ([networkManager isClient]) {
        if ([peerId isEqualToString:self.connectedServerDevice.peerId] ||
            [peerId isEqualToString:self.connectedServerDevice.name] ||
            [peerId isEqualToString:self.connectedToAltServerPeerId] ||
            command == P2PCommandServerAltPeerId)
        {
            [self executeReceivedCommand:command fromClient:NO data:array];
        }
    }
    if ([networkManager isServer]) {
        switch (command) {
            case 0:
            {
//              # TODO: What do we need here
                break;
            }
        }
        
        // if we get a command from the peer who is in command then execute that command
        if ([peerId isEqualToString:self.controlledByClientPeerId]) {
            [self executeReceivedCommand:command fromClient:YES data:array];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionReceivedCommandNotification object:array];
}

- (void)connectionWithDisplayNameConnected:(NSString *)displayName {
    if ([networkManager isServer]) {
        [self severSendingPlanToPlay:displayName];
    }
    else if ([networkManager isClient]) {
        if (self.connectedServerDevice.status == P2P_Device_Status_Connecting && [displayName isEqualToString:self.connectedServerDevice.name]) {
            self.connectedServerDevice.status = P2P_Device_Status_Connected;
            [self postNotification:P2PSessionConnectedNotification];
        }
    }
}

- (void)connectionWithDisplayNameDisconnected:(NSString *)displayName {
    if ([displayName isEqualToString:self.connectedServerDevice.name]) {
        [self performSafe:@selector(sessionClosing) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
            [delegate sessionClosing];
        }];
        [self clearConnectedServerDevice];
        [networkManager closeSessionManager];
    }
    [self postNotification:P2PSessionDisconnectedNotification];
}

- (void)connectionWithDisplayNameDidNotConnect:(NSString *)displayName {
    [self connectionWithDisplayNameDisconnected:displayName];
}

- (void)serverFoundWithDisplayName:(NSString *)displayName {
    // if we have a client reconnect pending then look for the server we disconnected from in the available servers list
    // if found then try to reconnect
    
    NSArray *servers = [self availableServers];
    if ([servers count] > 0 && [[[PROStateSaver sharedState] sessionType] isEqualToString:SESSION_TYPE_CLIENT]) {
        NSString *sessionPeerId = [[PROStateSaver sharedState] sessionConnectedToServerNamed];
        for (P2P_Device *device in servers) {
            if ([device.name isEqualToString:sessionPeerId]) {
                [self connectToServer:device];
                break;
            }
        }
    }
}

- (void)serverLostWithDisplayName:(NSString *)displayName {
    // if we are connected to a server and it suddenly disconnects then add it to the reconnect list
    if ([self.connectedServerDevice.name isEqualToString:displayName]) {
        [self saveActiveSession];
    }
}

#pragma mark - Command Processor

- (void)executeReceivedCommand:(NSInteger)command fromClient:(BOOL)fromClient data:(NSArray *)array {
    NSLog(@"executeReceivedCommand: %td", command);
    switch (command) {
        case P2PCommandLoadThisPlan:
        {
            NSNumber *remoteID = [array objectAtIndex:1];
            NSNumber *orgID = [array objectAtIndex:2];
            NSString *orgName = [array objectAtIndex:3];
            NSDictionary *planData = [array objectAtIndex:4];
            NSLog(@"PlanData: %@", planData);
            if ([orgID isEqualToNumber:[[PCOOrganization current] organizationId]]) {
                if (![[[[PROSlideManager sharedManager] plan] remoteId] isEqualToNumber:remoteID]) {
                    PCOPlan *plan = [PCOPlan findOrCreateWithRemoteID:remoteID];
                    if (plan) {
                        [[PROUIOptimization sharedOptimizer] loadingAFreshPlan];
                        [PROPlanContainerViewController displayPlan:plan];
                    }
                }
                NSNumber *sessionUserId = [planData objectForKey:@"live"];
                if (sessionUserId) {
                    [[PCOLiveController sharedController] setSessionServerUserId:sessionUserId];
                }
            }
            else {
                NSString *title = NSLocalizedString(@"Incorrect Organization", nil);
                NSString *orgMsg = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"To connect to this session you need to log into", nil), orgName];
                MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:title message:orgMsg cancelButtonTitle:NSLocalizedString(@"OK", nil)];
                [alert show];
                [super disconnectFromServer:self.connectedServerDevice];
            }
        }
            break;
        case P2PCommandServerAltPeerId:
        {
            P2PEventLog(@"Received Use Alt Server Peer ID: %@", array);
            if ([networkManager isClient]) {
                self.connectedToAltServerPeerId = [array objectAtIndex:1];
                if ([self.connectedServerDevice.peerId isEqualToString:self.connectedToAltServerPeerId]) {
                    self.connectedToAltServerPeerId = nil;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionStateChangedNotification object:nil];
            break;
        }
        case P2PCommandSessionClosing:
        {
            clientCommand = fromClient;
            
            [self performSafe:@selector(sessionClosing) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate sessionClosing];
            }];
            
            [self clearConnectedServerDevice];
            [self clearSavedActiveSession];
            [networkManager closeSessionManager];
            break;
        }
        case P2PCommandPlayThisSlide:
        {
            clientCommand = fromClient;
            NSInteger slideIndex = [[array objectAtIndex:1] integerValue];
            NSInteger planItemIndex = [[array objectAtIndex:2] integerValue];
            shouldPause = [[array objectAtIndex:3] boolValue];
            scrubPosition = [[array objectAtIndex:4] floatValue];
            
            [self performSafe:@selector(playSlideAtIndex:withPlanItemIndex:andScrubPosition:shouldPause:) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate playSlideAtIndex:slideIndex
                              withPlanItemIndex:planItemIndex
                               andScrubPosition:scrubPosition
                                    shouldPause:shouldPause];
            }];
            break;
        }
        case P2PCommandPlayLogo:
        {
            clientCommand = fromClient;
            [self performSafe:@selector(playLogo) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate playLogo];
            }];
            break;
        }
        case P2PCommandPlayBlackScreen:
        {
            clientCommand = fromClient;
            [self performSafe:@selector(playBlackScreen) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate playBlackScreen];
            }];
            break;
        }
        case P2PCommandPlayHideLyrics:
        {
            clientCommand = fromClient;
            [self performSafe:@selector(hideLyrics) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate hideLyrics];
            }];
            break;
        }
        case P2PCommandPlayShowLyrics:
        {
            clientCommand = fromClient;
            [self performSafe:@selector(showLyrics) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate showLyrics];
            }];
            break;
        }
        case P2PCommandShowTextAlert:
        case P2PCommandShowNumberAlert:
        {
            clientCommand = fromClient;
            NSString *alertText = nil;
            if ([array count] > 1) {
                alertText = [array objectAtIndex:1];
                [self performSafe:@selector(showAlertText:) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                    [delegate showAlertText:alertText];
                }];
            }
            break;
        }
        case P2PCommandHideAlert:
        {
            clientCommand = fromClient;
            [self performSafe:@selector(hideAlertText) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate hideAlertText];
            }];
            break;
        }
        case P2PCommandServerPlanItemChanged:
        {
            [self performSafe:@selector(refreshPlan) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate refreshPlan];
            }];
            break;
        }
		case P2PCommandClientPlanItemChanged:
		{
            [self performSafe:@selector(refreshPlan) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate refreshPlan];
            }];
			break;
		}
        case P2PCommandGeneralLayoutCHanged:
        {
            [self performSafe:@selector(refreshPlan) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate refreshPlan];
            }];
            break;
        }
        case P2PCommandPlayVideo:
        {
            clientCommand = fromClient;
            [self performSafe:@selector(playVideo) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate playVideo];
            }];
            break;
        }
        case P2PCommandPauseVideo:
        {
            clientCommand = fromClient;
            [self performSafe:@selector(pauseVideo) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                [delegate pauseVideo];
            }];
            break;
        }
        case P2PCommandScrubVideo:
        {
            clientCommand = fromClient;
            if ([array count] > 1) {
                scrubPosition = [[array objectAtIndex:1] floatValue];
                [self performSafe:@selector(scrubVideo:) forDelegates:^(id<ProjectorP2P_SessionManagerDelegate> delegate) {
                    [delegate scrubVideo:scrubPosition];
                }];
            }
            break;
        }
        case P2PCommandLiveControlledByUserId:
        {
            NSNumber *sessionUserId = [array objectAtIndex:1];
            [[PCOLiveController sharedController] setSessionServerUserId:sessionUserId];
            break;
        }
        case P2PCommandLiveClearControlledByUserId:
        {
            [[PCOLiveController sharedController] setSessionServerUserId:nil];
            break;
        }
    }
}

- (void)controllingIdChanged:(NSString *)peerId {
    [self serverSendUseAltServerPeerId:peerId];
}

- (void)clearConnectedServerDevice {
    if (self.connectedServerDevice) {
        self.connectedServerDevice.status = P2P_Device_Status_NotConnected;
        self.connectedServerDevice = nil;
        [self postNotification:P2PSessionStateChangedNotification];
    }
}

- (void)setClientMode:(P2PClientMode)clientMode {
    _clientMode = clientMode;
    [[PROStateSaver sharedState] setSessionClientMode:@(clientMode)];
    [[NSNotificationCenter defaultCenter] postNotificationName:P2P_CLIENT_MODE_CHANGED_NOTIFICATION object:nil];
}

- (P2PClientMode)currentClientMode {
    if ([self isConnectedClient]) {
        return self.clientMode;
    }
    return P2PClientModeNone;
}

- (BOOL)useConfidenceModeAtPlanItemIndex:(NSInteger)index {
    if ([self currentClientMode] != P2PClientModeConfidence) {
        return NO;
    }
    PCOPlan *plan = [[PROSlideManager sharedManager] plan];
    if (plan) {
        if (index < (NSInteger)[[plan orderedItems] count]) {
            PCOItem *item = [[plan orderedItems] objectAtIndex:index];
            if ([item isTypeSong]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - PROContainerViewControllerEventListener Methods

- (void)currentItemDidChange:(PRODisplayItem *)currentItem {
    if ([self isInControl]) {
        if ([currentItem isKindOfClass:[PROBlackItem class]]) {
            [self serverSendPlayBlackScreen];
        }
        else if ([currentItem isKindOfClass:[PROLogoDisplayItem class]]) {
            [self serverSendPlayLogo];
        }
        else if ([currentItem isKindOfClass:[PRODisplayItem class]]) {
            NSInteger slideIndex = currentItem.indexPath.row;
            NSInteger planItemIndex = currentItem.indexPath.section;
            [self serverSendPlaySlideAtIndex:slideIndex itemIndex:planItemIndex isPaused:NO scrubPosition:0.0];
        }
    }
}

#pragma mark - UI Helper Methods

- (UIColor *)navBarColorForP2PSessionState {
    if ([self isInControl]) {
        return RGB(46, 126, 38);
    }
    else if ([self isConnectedClient]) {
        return RGB(160, 57, 37);
    }
    return nil;
}

- (UIColor *)navBarTintColorForP2PSessionState {
    if ([self isInControl]) {
        return RGB(31, 75, 25);
    }
    else if ([self isConnectedClient]) {
        return RGB(96, 28, 15);
    }
    return nil;
}

@end

// User Default Strings
NSString * const USER_DEFAULT_P2P_CLIENT_MODE = @"P2PClientMode";
NSString * const USER_DEFAULT_P2P_LAST_SERVER_DISPLAY_PEERID = @"P2PLastServerDisplayPeerId";

// P2P Command Strings
NSString * const P2P_PICK_PLAN_ITEM_COMMAND_NOTIFICATION = @"P2P_PICK_PLAN_ITEM_COMMAND_NOTIFICATION";
NSString * const P2P_SHOW_THIS_PAGE_COMMAND_NOTIFICATION = @"P2P_SHOW_THIS_PAGE_COMMAND_NOTIFICATION";
NSString * const P2P_SEND_SHOW_THIS_PAGE_COMMAND_NOTIFICATION = @"P2P_SEND_SHOW_THIS_PAGE_COMMAND_NOTIFICATION";
NSString * const P2P_GOTO_THIS_PAGE_COMMAND_NOTIFICATION = @"P2P_GOTO_THIS_PAGE_COMMAND_NOTIFICATION";
NSString * const P2P_REFRESH_PLAN_COMMAND_NOTIFICATION = @"P2P_REFRESH_PLAN_COMMAND_NOTIFICATION";
NSString * const P2P_CLOSE_PDF_VIEW_COMMAND_NOTIFICATION = @"P2P_CLOSE_PDF_VIEW_COMMAND_NOTIFICATION";
NSString * const P2P_LOAD_THIS_PLAN_COMMAND_NOTIFICATION = @"P2P_LOAD_THIS_PLAN_COMMAND_NOTIFICATION";
NSString * const P2P_CLIENT_MODE_CHANGED_NOTIFICATION = @"P2P_CLIENT_MODE_CHANGED_NOTIFICATION";
