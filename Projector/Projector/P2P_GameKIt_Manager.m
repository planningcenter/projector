//
//  P2P_GameKIt_Manager.m
//  Music Stand
//
//  Created by Peter Fokos on 8/15/13.
//

#import "P2P_GameKIt_Manager.h"
#import "P2P_Networking_Manager.h"
#import "P2P_SessionManager.h"
#import "P2P_Device.h"

@interface P2P_GameKIt_Manager ()

@property (nonatomic, strong) GKSession *activeGKSession;

@end

@implementation P2P_GameKIt_Manager

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
    }
    return self;
}

#pragma mark - Overridden Base Class Methods

- (void)createServerSession {
    P2PEventLog(@"Starting a Gamekit server with sessionID: %@ and displayName: %@", [self.delegate productName], [[UIDevice currentDevice] name]);
    self.activeGKSession = [[GKSession alloc] initWithSessionID:[self.delegate productName] displayName:[[UIDevice currentDevice] name] sessionMode:GKSessionModeServer];
    self.activeGKSession.delegate = self;
    [self.activeGKSession setDataReceiveHandler:self withContext:nil];
    self.activeGKSession.available = YES;
}

- (void)createClientSession {
    P2PEventLog(@"Starting a Gamekit client with sessionID: %@ and displayName: %@", [self.delegate productName], [[UIDevice currentDevice] name]);
    self.activeGKSession = [[GKSession alloc] initWithSessionID:[self.delegate productName] displayName:[[UIDevice currentDevice] name] sessionMode:GKSessionModeClient];
    self.activeGKSession.delegate = self;
    [self.activeGKSession setDataReceiveHandler:self withContext:nil];
    self.activeGKSession.available = YES;
}

- (NSArray *)availableServers {
    NSMutableArray *allServers = nil;
    
    if (!_activeGKSession) {
        [self createClientSession];
    }
    
    if (self.activeGKSession.sessionMode == GKSessionModeClient) {
        NSArray *availableServers = [self.activeGKSession peersWithConnectionState:GKPeerStateAvailable];
        NSArray *connectedServers = [self.activeGKSession peersWithConnectionState:GKPeerStateConnected];
        
        allServers = [[NSMutableArray alloc] init];
        
        for (NSString *peerId in availableServers) {
            if (![[self.activeGKSession displayNameForPeer:peerId] isEqualToString:[self.activeGKSession displayNameForPeer:[self.activeGKSession peerID]]]) {
                P2P_Device *newDevice = [self deviceWithPeerId:peerId];
                [allServers addObject:newDevice];
            }
        }
    
        for (NSString *peerId in connectedServers) {
            P2P_Device *newDevice = [self deviceWithPeerId:peerId];
            [allServers addObject:newDevice];
        }

    }
    P2PEventLog(@"GK Available Servers = %@", allServers);
    
    return [NSArray arrayWithArray:allServers];
}

- (NSArray *)connectedDevices {
    NSMutableArray *connectedDevices = nil;
    if (self.activeGKSession.sessionMode == GKSessionModeServer) {
        NSArray *gkDevices = [self.activeGKSession peersWithConnectionState:GKPeerStateConnected];
        connectedDevices = [[NSMutableArray alloc] initWithCapacity:[gkDevices count]];
        
        for (NSString *peerId in gkDevices) {
            P2P_Device *newDevice = [self deviceWithPeerId:peerId];
            [connectedDevices addObject:newDevice];
        }
    }
    P2PEventLog(@"GK Connected Devices = %@", connectedDevices);
    
    return [NSArray arrayWithArray:connectedDevices];
}

- (BOOL)sessionActive {
    if (_activeGKSession) {
        return YES;
    }
    return NO;
}

- (BOOL)isServer {
    BOOL result = NO;
    if (_activeGKSession && self.activeGKSession.sessionMode == GKSessionModeServer) {
        result = YES;
    }
    return result;
}

- (BOOL)isClient {
    BOOL result = NO;
    if (_activeGKSession && self.activeGKSession.sessionMode == GKSessionModeClient) {
        result = YES;
    }
    return result;
}

- (NSString *)sessionPeerId {
    if (self.activeGKSession) {
        return self.activeGKSession.peerID;
    }
    return @"No GameKit Session";
}

- (NSString *)protocolName {
    return @"GameKit";
}

- (void)closeServerSession {
    [self closeSessionManager];
    [self createClientSession];
}

- (void)closeSessionManager {
    if (self.activeGKSession) {
        [self.activeGKSession disconnectFromAllPeers];
        self.activeGKSession.available = NO;
        [self.activeGKSession setDataReceiveHandler:nil withContext:nil];
        [self.activeGKSession setDelegate:nil];
        self.activeGKSession = nil;
        P2PEventLog(@"GK Session closed");
    }
}

- (void)resetSession {
    if (_activeGKSession) {
        
    }
}

- (void)resetConnection {
    
}

- (void)connectToServer:(P2P_Device *)device {
    if (self.activeGKSession) {
        for (P2P_Device *server in [self availableServers]) {
            if ([server.peerId isEqualToString:device.peerId]) {
                P2PEventLog(@"GK Connect to peerId: %@", device.peerId);
                [self.activeGKSession connectToPeer:device.peerId withTimeout:P2P_TIMEOUT_DURATION];
                return;
            }
        }
        P2PEventLog(@"GK Could not find server with peerId: %@", device.peerId);
        return;
    }
    P2PEventLog(@"GK Session not active");
}

- (void)disconnectFromServer:(P2P_Device *)device {
    if (self.activeGKSession) {
        [self.activeGKSession disconnectFromAllPeers];
        self.activeGKSession.available = YES;
    }
}

- (NSString *)displayNameForPeerId:(NSString *)peerId {
    return [self.activeGKSession displayNameForPeer:peerId];
}

- (NSString *)peerIdForServerNamed:(NSString *)serverName {
    for (P2P_Device *server in [self availableServers]) {
        if ([server.name isEqualToString:serverName]) {
            return server.peerId;
        }
    }
    return nil;
}

- (void)restartServerIfStopped {
    [self closeSessionManager];
    [self createServerSession];
    [self postNotification:P2PSessionConnectedNotification];
}

#pragma mark - Helper Methods

- (P2P_Device *)deviceWithPeerId:(NSString *)peerId {
    P2P_Device *newDevice = [P2P_Device deviceWithPeerId:peerId];
    newDevice.operatingSystem = @"iOS";
    newDevice.protocolName = [self protocolName];
    newDevice.name = [self displayNameForPeerId:peerId];
    newDevice.UUID = @"";
    newDevice.orgId = @(0);
    newDevice.planId = @(0);
    return newDevice;
}

- (BOOL)sendDataToAllPeers:(NSData *)data {
    NSError *error = nil;
    return [self.activeGKSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
}

- (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peers {
    NSError *error = nil;
    return [self.activeGKSession sendData:data toPeers:peers withDataMode:GKSendDataReliable error:&error];
}

- (BOOL)serverSendData:(NSArray *)array {
    BOOL result = NO;
        
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    if (_activeGKSession) {
        result = [self sendDataToAllPeers:data];
        P2PEventLog(@"GK Server sent: %@", array);

    }

    return result;
}

- (BOOL)serverSendData:(NSArray *)array toPeerId:(NSString *)peerId {
    BOOL result = NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    P2PEventLog(@"GK Server Sent: %@ to PeerId: %@", array, peerId);
    
    if (_activeGKSession) {
        result = [self sendDataToAllPeers:data];
    }
    return result;
}

#pragma mark - Game Kit GKSessionDelegate Methods

- (void)session:(GKSession *)session peer:(NSString *)peerId didChangeState:(GKPeerConnectionState)state {
    //  GKPeerStateAvailable,    // not connected to session, but available for connectToPeer:withTimeout:
    //	GKPeerStateUnavailable,  // no longer available
    //	GKPeerStateConnected,    // connected to the session
    //	GKPeerStateDisconnected, // disconnected from the session
    //	GKPeerStateConnecting,   // waiting for accept, or deny response
    
    NSString *displayName = [session displayNameForPeer:peerId];
    
    switch (state) {
        case GKPeerStateAvailable:
        {
            P2PEventLog(@"GK Available - %@", displayName);
            [self.delegate serverFoundWithDisplayName:displayName];
            [self postNotification:P2PFoundPeerNotification];
            break;
        }
        case GKPeerStateUnavailable:
        {
            P2PEventLog(@"GK Unavailable - %@", displayName);
            [self.delegate serverLostWithDisplayName:displayName];
            [self postNotification:P2PLostPeerNotification];
            break;
        }
        case GKPeerStateConnected:
        {
            P2PEventLog(@"GK Connected - %@", displayName);
            if (self.activeGKSession.sessionMode == GKSessionModeClient)
            {
                self.activeGKSession.available = NO;
                
                [self postNotification:P2PSessionConnectedNotification];
            }
            else if (self.activeGKSession.sessionMode == GKSessionModeServer)
            {
                [self.delegate severSendingPlanToPlay:displayName];
                [self postNotification:P2PSessionConnectedNotification];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate connectionWithDisplayNameConnected:displayName];
            });
            break;
        }
        case GKPeerStateDisconnected:
        {
            P2PEventLog(@"GK Disconnected - %@", displayName);
            [self.delegate connectionWithDisplayNameDisconnected:displayName];
            break;
        }
        case GKPeerStateConnecting:
        {
            P2PEventLog(@"GK Connecting - %@", displayName);
            break;
        }
    }
    P2PEventLog(@"GK Session State = %d", state);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSError *error = nil;
    
    P2PEventLog(@"GK Client requests connection - %@", [session displayNameForPeer:peerID]);
    
    if ([session acceptConnectionFromPeer:peerID error:&error])
    {
        P2PEventLog(@"GK Client connection accepted - %@", [session displayNameForPeer:peerID]);
        [self postNotification:P2PSessionConnectedNotification];
    }
    else {
        P2PEventLog(@"GK Client request failed - %@ with error - %@", [session displayNameForPeer:peerID], [error localizedDescription]);
        [self postNotification:P2PSessionDisconnectedNotification];
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    P2PEventLog(@"GK Client connection failed - %@ with error - %@", [session displayNameForPeer:peerID], [error localizedDescription]);
    if ([[error.userInfo objectForKey:NSLocalizedFailureReasonErrorKey] isEqualToString:@"Already in progress."]) {
        [self.delegate connectionWithDisplayNameConnected:[self.activeGKSession displayNameForPeer:peerID]];
    }
    else {
        if ([self isClient]) {
            [self.delegate connectionFailed:self withPeerID:peerID withError:error];
        }
    }
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    P2PEventLog(@"GKSession didFailWithError: %@", [error localizedDescription]);
    [self postNotification:P2PSessionDisconnectedNotification];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    P2PEventLog(@"GK recieved data: %@", data);
    P2PEventLog(@"GK recieved command: %@", array);
    [self.delegate processP2PCommand:array from:[session displayNameForPeer:peer]];
}

#pragma GCC diagnostic warning "-Wdeprecated-declarations"

@end
