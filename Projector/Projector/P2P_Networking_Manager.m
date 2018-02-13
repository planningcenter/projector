//
//  P2P_Networking_Manager.m
//  Music Stand
//
//  Created by Peter Fokos on 8/15/13.
//

#import "P2P_Networking_Manager.h"
#import "PCOOrganization.h"
#import "P2P_GameKIt_Manager.h"
#import "P2P_Multipeer_Manager.h"
#import "P2P_Pusher_Manager.h"
#import "P2P_SessionManager.h"
#import "P2P_Device.h"
#import "PROStateSaver.h"
#import "ProjectorSettings.h"
#import "PROSlideManager.h"

@interface P2P_Networking_Manager ()

@property (strong, nonatomic) NSMutableDictionary *commandCache;
@property (strong, nonatomic) NSMutableArray *protocolMangaers;

@end

@implementation P2P_Networking_Manager

- (id)init {
    self = [super init];
    if (self) {
        [self setupProtocolManagers];
    }
    return self;
}

- (void)setupProtocolManagers {
    [self setupMultipeerProtocol];
    [self setupGameKitProtocol];
    [self setupPusherProtocol];
}

- (void)restartNetworkProtocolManagers {
    [self restartGameKitProtocol];
    [self restartPusherProtocol];
    [self restartMultipeerProtocol];
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionStateChangedNotification object:nil];
}

#pragma mark - GameKit Methods

- (void)setupGameKitProtocol {
    if ([[ProjectorSettings userSettings] useGamekitProtocol]) {
        P2P_GameKIt_Manager *gameKitManager = [[P2P_GameKIt_Manager alloc] init];
        gameKitManager.delegate = self;
        [self.protocolMangaers addObject:gameKitManager];
        P2PEventLog(@"GameKit Session Protocol is on!");
    }
}

- (P2P_NetworkingProtocolManager *)findGameKitProtocol {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if ([protocol isKindOfClass:[P2P_GameKIt_Manager class]]) {
            return protocol;
        }
    }
    return nil;
}

- (void)restartGameKitProtocol {
    P2P_NetworkingProtocolManager *gameKitProtocol = [self findGameKitProtocol];
    
    if ([[ProjectorSettings userSettings] useGamekitProtocol]) {
        if (!gameKitProtocol) {
            [self setupGameKitProtocol];
        }
    }
    else {
        if (gameKitProtocol) {
            [gameKitProtocol closeSessionManager];
            [self.protocolMangaers removeObject:gameKitProtocol];
            P2PEventLog(@"GameKit Session Protocol is off!");
        }
    }
}

#pragma mark - Pusher Methods

- (void)setupPusherProtocol {
    if ([[ProjectorSettings userSettings] usePusherProtocol]) {
        P2P_Pusher_Manager *pusherManager = [[P2P_Pusher_Manager alloc] init];
        pusherManager.delegate = self;
        [self.protocolMangaers addObject:pusherManager];
        P2PEventLog(@"Pusher Session Protocol is on!");
    }
}

- (P2P_NetworkingProtocolManager *)findPusherProtocol {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if ([protocol isKindOfClass:[P2P_Pusher_Manager class]]) {
            return protocol;
        }
    }
    return nil;
}

- (void)restartPusherProtocol {
    P2P_NetworkingProtocolManager *pusherProtocol = [self findPusherProtocol];
    
    if ([[ProjectorSettings userSettings] usePusherProtocol]) {
        if (!pusherProtocol) {
            [self setupPusherProtocol];
        }
    }
    else {
        if (pusherProtocol) {
            [pusherProtocol closeSessionManager];
            [self.protocolMangaers removeObject:pusherProtocol];
            P2PEventLog(@"Pusher Session Protocol is off!");
        }
    }
}

#pragma mark - Multipeer Methods

- (void)setupMultipeerProtocol {
    if ([[ProjectorSettings userSettings] useMultipeerProtocol]) {
        P2P_Multipeer_Manager *multiPeerManager = [[P2P_Multipeer_Manager alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        multiPeerManager.delegate = self;
        [self.protocolMangaers addObject:multiPeerManager];
        P2PEventLog(@"MultiPeer Session Protocol is on!");
    }
}

- (P2P_NetworkingProtocolManager *)findMultipeerProtocol {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if ([protocol isKindOfClass:[P2P_Multipeer_Manager class]]) {
            return protocol;
        }
    }
    return nil;
}

- (void)restartMultipeerProtocol {
    P2P_NetworkingProtocolManager *multipeerProtocol = [self findMultipeerProtocol];
    
    if ([[ProjectorSettings userSettings] useMultipeerProtocol]) {
        if (!multipeerProtocol) {
            [self setupMultipeerProtocol];
        }
    }
    else {
        if (multipeerProtocol) {
            [multipeerProtocol closeSessionManager];
            [self.protocolMangaers removeObject:multipeerProtocol];
            P2PEventLog(@"Multipeer Session Protocol is off!");
        }
    }
}


#pragma mark - Create Methods

- (void)createP2PServerSession {
    [self clearCommandCache];
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol resetSession];
        [protocol createServerSession];
    }
}

- (void)createP2PClientSession {
    [self clearCommandCache];
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol resetSession];
        [protocol createClientSession];
    }
}

#pragma mark - Connection Methods

- (void)connectToServer:(P2P_Device *)device {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if (device.peerId) {
            [protocol connectToServer:device];
        }
    }
}

- (void)disconnectFromServer:(P2P_Device *)device {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if (device) {
            [protocol disconnectFromServer:device];
        }
    }
}

- (void)closeSessionManager {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol closeSessionManager];
    }
    [self postNotification:P2PSessionDisconnectedNotification];
    [self clearCommandCache];
}

- (void)resetConnection {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol resetConnection];
    }
}

- (void)closeServerSession {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol closeServerSession];
    }
}

- (void)restartServerIfStopped {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol restartServerIfStopped];
    }
}

- (void)reconnectClient {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol reconnectClient];
    }
}

-(void)applicationDidEnterBackground:(P2P_Device *)device {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol applicationDidEnterBackground:device];
    }
}

#pragma mark - Get Data Methods

- (NSArray *)availableServers {
//    P2PEventLog(@"Generating Available Servers!");
    
    NSMutableArray *allServers = [NSMutableArray array];
    
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        NSArray *servers = [protocol availableServers];
        for (P2P_Device *newServer in servers) {
            BOOL addNewServer = YES;
            for (P2P_Device *existingServer in allServers) {
                if ([newServer.name isEqualToString:existingServer.name]) {
                    addNewServer = NO;
                    break;
                }
            }
            if (addNewServer) {
                [allServers addObject:newServer];
            }
        }
    }
    
//    P2PEventLog(@"allServers: %@", allServers);
    return allServers;
}

- (NSArray *)connectedDevices {
//    P2PEventLog(@"Generating Connected Devices!");
    
    NSMutableArray *allDevices = [NSMutableArray array];
    
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        NSArray *devices = [protocol connectedDevices];
        for (P2P_Device *newDevice in devices) {
            BOOL addNewDevice = YES;
            for (P2P_Device *existingDevice in allDevices) {
                if ([newDevice.name isEqualToString:existingDevice.name]) {
                    addNewDevice = NO;
                    break;
                }
            }
            if (addNewDevice) {
                [allDevices addObject:newDevice];
            }
        }
    }
    
//    P2PEventLog(@"allDevices: %@", allDevices);
    return allDevices;
}

- (NSString *)displayNameForPeerId:(NSString *)peerId {
    NSString *displayName = nil;
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        displayName = [protocol displayNameForPeerId:peerId];
        if (displayName) {
            break;
        }
    }
    return displayName;
}

- (NSString *)peerIdOfAvailableServerNamed:(NSString *)serverName {
    for (P2P_Device *server in [self availableServers]) {
        if ([server.name isEqualToString:serverName]) {
            return server.peerId;
        }
    }
    return @"Session name not found";
}

- (NSString *)peerIdOfConnectedDeviceNamed:(NSString *)displayName {
    for (P2P_Device *device in [self connectedDevices]) {
        if ([device.name isEqualToString:displayName]) {
            return device.peerId;
        }
    }
    return @"Display Name not found";
}

- (NSString *)displayName {
    return [[self sessionInfo] objectForKey:P2P_INFO_DICT_NAME_KEY];
}

- (NSString *)peerId {
    return [[self sessionInfo] objectForKey:P2P_INFO_DICT_PEERID_KEY];
}

- (NSDictionary *)sessionInfo {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if ([protocol sessionActive]) {
            PCOOrganization *org = [PCOOrganization current];
            PCOPlan *plan = [[PROSlideManager sharedManager] plan];
            NSString *peerId = [protocol sessionPeerId];
            
            NSDictionary *info = @{P2P_INFO_DICT_DEVICE_OS_KEY: @"iOS",
                                   P2P_INFO_DICT_CONNECTION_TYPE: [protocol protocolName],
                                   P2P_INFO_DICT_NAME_KEY: [[UIDevice currentDevice] name],
                                   P2P_INFO_DICT_PEERID_KEY: peerId,
                                   P2P_INFO_DICT_UUID_KEY: [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                                   P2P_INFO_DICT_ORGID_KEY: PCOSafe(org.organizationId),
                                   P2P_INFO_DICT_PLANID_KEY: PCOSafe(plan.remoteId)
                                   };
            P2PEventLog(@"Server Info: %@", info);
            return info;
        }
    }
    return nil;
}

- (NSDictionary *)rawSessionInfo {
    PCOOrganization *org = [PCOOrganization current];
    PCOPlan *plan = [[PROSlideManager sharedManager] plan];
    NSDictionary *info = @{P2P_INFO_DICT_DEVICE_OS_KEY: @"iOS",
                           P2P_INFO_DICT_NAME_KEY: [[UIDevice currentDevice] name],
                           P2P_INFO_DICT_UUID_KEY: [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                           P2P_INFO_DICT_ORGID_KEY: PCOSafe(org.organizationId),
                           P2P_INFO_DICT_PLANID_KEY: PCOSafe(plan.remoteId)
                           };
    P2PEventLog(@"Raw Session Info: %@", info);
    return info;
}

#pragma mark - Get Status Methods

- (BOOL)isServer {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if ([protocol sessionActive] && [protocol isServer]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isClient {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if ([protocol sessionActive] && [protocol isClient]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)sessionActive {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        if ([protocol sessionActive]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)protocolInitials {
    NSString *initials = @"";

    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        initials = [NSString stringWithFormat:@"%@%@", initials, [protocol protocolInitial]];
    }

    return initials;
}

#pragma mark - Lazy Loader Methods

- (NSMutableArray *)protocolMangaers {
    if (!_protocolMangaers) {
        _protocolMangaers = [[NSMutableArray alloc] init];
    }
    return _protocolMangaers;
}

- (NSMutableDictionary *)commandCache {
    if (!_commandCache) {
        _commandCache = [[NSMutableDictionary alloc] init];
    }
    return _commandCache;
}

#pragma mark - Helper Methods

- (void)clearCommandCache {
    [self.commandCache removeAllObjects];
}

- (BOOL)commandUnique:(NSArray *)array {
    BOOL result = YES;
    
    if (!array) {
        // bad data should cause it to ignore the command
        return NO;
    }
    
    if ([[array lastObject] isKindOfClass:[NSString class]]) {
        NSString *uid = [array lastObject];
        
        if (!uid) {
            // bad data should cause it to ignore the command
            return NO;
        }
        
        if ([self.commandCache objectForKey:uid]) {
            NSUInteger count = [[self.commandCache objectForKey:uid] integerValue] + 1;
            if (count == [[self protocolMangaers] count]) {
                // since we now have recieved all copies of this command remove it from the cache
                P2PEventLog(@"REMOVING THE COMMAND FROM THE CACHE");
                [self.commandCache removeObjectForKey:uid];
            }
            else {
                // save the new count
                P2PEventLog(@"Got a dup!!!!");
                [self.commandCache setValue:@(count) forKey:uid];
            }
            result = NO;
        }
        else {
            [self.commandCache setValue:@(1) forKey:uid];
            result = YES;
        }

    }
    return result;
}

- (void)postNotification:(NSString *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
    });
}

- (void)clearAvailableServersList {
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        [protocol clearAvailableServersList];
    }
}

#pragma mark - Server Send Methods

- (BOOL)serverSendData:(NSArray *)array {
    BOOL result = YES;
    
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        result = [protocol serverSendData:array];
    }

    return result;
}

- (BOOL)serverSendData:(NSArray *)array toDisplayName:(NSString *)displayName {
    BOOL result = NO;
    
    P2PEventLog(@"Server Sent: %@", array);
    
    for (P2P_NetworkingProtocolManager *protocol in self.protocolMangaers) {
        NSString *peerId = [self peerIdOfConnectedDeviceNamed:displayName];
        result = [protocol serverSendData:array toPeerId:peerId];
    }

    return result;
}

#pragma mark - P2P_NetworkingProtocolManager Delegate Methods

- (NSString *)productName {
    return [self.delegate productName];
}

-(void)processP2PCommand:(NSArray *)array from:(NSString *)displayName {
    if (![self commandUnique:array]) {
        // we have already recieved this command so ignore it
        
        P2PEventLog(@"Ignoring this command as a dup: %@", array);
        return;
    }
    [self.delegate processP2PCommand:array from:displayName];
}

- (void)connectionFailed:(P2P_NetworkingProtocolManager *)protocol withPeerID:(NSString *)peerID withError:(NSError *)error {
    //        [self closeSession];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:P2P_STATE_CHANGED object:nil];
    NSString *failMsg = [NSString stringWithFormat:@"Could not connect to %@", [protocol displayNameForPeerId:peerID]];
    UIAlertView * sessionClientAlert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:failMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [sessionClientAlert show];
}

- (NSDictionary *)getSessionInfo {
    return [self rawSessionInfo];
}

- (void)severSendingPlanToPlay:(NSString *)displayName {
    [self.delegate severSendingPlanToPlay:displayName];
}

- (void)connectionDisconnected {
    
}

- (void)connectionWithDisplayNameConnected:(NSString *)displayName {
    [self.delegate connectionWithDisplayNameConnected:displayName];
}

- (void)connectionWithDisplayNameDisconnected:(NSString *)displayName {
    [self.delegate connectionWithDisplayNameDisconnected:displayName];
}

- (void)connectionWithDisplayNameDidNotConnect:(NSString *)displayName {
    [self.delegate connectionWithDisplayNameDidNotConnect:displayName];
}

-(void)serverFoundWithDisplayName:(NSString *)displayName {
    [self.delegate serverFoundWithDisplayName:displayName];
}

- (void)serverLostWithDisplayName:(NSString *)displayName {
    [self.delegate serverLostWithDisplayName:displayName];
}

@end
