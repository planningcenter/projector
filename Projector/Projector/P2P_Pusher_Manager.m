//
//  P2P_Pusher_Manager.m
//  Music Stand
//
//  Created by Peter Fokos on 8/15/13.
//

#import "P2P_Pusher_Manager.h"
#import "P2P_Networking_Manager.h"
#import "JSONHelpers.h"
#import "PCOOrganization.h"
#import "P2P_SessionManager.h"
#import "PROStateSaver.h"
#import "P2P_Device.h"
#import "PROSlideManager.h"
#import "MCTReachability.h"

@implementation P2P_Pusher_Manager

@synthesize orgChannelName = _orgChannelName;
@synthesize planChannelName = _planChannelName;

- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
    }
    return self;
}

#pragma mark - Overridden Base Class Methods

- (void)createServerSession {
    [self clearConnectedDevices];
    if ([self pusherConnectionPossible]) {
        [self subscribeToPlanChannel];
        self.pusherSessionMode = PusherSessionModeServer;
        P2PEventLog(@"\norgChannelName: %@\nplanChannelName:%@\n", self.orgChannelName, self.planChannelName);
    }
}

- (void)restartServerIfStopped {
    if ([self isServer]) {
        [self clearConnectedDevices];
    }
    else {
        [self createServerSession];
        [self request_ClientRollCall_EventThroughAPI];
    }
}

- (void)createClientSession {
    [self clearPusherServerList];
    if ([self pusherConnectionPossible]) {
        self.pusherSessionMode = PusherSessionModeClientSearching;
        P2PEventLog(@"\norgChannelName: %@\nplanChannelName:%@\n", self.orgChannelName, self.planChannelName);
    }
}

- (NSArray *)availableServers {
    P2PEventLog(@"Pusher Available Servers = %@", self.availablePusherServers);
    return [NSArray arrayWithArray:self.availablePusherServers];
}

- (NSArray *)connectedDevices {
    P2PEventLog(@"Pusher Connected Devices = %@", self.connectedPusherDevices);
    return [NSArray arrayWithArray:self.connectedPusherDevices];
}

- (BOOL)sessionActive {
    if (_pusherConnection && self.orgChannelName) {
        return YES;
    }
    return NO;
}

- (BOOL)isServer {
    BOOL result = NO;
    if (self.pusherConnection && self.pusherSessionMode == PusherSessionModeServer) {
        result = YES;
    }
    return result;
}

- (BOOL)isClient {
    if (self.pusherConnection && (self.pusherSessionMode == PusherSessionModeClient || self.pusherSessionMode == PusherSessionModeServerSlave || self.pusherSessionMode == PusherSessionModeClientSearching)) return YES;
    return NO;
}

- (NSString *)sessionPeerId {
    return [[UIDevice currentDevice] name];
}

- (NSString *)protocolName {
    return @"Pusher";
}

- (void)closeServerSession {
    [self closeSessionManager];
}

- (void)closeSessionManager {
    if ([self isClient]) {
        [self send_ClientDisconnectingSession_EventThroughAPI];
        [self unSubscribeFromPlanChannel];
    }
    else if([self isServer]) {
        [self send_ServerClosingSession_EventThroughAPI];
        [self unSubscribeFromPlanChannel];
        [self resetSession];
    }
}

- (void)resetSession {
    if (_pusherConnection) {
        self.pusherSessionMode = PusherSessionModeClientSearching;
    }
}

- (void)resetConnection {
    _pusherConnection = nil;
    pusherConnected = NO;
    _orgChannelName = nil;
    _planChannelName = nil;
}

- (void)connectToServer:(P2P_Device *)device {
    if (device) {
        NSString *orgId = [device.orgId stringValue];
        NSString *planId = [device.planId stringValue];
        NSString *uuid = device.UUID;
        self.connectingToServerDevice = device;
        if (orgId && planId) {
            [self subscribeToPlanChannelWithOrgId:orgId planId:planId uuid:uuid];
        }
    }
}

- (void)disconnectFromServer:(P2P_Device *)device {
    [self closeSessionManager];
    [self.delegate connectionWithDisplayNameDisconnected:device.peerId];
}

- (NSString *)displayNameForPeerId:(NSString *)peerId {
    for (P2P_Device *server in [self availableServers]) {
        if ([server.peerId isEqualToString:peerId]) {
            return server.name;
        }
    }
    return nil;
}

- (NSString *)peerIdForServerNamed:(NSString *)serverName {
    for (P2P_Device *server in [self availableServers]) {
        if ([serverName isEqualToString:server.name]) {
            return server.peerId;
        }
    }
    return nil;
}

#pragma mark - Helper Methods

- (BOOL)pusherConnectionPossible {
    // if they have an Internet connection then yes
    if ([PCOServer networkReachable]) {
        return YES;
    }
    return NO;
}

- (BOOL)isInControlThroughPusher {
    if (self.pusherSessionMode == PusherSessionModeServer) {
        return YES;
    }
    else if (self.pusherSessionMode == PusherSessionModeClientMaster) {
        return YES;
    }
    return NO;
}

- (BOOL)inPusherClientSearchingMode {
    if (self.pusherConnection && self.pusherSessionMode == PusherSessionModeClientSearching) return YES;
    return NO;
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

- (P2P_Device *)deviceWithPeerId:(NSString *)peerId {
    P2P_Device *newDevice = [P2P_Device deviceWithPeerId:peerId];
    newDevice.operatingSystem = @"iOS";
    newDevice.protocolName = [self protocolName];
    newDevice.name = peerId;
    newDevice.UUID = @"";
    newDevice.orgId = @(0);
    newDevice.planId = @(0);
    return newDevice;
}

#pragma mark - Pusher Channel Methods

- (void)subscribeToOrgChannel {
    PTPusherChannel *orgChannel = [self.pusherConnection channelNamed:self.orgChannelName];
    if (!orgChannel) {
        orgChannel = [self.pusherConnection subscribeToChannelNamed:self.orgChannelName];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveChannelEventNotification:) name:PTPusherEventReceivedNotification object:orgChannel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionStateChangedNotification object:nil];
}

- (void)subscribeToPlanChannelWithOrgId:(NSString *)orgId planId:(NSString *)planId uuid:(NSString *)uuid {
    if (![self pusherConnectionPossible]) return;
    self.planChannelName = [NSString stringWithFormat:@""];
    PTPusherChannel *planChannel = [self.pusherConnection subscribeToChannelNamed:self.planChannelName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveChannelEventNotification:) name:PTPusherEventReceivedNotification object:planChannel];
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionStateChangedNotification object:nil];
}

- (void)subscribeToPlanChannel {
    PCOOrganization *org = [PCOOrganization current];
    PCOPlan *plan = [[PROSlideManager sharedManager] plan];
    
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.planChannelName = [NSString stringWithFormat:@""];
    PTPusherChannel *planChannel = [self.pusherConnection subscribeToChannelNamed:self.planChannelName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveChannelEventNotification:) name:PTPusherEventReceivedNotification object:planChannel];
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionStateChangedNotification object:nil];
}

- (void)unSubscribeFromPlanChannel {
    PTPusherChannel *planChannel = [self.pusherConnection channelNamed:self.planChannelName];
    if (planChannel) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PTPusherEventReceivedNotification object:planChannel];
        [planChannel unsubscribe];
        _planChannelName = nil;
        self.pusherSessionMode = PusherSessionModeClientSearching;
        [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionStateChangedNotification object:nil];
    }
}

- (void)unSubscribeFromOrgChannel {
    PTPusherChannel *orgChannel = [self.pusherConnection channelNamed:self.orgChannelName];
    if (orgChannel) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PTPusherEventReceivedNotification object:orgChannel];
        [orgChannel unsubscribe];
        _orgChannelName = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionStateChangedNotification object:nil];
    }
}

- (void)setPlanChannelName:(NSString *)planChannelName {
    if (_planChannelName && ![_planChannelName isEqualToString:planChannelName]) {
        [[self.pusherConnection channelNamed:_planChannelName] unsubscribe];
        _planChannelName = nil;
    }
    _planChannelName = planChannelName;
}

- (void)setOrgChannelName:(NSString *)orgChannelName {
    if (_orgChannelName && ![_orgChannelName isEqualToString:orgChannelName]) {
        [[self.pusherConnection channelNamed:_orgChannelName] unsubscribe];
        _orgChannelName = nil;
    }
    _orgChannelName = orgChannelName;
}

- (NSString *)channelNameForOrgId:(NSString *)orgId {
    return nil;
}

#pragma mark - Lazy Loader Methods

- (PTPusher *)pusherConnection {
    if (!_pusherConnection) {
        P2PEventLog(@"Creating Pusher Connection");
        _pusherConnection = [PTPusher pusherWithKey:@"" delegate:self encrypted:YES];
        [_pusherConnection connect];
        _pusherConnection.reconnectDelay = 30; // defaults to 5 seconds
        _pusherConnection.delegate = self;
    }
    return _pusherConnection;
}

- (NSMutableArray *)connectedPusherDevices {
    if (!_connectedPusherDevices) {
        _connectedPusherDevices = [[NSMutableArray alloc] init];
    }
    return _connectedPusherDevices;
}

- (NSMutableArray *)availablePusherServers {
    if (!_availablePusherServers) {
        _availablePusherServers = [[NSMutableArray alloc] init];
        if (![self.pusherConnection channelNamed:self.orgChannelName]) {
            [self subscribeToOrgChannel];
            self.pusherSessionMode = PusherSessionModeClientSearching;
        }
    }
    return _availablePusherServers;
}

- (NSString *)orgChannelName {
    if (!_orgChannelName) {
        PCOOrganization *org = [PCOOrganization current];
        _orgChannelName = [self channelNameForOrgId:[org.organizationId stringValue]];
    }
    return _orgChannelName;
}

#pragma mark - PTPusherDelegate Methods

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error {
    P2PEventLog(@"failedWithError: %@", [error localizedDescription]);
    pusherConnected = NO;
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection {
    P2PEventLog(@"connectionDidConnect: %@", [connection description]);
    pusherConnected = YES;
    if (_orgChannelName) {
        [self subscribeToOrgChannel];
    }
    if (_planChannelName) {
        [self subscribeToPlanChannel];
    }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect {
    P2PEventLog(@"connectionDidDisconnect: %@", [connection description]);
    pusherConnected = NO;
    
    [self clearPusherServerList];

    if (_orgChannelName) {
        [self unSubscribeFromOrgChannel];
    }
    
    if (_planChannelName) {
        [self unSubscribeFromPlanChannel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionDisconnectedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:MCTReachabilityStatusChangedNotification object:nil];
}

- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay {
    P2PEventLog(@"connectionWillReconnect");
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error {
    P2PEventLog(@"didFailToSubscribeToChannel: %@ withError: %@", channel.name, [error localizedDescription]);
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent {
    P2PEventLog(@"didReceiveErrorEvent: %@", errorEvent.message);
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
    P2PEventLog(@"didSubscribeToChannel: %@", channel.name);
    
    if ([channel.name isEqualToString:self.orgChannelName]) {
        // we just subscribed to the org channel
        
        if ([self inPusherClientSearchingMode]) {
            // we are a client so ask all the servers in the org channel to send their info
            [self request_ServerRollCall_EventThroughAPI];
        }
        else if ([self isServer]){
            // we are a server so let all org channel subscribers know that a new server is available
            [self send_NewServerAvailable_EventThroughAPI];
        }
    }
    
    if ([channel.name isEqualToString:self.planChannelName]) {
        
        // we just subscribed to a plan channel
        if ([self isClient]) {
            // we are a client so send our info to the server
            [self send_ClientInfo_ToPlanChannel_EventThroughAPI];
            [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionConnectedNotification object:nil];
            self.pusherSessionMode = PusherSessionModeClient;
            [self.delegate connectionWithDisplayNameConnected:self.connectingToServerDevice.peerId];
            _connectingToServerDevice = nil;
        }
        else if ([self isServer]){
            // we are a server so let all org channel subscribers know that a new server is available
            [self send_NewServerAvailable_EventThroughAPI];
        }
    }
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel {
    P2PEventLog(@"didUnsubscribeFromChannel: %@", channel.name);
}

#pragma mark - Pusher Send Server Events Through API Methods

- (void)send_NewServerAvailable_EventThroughAPI {
    // send our server info dictionary to all the device in the org channel
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_NEW_SERVER_AVAILABLE_EVENT channel:self.orgChannelName];
}

- (void)send_ServerClosingSession_EventThroughAPI {
    // tell everyone in the org channel that this server is closing it's session
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_SERVER_CLOSING_SESSION_EVENT channel:self.orgChannelName];
    
    // tell everyone in the plan channel that this server is closing it's session
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_SERVER_CLOSING_SESSION_EVENT channel:self.planChannelName];
}

#pragma mark - Pusher Send Client Events Through API Methods

- (void)request_ServerRollCall_EventThroughAPI {
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_REQUEST_SERVER_ROLLCALL_EVENT channel:self.orgChannelName];
}

- (void)request_ClientRollCall_EventThroughAPI {
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_REQUEST_CLIENT_ROLLCALL_EVENT channel:self.planChannelName];
}

- (void)send_ServerInfo_ToOrgChannel_EventThroughAPI {
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_SEND_SERVER_INFO_EVENT channel:self.orgChannelName];
}

- (void)send_ClientInfo_ToPlanChannel_EventThroughAPI {
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_CLIENT_INFO_EVENT channel:self.planChannelName];
}

- (void)send_ClientDisconnectingSession_EventThroughAPI {
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_CLIENT_DISCONNECT_EVENT channel:self.planChannelName];
    
    [self serverSendPusherData:[self.delegate getSessionInfo] event:PUSHER_CLIENT_DISCONNECT_EVENT channel:self.orgChannelName];
}

- (BOOL)sendDataWithPusher:(NSArray *)data {
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:[self.delegate getSessionInfo]];
    [payload setObject:data forKey:P2P_INFO_DICT_COMMAND_ARRAY_KEY];
    
    [self serverSendPusherData:payload event:PUSHER_P2P_COMMAND_EVENT channel:self.planChannelName];
    return YES;
}

#pragma mark - Pusher Event Handler Method

- (void)didReceiveChannelEventNotification:(NSNotification *)note {
    BOOL isClient = [self isClient];
    BOOL isServer = [self isServer];
    
    PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
    NSDictionary *info = event.data;
    
    P2PEventLog(@"\n\n>>> Pusher Event Recieved:\nchannel: %@\nname: %@\ndata: %@\n\n", event.channel, event.name, event.data);
    
    // Events sent on the ORG channel
    if ([event.channel isEqualToString:self.orgChannelName]) {
        
        if ([event.name isEqualToString:PUSHER_NEW_SERVER_AVAILABLE_EVENT] ||
            [event.name isEqualToString:PUSHER_SEND_SERVER_INFO_EVENT]) {
            [self addDataToPusherServerList:event];
        }
        if ([event.name isEqualToString:PUSHER_SERVER_CLOSING_SESSION_EVENT]) {
            [self removeDataFromPusherServerList:event];
        }
        if (isServer){  // we are a server
            if ([event.name isEqualToString:PUSHER_REQUEST_SERVER_ROLLCALL_EVENT]) {
                [self send_ServerInfo_ToOrgChannel_EventThroughAPI];
            }
        }
    }
    // Events sent on the PLAN channel
    else if ([event.channel isEqualToString:self.planChannelName]) {
        if (isClient) { // client events here
            if ([event.name isEqualToString:PUSHER_SERVER_CLOSING_SESSION_EVENT]) {
                P2PEventLog(@"Pusher server telling plan channel it is closing");
                [self unSubscribeFromPlanChannel];
                [self removeDataFromPusherServerList:event];
                self.pusherSessionMode = PusherSessionModeClientSearching;
                [self.delegate connectionWithDisplayNameDisconnected:[info objectForKey:P2P_INFO_DICT_NAME_KEY]];
            }
            else if ([event.name isEqualToString:PUSHER_REQUEST_CLIENT_ROLLCALL_EVENT]) {
                [self send_ClientInfo_ToPlanChannel_EventThroughAPI];
            }
        }
        else {      // server events here
            if ([event.name isEqualToString:PUSHER_CLIENT_INFO_EVENT]) {
                [self addDataToClientList:event];
                [self.delegate severSendingPlanToPlay:[info objectForKey:P2P_INFO_DICT_NAME_KEY]];
            }
            else if ([event.name isEqualToString:PUSHER_CLIENT_DISCONNECT_EVENT]) {
                [self removeDataFromClientList:event];
            }
            else if ([event.name isEqualToString:PUSHER_SERVER_CLOSING_SESSION_EVENT]) {
                if ([[info objectForKey:P2P_INFO_DICT_UUID_KEY] isEqualToString:[[[UIDevice currentDevice] identifierForVendor] UUIDString]]) {
                    [self unSubscribeFromPlanChannel];
                }
            }
        }
        // pass any command events up the stack and let them determine who should handle
        if ([event.name isEqualToString:PUSHER_P2P_COMMAND_EVENT]) {
            P2PEventLog(@"Got a Pusher P2PCommand: %@", info);
            NSArray *array = [info objectForKey:P2P_INFO_DICT_COMMAND_ARRAY_KEY];
            [self.delegate processP2PCommand:array from:[info objectForKey:P2P_INFO_DICT_NAME_KEY]];
        }
    }
}

#pragma mark - Server Send Data Methods

- (void)serverSendPusherData:(NSDictionary *)data event:(NSString *)event channel:(NSString *)channel {
    if (!event || [event isEqualToString:@""]) {
        P2PEventLog(@"Pusher Event Empty");
        return;
    }
    
    if (!channel || [channel isEqualToString:@""]) {
        P2PEventLog(@"Pusher Channel Name Empty");
        return;
    }
    
    if (!data || [data count] == 0) {
        P2PEventLog(@"Pusher Data Empty");
        return;
    }
    P2PEventLog(@"Sending Pusher Event: %@ on channel: %@ data: %@", event, channel, data);

    NSURL *URL = [NSURL planningCenterBaseURLWithPath:@""];
    NSDictionary *pusherData = @{@"channel": channel,
                                 @"event": event,
                                 @"data": data};
    
    PCOServerRequest *request = [PCOServerRequest requestWithURL:URL];
    request.HTTPMethod = HTTPMethodPost;
    request.offlinePolicy = PCOServerRequestOfflineDiscard;
    [request setJSONBody:pusherData];
    
    [request setCompletion:^(PCOServerResponse *response) {
        if (response.error) {
			PCOLogError(@"Pusher Error %@", [response.error localizedDescription]);
        } else {
			if (![response.HTTPResponse responseOK]) {
				PCOLogError(@"Pusher Connection Error - got response: %d", response.HTTPResponse.statusCode);
			} else {
				P2PEventLog(@"Pusher Connection got response: %d", response.HTTPResponse.statusCode);
			}
        }
    }];
    [request start];
}

- (BOOL)serverSendData:(NSArray *)array toPeerId:(NSString *)peerId {
    BOOL result = NO;
    P2PEventLog(@"Server Sent: %@", array);
    
    if (self.pusherConnection) {
        result = [self sendDataWithPusher:array];
    }
    return result;
}

- (BOOL)serverSendData:(NSArray *)array {
    BOOL result = NO;
    if (self.pusherConnection) {
        result = [self sendDataWithPusher:array];
        P2PEventLog(@"Pusher Server sent this: %@", array);
    }
    return result;
}

#pragma mark - Servers and Clients Managment Methods

- (void)addDataToClientList:(PTPusherEvent *)event {
    NSDictionary *dict = event.data;

    P2P_Device *newClient = [self deviceWithPeerId:[dict objectForKey:P2P_INFO_DICT_NAME_KEY]];
    
    for (P2P_Device *client in [self connectedDevices]) {
        if ([[dict objectForKey:P2P_INFO_DICT_NAME_KEY] isEqualToString:client.name]) {
            return;
        }
    }
    [self.connectedPusherDevices addObject:newClient];
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionConnectedNotification object:nil];
}

- (void)removeDataFromClientList:(PTPusherEvent *)event {
    NSDictionary *dict = event.data;
    NSMutableArray *removeThese = [[NSMutableArray alloc] initWithCapacity:[self.connectedDevices count]];
    
    if (self.connectedPusherDevices) {
        for (P2P_Device *client in [self connectedDevices]) {
            if ([[dict objectForKey:P2P_INFO_DICT_NAME_KEY] isEqualToString:client.name]) {
                [removeThese addObject:client];
            }
        }
        if ([removeThese count] > 0) {
            [self.connectedPusherDevices removeObjectsInArray:removeThese];
            [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionDisconnectedNotification object:nil];
        }
    }
}

- (void)clearConnectedDevices {
    if (self.connectedPusherDevices) {
        [self.connectedPusherDevices removeAllObjects];
    }
}

- (void)addDataToPusherServerList:(PTPusherEvent *)event {
    NSDictionary *dict = event.data;
    if (!self.availablePusherServers) {
        self.availablePusherServers = [[NSMutableArray alloc] init];
    }
    
    P2P_Device *newDevice = [self deviceWithPeerId:[dict objectForKey:P2P_INFO_DICT_NAME_KEY]];
    newDevice.orgId = [dict objectForKey:P2P_INFO_DICT_ORGID_KEY];
    newDevice.planId = [dict objectForKey:P2P_INFO_DICT_PLANID_KEY];
    newDevice.UUID = [dict objectForKey:P2P_INFO_DICT_UUID_KEY];
    
    if ([newDevice.peerId isEqualToString:[self sessionPeerId]]) {
        return;
    }
    
    for (P2P_Device *server in [self availableServers]) {
        if ([newDevice.name isEqualToString:server.name]) {
            return;
        }
    }
    [self.availablePusherServers addObject:newDevice];
    P2PEventLog(@"Available Pusher servers: %@", self.availablePusherServers);
    [self.delegate serverFoundWithDisplayName:newDevice.name];
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PFoundPeerNotification object:nil];
}

- (void)removeDataFromPusherServerList:(PTPusherEvent *)event {
    NSDictionary *dict = event.data;
    NSMutableArray *removeThese = [[NSMutableArray alloc] initWithCapacity:[self.availablePusherServers count]];
    
    if (self.availablePusherServers) {
        for (P2P_Device *server in [self availableServers]) {
            if ([[dict objectForKey:P2P_INFO_DICT_NAME_KEY] isEqualToString:server.name]) {
                [removeThese addObject:server];
            }
        }
        if ([removeThese count] > 0) {
            [self.availablePusherServers removeObjectsInArray:removeThese];
            P2P_Device *removedServer = removeThese[0];
            [self.delegate serverLostWithDisplayName:removedServer.name];
            [[NSNotificationCenter defaultCenter] postNotificationName:P2PLostPeerNotification object:nil];
        }
    }
    P2PEventLog(@"Removed - Pusher available servers: %@", self.availablePusherServers);
}

- (void)clearPusherServerList {
    if (self.availablePusherServers) {
        [self.availablePusherServers removeAllObjects];
        _availablePusherServers = nil;
    }
}

@end
