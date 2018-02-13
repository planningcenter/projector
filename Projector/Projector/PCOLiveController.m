//
//  PCOLiveController.m
//  Projector
//
//  Created by Peter Fokos on 7/21/14.
//

#import "PCOLiveController.h"
#import "PCOPlanItemTime.h"
#import "PCOPlanTime.h"
#import "PCOServiceType.h"
#import "ProjectorP2P_SessionManager.h"
#import "MCTReachability.h"

id static _sharedPCOLiveController = nil;

@interface PCOLiveController ()

@property (nonatomic) NSInteger lastPlanItemIndex;
@property (strong, nonatomic) PTPusher *pusherConnection;
@property (strong, nonatomic) NSString *liveChannelName;
@property (strong, nonatomic) NSString *liveChatChannelName;
@property (nonatomic, strong) NSHashTable *delegateHashTable;
@property (nonatomic, strong) NSDateFormatter *liveDateFormatter;
@property (nonatomic, strong) NSDateFormatter *moveDateFormatter;

@end

@implementation PCOLiveController



#pragma mark -
#pragma mark - Initialization

- (id)init {
	self = [super init];
	if (self) {
        self.lastPlanItemIndex = -1;
        
        //sample @"at=July 22 2014, 9:18:11 am";
        _liveDateFormatter = [[NSDateFormatter alloc] init];
        [_liveDateFormatter setDateFormat:@"MMM dd yyyy, hh:mm:ss a"];
        _liveDateFormatter.locale = [NSLocale currentLocale];

        //sample @"2014-07-22T17:35:12";
        _moveDateFormatter = [[NSDateFormatter alloc] init];
        [_moveDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        _moveDateFormatter.locale = [NSLocale currentLocale];

	}
	return self;
}

- (NSHashTable *)delegateHashTable {
    if (!_delegateHashTable) {
        _delegateHashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegateHashTable;
}

- (void)addDelegate:(id<PCOLiveControllerDelegate>)delegate {
    if (delegate) {
        [self.delegateHashTable addObject:delegate];
    }
}

- (void)removeDelegate:(id<PCOLiveControllerDelegate>)delegate {
    if (delegate) {
        [self.delegateHashTable removeObject:delegate];
    }
}

- (void)performSafe:(SEL)checkSelector forDelegates:(void(^)(id<PCOLiveControllerDelegate> delegate))perform {
    for (id<PCOLiveControllerDelegate>del in self.delegateHashTable ) {
        if (checkSelector == NULL) {
            perform(del);
        } else if ([del respondsToSelector:checkSelector]) {
            perform(del);
        }
    }
}

- (void)setLivePlan:(PCOPlan *)livePlan {
    _livePlan = livePlan;
    [livePlan loadServiceTypeIfNeeded];
}

- (void)setSessionServerUserId:(NSNumber *)sessionServerUserId {
    _sessionServerUserId = sessionServerUserId;
    [[NSNotificationCenter defaultCenter] postNotificationName:PCOLiveStateChangedNotification object:nil];
}

- (void)setLiveStatus:(PCOLiveStatus *)liveStatus {
    _liveStatus = liveStatus;
}

#pragma mark -
#pragma mark - Singleton

+ (instancetype)sharedController {
	@synchronized (self) {
        if (!_sharedPCOLiveController) {
            _sharedPCOLiveController = [[[self class] alloc] init];
        }
        return _sharedPCOLiveController;
    }
}

#pragma mark -
#pragma mark - Helpers
- (PCOServerRequest *)livePostRequestWithURLString:(NSString *)urlString {
    NSURL *URL = [NSURL planningCenterBaseURLWithPath:urlString];
    NSString *time = [NSString stringWithFormat:@"at=%@", [[self.liveDateFormatter stringFromDate:[NSDate date]] lowercaseString]];
    NSData *data = [time dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest =  [NSMutableURLRequest requestWithURL:URL];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest addValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [urlRequest addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:data];
    
    PCOServerRequest *request = [PCOServerRequest requestWithURLRequest:urlRequest];
    request.offlinePolicy = PCOServerRequestOfflineDiscard;
    request.HTTPMethod = HTTPMethodPost;
    return request;
}

#pragma mark -
#pragma mark - Live Control

- (void)liveNextAtPlanItemIndex:(NSInteger)planItemIndex {
    if (planItemIndex == self.lastPlanItemIndex || !_livePlan) {
        return;
    }
    
    [self getLiveStatusWithSuccessCompletion:^(PCOLiveStatus *status) {
        [self liveNext];
    } errorCompletion:^(NSError *error) {
        
    }];
}

- (void)liveNext {
    NSString *urlString = [NSString stringWithFormat:@"live/%@/next.json", [self.livePlan.remoteId stringValue]];
    PCOServerRequest *request = [self livePostRequestWithURLString:urlString];
    
    [request setCompletion:^(PCOServerResponse *response) {
        if (response.error)
        {
            PCOLogError(@"Error %@", [response.error localizedDescription]);
            PCOLogDebug(@"HTTPresponse status code: %d", response.HTTPResponse.statusCode);
        }
        else
        {
            if (![response.HTTPResponse responseOK])
            {
                PCOLogError(@"Error - got response: %d", response.HTTPResponse.statusCode);
            }
            else
            {
                PCOLogDebug(@"HTTPresponse status code: %d", response.HTTPResponse.statusCode);
                self.lastPlanItemIndex = -1;
                [self getLiveStatusWithSuccessCompletion:^(PCOLiveStatus *status) {
                    
                } errorCompletion:^(NSError *error) {
                    
                }];
            }
        }
    }];
    [request start];
}

- (void)livePrevious {
    [self livePreviousWithSuccessCompletion:^{
        
    } errorCompletion:^(NSError *error) {
        
    }];
}

- (void)livePreviousAtPlanItemIndex:(NSInteger)planItemIndex {
    if (planItemIndex == self.lastPlanItemIndex || !_livePlan) {
        return;
    }
    [self livePreviousWithSuccessCompletion:^{
        
    } errorCompletion:^(NSError *error) {
        
    }];
}

- (void)livePreviousWithSuccessCompletion:(void (^)(void))successBlock errorCompletion:(void (^)(NSError * error))errorBlock {
    if (self.livePlan.remoteId) {
        NSString *urlString = [NSString stringWithFormat:@"live/%@/previous.json", [self.livePlan.remoteId stringValue]];
        PCOServerRequest *request = [self livePostRequestWithURLString:urlString];
        
        [request setCompletion:^(PCOServerResponse *response) {
            if (response.error)
            {
                PCOLogError(@"Error %@", [response.error localizedDescription]);
                PCOLogDebug(@"HTTPresponse status code: %d", response.HTTPResponse.statusCode);
            }
            else
            {
                if (![response.HTTPResponse responseOK])
                {
                    PCOLogError(@"Error - got response: %d", response.HTTPResponse.statusCode);
                    errorBlock(response.error);
                }
                else
                {
                    PCOLogDebug(@"HTTPresponse status code: %d", response.HTTPResponse.statusCode);
                    self.lastPlanItemIndex = -1;
                    successBlock();
                }
            }
        }];
        [request start];
    }
    else {
        PCOLogError(@"Need to set plan id before requesting a PCO Live status!");
    }
}


- (void)startLiveItemAtPlanItemIndex:(NSInteger)planItemIndex {
    [self startLiveItemAtPlanItemIndex:planItemIndex successCompletion:^(NSDictionary *status) {
        
    } errorCompletion:^(NSError *error) {
        
    }];
}

- (void)moveLiveToEndOfServiceFromPlanItemIndex:(NSInteger)planItemIndex {
    if (planItemIndex == self.lastPlanItemIndex) {
        [self liveNext];
    }
    else {
        [self startLiveItemAtPlanItemIndex:planItemIndex successCompletion:^(NSDictionary *status) {
            [self liveNext];
        } errorCompletion:^(NSError *error) {
            
        }];
    }
}

- (void)startLiveItemAtPlanItemIndex:(NSInteger)planItemIndex successCompletion:(void (^)(NSDictionary *status))successBlock errorCompletion:(void (^)(NSError * error))errorBlock {

    // if planItemIndex == lastPlanItemIndex then return
    // get the current status
    // if the itemId == planItemIndex's id then return, same item no change
    // parse through all the items to find the one who's planItemTimeId matches the statusId
    // get the timeId of that planItemTime and save it
    // now parse through all the planItemTimes of the item from planItemIndex to find the one who's timeId matches the saved timeId
    
    if (planItemIndex == self.lastPlanItemIndex ||
        ![self isLiveControlledByUser] ||
        planItemIndex >= (NSInteger)[[self.livePlan orderedItems] count]
        ) {
        return;
    }
    
    [self getLiveStatusWithSuccessCompletion:^(PCOLiveStatus *status) {
        
        NSNumber *planItemTimeId = nil;
        
        PCOItem *planItem = [[self.livePlan orderedItems] objectAtIndex:planItemIndex];
        NSNumber *currentTimeId = nil;
        
        if (status.type != PCOLiveStatusTypeEnded) {
            if (self.lastPlanItemIndex == -1 || ![[status itemId] isEqualToNumber:planItem.remoteId]) {
                
                for (PCOItem *item in [self.livePlan orderedItems]) {
                    if ([item.remoteId isEqualToNumber:[status itemId]]) {
                        for (PCOPlanItemTime *planItemTime in [[item planItemTimes] allObjects]) {
                            if ([planItemTime.remoteId isEqualToNumber:[status timeId]]) {
                                currentTimeId = planItemTime.timeId;
                                break;
                            }
                        }
                        break;
                    }
                }
                if (currentTimeId) {
                    for (PCOPlanItemTime *planItemTime in [[planItem planItemTimes] allObjects]) {
                        if (([planItemTime.timeId isEqualToNumber:currentTimeId])) {
                            planItemTimeId = planItemTime.remoteId;
                            break;
                        }
                    }
                    
                    if (planItemTimeId) {
                        [self startLiveItemWithPlanItemTimeId:planItemTimeId successCompletion:^(NSDictionary *status) {
                            PCOLogDebug(@"Set Live pit_id: %@", [planItemTimeId stringValue]);
                            self.lastPlanItemIndex = planItemIndex;
                            [[NSNotificationCenter defaultCenter] postNotificationName:PCOLiveStateChangedNotification object:nil];
                            successBlock(status);
                        } errorCompletion:^(NSError *error) {
                            PCOLogDebug(@"Could Not Set Live pit_id: %@", [planItemTimeId stringValue]);
                            errorBlock(error);
                        }];
                    }
                }
            }
        }
    } errorCompletion:^(NSError *error) {
        errorBlock(error);
    }];
}

- (void)startLiveItemWithPlanItemTimeId:(NSNumber *)planItemTimeId successCompletion:(void (^)(NSDictionary *status))success errorCompletion:(void (^)(NSError * error))errorBlock {
    if (self.livePlan.remoteId && planItemTimeId) {
        NSString *time = [NSString stringWithFormat:@"at=%@", [[self.moveDateFormatter stringFromDate:[NSDate date]] lowercaseString]];
        time = [time stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        
        NSString *urlString = [NSString stringWithFormat:@"live/%@/move?pit_id=%@&%@", [self.livePlan.remoteId stringValue], [planItemTimeId stringValue], time];
        NSURL *URL = [NSURL planningCenterBaseURLWithPath:urlString];
        NSMutableURLRequest *urlRequest =  [NSMutableURLRequest requestWithURL:URL];
        urlRequest.HTTPMethod = @"POST";
        
        PCOServerRequest *request = [PCOServerRequest requestWithURLRequest:urlRequest];
        request.offlinePolicy = PCOServerRequestOfflineDiscard;
        request.HTTPMethod = HTTPMethodPost;
        
        [request setCompletion:^(PCOServerResponse *response) {
            if (response.error)
            {
                PCOLogError(@"Error %@", [response.error localizedDescription]);
                PCOLogDebug(@"HTTPresponse status code: %d", response.HTTPResponse.statusCode);
                errorBlock(response.error);
            }
            else
            {
                if (![response.HTTPResponse responseOK])
                {
                    PCOLogError(@"Error - got response: %d", response.HTTPResponse.statusCode);
                    errorBlock(response.error);
                }
                else
                {
                    PCOLogDebug(@"HTTPresponse status code: %d", response.HTTPResponse.statusCode);
                    NSDictionary *statusJson = [response.JSONBody objectForKey:@"control"];
                    success(statusJson);
                }
            }
        }];
        [request start];
    }
    else {
        PCOLogError(@"Need to set plan id before starting an item!");
    }
}

- (void)takeControlOfLiveSessionWithSuccessCompletion:(void (^)(PCOLiveStatus *status))success errorCompletion:(void (^)(NSError * error))errorBlock {
    if (self.livePlan.remoteId) {
        self.lastPlanItemIndex = -1;
        
        NSString *urlString = [NSString stringWithFormat:@"live/%@/control.json", [self.livePlan.remoteId stringValue]];
        PCOServerRequest *request = [self livePostRequestWithURLString:urlString];
        
        [request setCompletion:^(PCOServerResponse *response) {
            if (response.error)
            {
                PCOLogError(@"Error %@", [response.error localizedDescription]);
                PCOLogDebug(@"HTTPresponse status code: %d", response.HTTPResponse.statusCode);
                errorBlock(response.error);
            }
            else
            {
                if (![response.HTTPResponse responseOK])
                {
                    PCOLogError(@"Error - got response: %d", response.HTTPResponse.statusCode);
                    errorBlock(response.error);
                }
                else
                {
                    PCOLogDebug(@"HTTPresponse status code: %d", response.HTTPResponse.statusCode);
                    [self getLiveStatusWithSuccessCompletion:^(PCOLiveStatus *status) {
                        success(status);
                        if ([status isControlled]) {
                            [[ProjectorP2P_SessionManager sharedManager] serverSendLiveControlledByUserId];
                            [self performSafe:@selector(scrollToPlanItemId:) forDelegates:^(id<PCOLiveControllerDelegate> delegate) {
                                [delegate scrollToPlanItemId:status.itemId];
                            }];
                        }
                    } errorCompletion:^(NSError *error) {
                        errorBlock(error);
                    }];
                }
            }
        }];
        [request start];
    }
    else {
        PCOLogError(@"Need to set plan id before requesting a PCO Live status!");
    }
}

- (void)releaseControlOfLiveSessionByUserId:(NSNumber *)userId {
    if ([self.liveStatus isControlledByUserId:userId]) {
        [self.liveStatus setControlledByName:@"" controlledById:nil];
        [[ProjectorP2P_SessionManager sharedManager] serverSendLiveClearControlledByUserId];
        [self takeControlOfLiveSessionWithSuccessCompletion:^(PCOLiveStatus *status) {
            
        } errorCompletion:^(NSError *error) {
            
        }];
    }
}

#pragma mark -
#pragma mark - Live Status 

- (void)getLiveStatusWithSuccessCompletion:(void (^)(PCOLiveStatus *status))success errorCompletion:(void (^)(NSError * error))errorBlock {
    if (self.livePlan.remoteId) {
        NSURL *URL = [NSURL planningCenterBaseURLWithFormat:@"live/%@.json", [self.livePlan.remoteId stringValue]];
        
        PCOServerRequest *request = [PCOServerRequest requestWithURL:URL];
        request.HTTPMethod = HTTPMethodGet;
        request.offlinePolicy = PCOServerRequestOfflineDiscard;
        
        [request setCompletion:^(PCOServerResponse *response) {
            if (response.error)
            {
                PCOLogError(@"Error %@", [response.error localizedDescription]);
                errorBlock(response.error);
            }
            else
            {
                if (![response.HTTPResponse responseOK])
                {
                    PCOLogError(@"Error - got response: %d", response.HTTPResponse.statusCode);
                    errorBlock(response.error);
                }
                else
                {
                    _liveChannelName = [response.JSONBody objectForKey:@"live"];
                    _liveChatChannelName = [response.JSONBody objectForKey:@"chat_room"];
                    [self subscribeToLiveChannel];
//                    [self subscribeToLiveChatChannel];
                    PCOLiveStatus *newStatus = [PCOLiveStatus liveStatusFromDictionary:[response.JSONBody objectForKey:@"status"]];
                    
                    BOOL currentControlStatus = [self.liveStatus isControlledByUserId:[PCOUserData current].userId];
                    BOOL newControlStatus = [newStatus isControlledByUserId:[PCOUserData current].userId];
                    
                    if (currentControlStatus != newControlStatus) {
                        [self performSafe:@selector(statusDidUpdate:) forDelegates:^(id<PCOLiveControllerDelegate> delegate) {
                            [delegate statusDidUpdate:_liveStatus];
                        }];
                    }
                    
                    self.liveStatus = newStatus;
                    
                    if ([self.liveStatus isControlledByUserId:[PCOUserData current].userId]) {
                        [[ProjectorP2P_SessionManager sharedManager] serverSendLiveControlledByUserId];
                    }
                    
                    success(self.liveStatus);

                }
            }
        }];
        [request start];
    }
    else {
        PCOLogError(@"Need to set plan id before requesting a PCO Live status!");
    }
}

- (void)updateStatusWithControlledByName:(NSString *)controlledByName controlledById:(NSNumber *)controlledById {
    if (_liveStatus) {
        [self.liveStatus setControlledByName:controlledByName controlledById:controlledById];
        if ([controlledByName isEqualToString:@""] && controlledById == nil) {
            [[ProjectorP2P_SessionManager sharedManager] serverSendLiveClearControlledByUserId];
        }
        else {
            [self setSessionServerUserId:controlledById];
        }
        [self performSafe:@selector(statusDidUpdate:) forDelegates:^(id<PCOLiveControllerDelegate> delegate) {
            [delegate statusDidUpdate:_liveStatus];
        }];
    }
}

- (BOOL)canControl {
    return [self.livePlan canEdit];
}

- (BOOL)isLiveControlledByUser{
    if (_liveStatus && _currentUserId) {
        return [self.liveStatus isControlledByUserId:self.currentUserId];
    }
    return NO;
}

- (BOOL)isLiveActive {
    if (_liveStatus && _sessionServerUserId) {
        return [self.liveStatus isControlledByUserId:self.sessionServerUserId];
    }
    return NO;
}

- (BOOL)hasPreviousServiceTime {
    NSNumber *currentTimeId = nil;

    for (PCOItem *item in [self.livePlan orderedItems]) {
        for (PCOPlanItemTime *planItemTime in [[item planItemTimes] allObjects]) {
            if ([planItemTime.remoteId isEqualToNumber:[self.liveStatus timeId]]) {
                currentTimeId = planItemTime.timeId;
                break;
            }
        }
    }
    if (currentTimeId) {
        for (PCOPlanTime *serviceTime in [self.livePlan orderedServiceTimes]) {
            if ([serviceTime.remoteId isEqualToNumber:currentTimeId] && [[self.livePlan orderedServiceTimes] indexOfObject:serviceTime] > 0) {
                return YES;
            }
        }
    }

    return NO;
}

- (BOOL)hasNextServiceTime {
    NSNumber *currentTimeId = nil;
    
    for (PCOItem *item in [self.livePlan orderedItems]) {
        for (PCOPlanItemTime *planItemTime in [[item planItemTimes] allObjects]) {
            if ([planItemTime.remoteId isEqualToNumber:[self.liveStatus timeId]]) {
                currentTimeId = planItemTime.timeId;
                break;
            }
        }
    }
    if (currentTimeId) {
        for (PCOPlanTime *serviceTime in [self.livePlan orderedServiceTimes]) {
            if ([serviceTime.remoteId isEqualToNumber:currentTimeId]) {
                if ([[self.livePlan orderedServiceTimes] indexOfObject:serviceTime] == [[self.livePlan orderedServiceTimes] count] - 1) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}
- (BOOL)isLiveStatusEnded {
    if (self.liveStatus.type == PCOLiveStatusTypeEnded) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - Pusher Control Methods

- (void)subscribeToLiveChannel {
    if (!_liveChannelName || [self.liveChannelName isEqualToString:@""]) {
        PCOLogError(@"Can't connect to a live channel without a channel name");
        return;
    }
    PTPusherChannel *liveChannel = [self.pusherConnection channelNamed:self.liveChannelName];
    if (!liveChannel) {
        liveChannel = [self.pusherConnection subscribeToChannelNamed:self.liveChannelName];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveChannelEventNotification:) name:PTPusherEventReceivedNotification object:liveChannel];
    }
}

- (void)subscribeToLiveChatChannel {
    PTPusherChannel *liveChatChannel = [self.pusherConnection channelNamed:self.liveChatChannelName];
    if (!liveChatChannel) {
        liveChatChannel = [self.pusherConnection subscribeToChannelNamed:self.liveChatChannelName];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveChannelEventNotification:) name:PTPusherEventReceivedNotification object:liveChatChannel];
    }
}

#pragma mark - PTPusherDelegate Methods

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error {
    PCOLogDebug(@"failedWithError: %@", [error localizedDescription]);
    pusherConnected = NO;
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection {
    PCOLogDebug(@"connectionDidConnect: %@", [connection description]);
    pusherConnected = YES;
    
}
- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect {
    PCOLogDebug(@"connectionDidDisconnect: %@", [connection description]);
    pusherConnected = NO;
    
    if (![PCOServer networkReachable]) {
        // there is no point in trying to reconnect at this point
        
        // start observing the reachability status to see when we come back online
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:MCTReachabilityStatusChangedNotification object:nil];
    }
}

- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay {
    PCOLogDebug(@"connectionWillReconnect");
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error {
    PCOLogDebug(@"didFailToSubscribeToChannel: %@ withError: %@", channel.name, [error localizedDescription]);
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent {
    PCOLogDebug(@"didReceiveErrorEvent: %@", errorEvent.message);
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
    PCOLogDebug(@"didSubscribeToChannel: %@", channel.name);
    
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel {
    PCOLogDebug(@"didUnsubscribeFromChannel: %@", channel.name);
}

- (void)reachabilityChanged:(NSNotification *)note {
    
    if ([PCOServer networkReachable]) {
        // we seem to have some kind of network reachability, so try again
        PTPusher *pusher = self.pusherConnection;
        [pusher connect];
        
        // we can stop observing reachability changes now
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MCTReachabilityStatusChangedNotification object:nil];
        
    }
}

#pragma mark - Pusher Event Handler Method

- (void)didReceiveChannelEventNotification:(NSNotification *)note {
    
    PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
    
//    PCOLogDebug(@"\n\n>>> Pusher Live Event Recieved:\nchannel: %@\nname: %@\ndata: %@\n\n", event.channel, event.name, info);
    
    if ([event.channel isEqualToString:self.liveChannelName] && [event.name isEqualToString:@"goToPlanItemTime"]) {
        [self getLiveStatusWithSuccessCompletion:^(PCOLiveStatus *status) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PCOLiveStateChangedNotification object:nil];
        } errorCompletion:^(NSError *error) {
            
        }];
    }
}

#pragma mark - Lazy Loader Methods

- (PTPusher *)pusherConnection {
    if (!_pusherConnection) {
        _pusherConnection = [PTPusher pusherWithKey:@"6d1601960fdf505090b8" delegate:self encrypted:YES];
        [_pusherConnection connect];
        _pusherConnection.reconnectDelay = 30; // defaults to 5 seconds
        _pusherConnection.delegate = self;
    }
    return _pusherConnection;
}

NSString * const PCOLiveStateChangedNotification = @"PCOLiveStateChangedNotification";

@end
