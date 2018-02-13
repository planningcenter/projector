//
//  P2P_Multipeer_Manager.m
//  Music Stand
//
//  Created by Peter Fokos on 10/22/13.
//

#import "P2P_Multipeer_Manager.h"
#import "P2P_Networking_Manager.h"
#import "P2P_Device.h"
#import "P2P_SessionManager.h"

#define MCSESSION_SERVICE_TYPE_BASE @"mct"

@interface P2P_Multipeer_Manager ()

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) MCPeerID *ourPeerID;
@property (nonatomic, strong) MCSession *activeMCSession;
@property (nonatomic, strong) MCNearbyServiceBrowser *serviceBrowser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *serviceAdvertiser;
@property (nonatomic, strong) NSMutableSet *serversFound;
@property (nonatomic, strong) NSMutableSet *connectedClients;

@property (nonatomic, strong) NSMutableSet *acceptedInvitations;

@end

@implementation P2P_Multipeer_Manager

- (id)initWithDisplayName:(NSString *)displayName {
    self = [super init];
    if (self) {
        if ([displayName lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 63) {
            displayName = [displayName substringToIndex:60];
        }
        _displayName = [NSString stringWithString:displayName];
    }
    return self;
}

#pragma mark - Overridden Base Class Methods

- (void)createServerSession {
    P2PEventLog(@"Starting a MultiPeer server with service type: %@ and displayName: %@", [self ourMCSessionServiceType], self.ourPeerID.displayName);
    if (self.activeMCSession) {
        NSDictionary *discoveryInfo = [self discoveryInfoFromSessionInfo];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            _serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.ourPeerId discoveryInfo:discoveryInfo serviceType:[self ourMCSessionServiceType]];
            _serviceAdvertiser.delegate = self;
            [_serviceAdvertiser startAdvertisingPeer];
        });
    }
}

- (void)applicationDidEnterBackground:(P2P_Device *)device {
    [self resetMultipeerProtocol];
}

- (void)resetMultipeerProtocol {
    [self stopBrowsingForAvailableServers];
    [self stopAdvertisingAsAServer];
    
    [self.activeMCSession disconnect];
    _activeMCSession = nil;

    _connectedClients = nil;
    _ourPeerID = nil;
}

- (void)restartServerIfStopped {
    if ([self isServer]) {
        
    }
    else {
        [self createServerSession];
    }
}

- (NSArray *)availableServers {
    if (!_serviceBrowser) {
        P2PEventLog(@"Starting looking for MultiPeer servers with service type: %@", [self ourMCSessionServiceType]);
        _serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.ourPeerId serviceType:[self ourMCSessionServiceType]];
        _serviceBrowser.delegate = self;
        [_serviceBrowser startBrowsingForPeers];
    }
    P2PEventLog(@"Multipeer Available Servers = %@", [self.serversFound allObjects]);
    return [NSArray arrayWithArray:[self.serversFound allObjects]];
}

- (NSArray *)connectedDevices {
    return [NSArray arrayWithArray:[self.connectedClients allObjects]];
}

- (BOOL)sessionActive {
    if (_activeMCSession) {
        return YES;
    }
    return NO;
}

- (BOOL)isServer {
    if (_activeMCSession && _serviceAdvertiser) {
        return YES;
    }
    return NO;
}

- (BOOL)isClient {
    if (_activeMCSession && _serviceBrowser && !_serviceAdvertiser) {
        return YES;
    }
    return NO;
}

- (NSString *)sessionPeerId {
    if (_activeMCSession) {
        return self.ourPeerId.displayName;
    }
    return @"No MultiPeer Session";
}

- (NSString *)protocolName {
    return @"MultiPeer";
}

- (void)closeServerSession {
    [self.serviceAdvertiser stopAdvertisingPeer];
    self.serviceAdvertiser.delegate = nil;
    _serviceAdvertiser = nil;
    [self.connectedClients removeAllObjects];
    [self.acceptedInvitations removeAllObjects];
}

- (void)closeSessionManager {
    if ([self isServer]) {
        [self closeServerSession];
    }
    else {
        if (_activeMCSession) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
                [self.activeMCSession disconnect];
                _activeMCSession = nil;
            });
        }
    }
}

- (void)stopBrowsingForAvailableServers {
    [self.serviceBrowser stopBrowsingForPeers];
    self.serviceBrowser.delegate = nil;
    _serviceBrowser = nil;
    [self clearAvailableServersList];
}

- (void)stopAdvertisingAsAServer {
    [self.serviceAdvertiser stopAdvertisingPeer];
    self.serviceAdvertiser.delegate = nil;
    _serviceAdvertiser = nil;
}

- (void)resetSession {
    
}

- (void)resetConnection {
    
}

- (void)connectToServer:(P2P_Device *)device {
    MCPeerID *peerID = (MCPeerID *)device.peerIdObject;
    P2PEventLog(@"Requesting connection to server: %@", peerID.displayName);
    P2P_Device *ourDevice = [self deviceFromPeerId:self.ourPeerId discoveryInfo:[self.delegate getSessionInfo]];
    NSData *context = [NSKeyedArchiver archivedDataWithRootObject:ourDevice];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self.serviceBrowser invitePeer:peerID toSession:self.activeMCSession withContext:context timeout:10];
    });
}

- (void)disconnectFromServer:(P2P_Device *)device {
    if (_activeMCSession && device) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            [self.activeMCSession disconnect];
            _activeMCSession = nil;
        });
    }
}

- (NSString *)displayNameForPeerId:(NSString *)peerId {
    NSString *displayName = @"";
    for (P2P_Device *device in self.connectedDevices) {
        if ([peerId isEqualToString:device.peerId]) {
            displayName = device.name;
            break;
        }
    }
    return displayName;
}

- (NSString *)peerIdForServerNamed:(NSString *)serverName {
    for (P2P_Device *server in [self availableServers]) {
        if ([server.name isEqualToString:serverName]) {
            return server.peerId;
        }
    }
    return nil;
}

- (void)clearAvailableServersList {
    _serversFound = nil;
}

#pragma mark - Helper Methods

- (NSDictionary *)discoveryInfoFromSessionInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self.delegate getSessionInfo]];
    NSString *orgId = [PCOCocoaNullToNil([dict objectForKey:@"orgId"]) stringValue];
    if (orgId) {
        [dict setObject:orgId forKey:@"orgId"];
    }
    NSString *planId = [PCOCocoaNullToNil([dict objectForKey:@"planId"]) stringValue];
    if (planId) {
        [dict setObject:planId forKey:@"planId"];
    }
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)ourMCSessionServiceType {
    NSString *serviceType = [NSString stringWithFormat:@"%@-%@", MCSESSION_SERVICE_TYPE_BASE, [self.delegate productName]];
    P2PEventLog(@"MCSession service type: %@", serviceType);
    return serviceType;
}

- (P2P_Device *)deviceFromPeerId:(MCPeerID *)peerID discoveryInfo:(NSDictionary *)info {
    P2P_Device *device = [P2P_Device deviceWithPeerId:peerID.displayName];
    device.peerIdObject = peerID;
    device.protocolName = [self protocolName];
    device.operatingSystem = PCOCocoaNullToNil([info objectForKey:P2P_INFO_DICT_DEVICE_OS_KEY]);
    device.name = PCOCocoaNullToNil([info objectForKey:P2P_INFO_DICT_NAME_KEY]);
    device.UUID = PCOCocoaNullToNil([info objectForKey:P2P_INFO_DICT_UUID_KEY]);
    device.orgId = @([PCOCocoaNullToNil([info objectForKey:P2P_INFO_DICT_ORGID_KEY]) integerValue]);
    device.planId = @([PCOCocoaNullToNil([info objectForKey:P2P_INFO_DICT_PLANID_KEY]) integerValue]);
    return device;
}

- (BOOL)sendDataToAllPeers:(NSData *)data {
    NSError *error = nil;
    return [self.activeMCSession sendData:data toPeers:[self.activeMCSession connectedPeers] withMode:MCSessionSendDataReliable error:&error];
}

- (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peers {
    NSError *error = nil;
    return [self.activeMCSession sendData:data toPeers:peers withMode:MCSessionSendDataReliable error:&error];
}

- (BOOL)serverSendData:(NSArray *)array {
    BOOL result = NO;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    if (_activeMCSession) {
        result = [self sendDataToAllPeers:data];
        P2PEventLog(@"MultiPeer Server sent: %@", array);
    }
    
    return result;
}

- (BOOL)serverSendData:(NSArray *)array toPeerId:(NSString *)peerId {
    BOOL result = NO;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    if (_activeMCSession) {
        for (P2P_Device *device in self.connectedDevices) {
            if ([peerId isEqualToString:device.peerId]) {
                result = [self sendData:data toPeers:@[device.peerIdObject]];
                P2PEventLog(@"MultiPeer Server sent: %@ with result: %d", array, result);
                break;
            }
        }
    }
    
    return result;
}

#pragma mark - Lazy Loader Methods

- (MCPeerID *)ourPeerId {
    if (!_ourPeerID) {
        _ourPeerID = [[MCPeerID alloc] initWithDisplayName:self.displayName];
    }
    return _ourPeerID;
}

- (MCSession *)activeMCSession {
    if (!_activeMCSession) {
        _activeMCSession = [[MCSession alloc] initWithPeer:self.ourPeerId];
        _activeMCSession.delegate = self;
    }
    return _activeMCSession;
}

- (NSMutableSet *)serversFound {
    if (!_serversFound) {
        _serversFound = [[NSMutableSet alloc] init];
    }
    return _serversFound;
}

- (NSMutableSet *)connectedClients {
    if (!_connectedClients) {
        _connectedClients = [[NSMutableSet alloc] init];
    }
    return _connectedClients;
}

- (NSMutableSet *)acceptedInvitations {
    if (!_acceptedInvitations) {
        _acceptedInvitations = [[NSMutableSet alloc] init];
    }
    return _acceptedInvitations;
}

#pragma mark - MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
        case MCSessionStateConnecting:
            P2PEventLog(@"MCSessionStateConnecting to: %@", peerID.displayName);
            break;
            
        case MCSessionStateConnected:
        {
            P2PEventLog(@"MCSessionStateConnected to: %@", peerID.displayName);
            if ([self isServer]) {
                P2P_Device *connectedDevice = nil;
                for (P2P_Device *device in self.acceptedInvitations) {
                    MCPeerID *testPeerID = (MCPeerID *)device.peerIdObject;
                    if ([testPeerID.displayName isEqualToString:peerID.displayName]) {
                        connectedDevice = device;
                        break;
                    }
                }
                if (connectedDevice) {
                    [self.acceptedInvitations removeObject:connectedDevice];
                    [self.connectedClients addObject:connectedDevice];
                    [self postNotification:P2PSessionConnectedNotification];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate connectionWithDisplayNameConnected:peerID.displayName];
            });

            break;
        }
            
        case MCSessionStateNotConnected:
        {
            P2PEventLog(@"MCSessionStateNotConnected to: %@", peerID.displayName);
            if ([self isServer]) {
                P2P_Device *removeDevice = nil;
                for (P2P_Device *device in self.connectedClients) {
                    MCPeerID *testPeerID = (MCPeerID *)device.peerIdObject;
                    if (testPeerID == peerID) {
                        removeDevice = device;
                        break;
                    }
                }
                if (removeDevice) {
                    [self.connectedClients removeObject:removeDevice];
                    [self postNotification:P2PSessionDisconnectedNotification];
                }
                
                removeDevice = nil;
                
                for (P2P_Device *device in self.acceptedInvitations) {
                    MCPeerID *testPeerID = (MCPeerID *)device.peerIdObject;
                    if (testPeerID == peerID) {
                        removeDevice = device;
                        break;
                    }
                }
                if (removeDevice) {
                    [self.acceptedInvitations removeObject:removeDevice];
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self resetMultipeerProtocol];
                    [self.delegate connectionWithDisplayNameDisconnected:peerID.displayName];
                });
            }
            break;
        }
        default:
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    P2PEventLog(@"Did recieve data from: %@", peerID.displayName);
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    P2PEventLog(@"Recieved Data: %@", data);
    P2PEventLog(@"Multipeer recieved command: %@", array);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate processP2PCommand:array from:peerID.displayName];
    });


}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler {
    if (certificateHandler != nil) { certificateHandler(YES); }
}

#pragma mark - MCNearbyServiceAdvertiserDelegate Methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    P2PEventLog(@"Server accepting invitation from: %@", peerID.displayName);
    
    P2P_Device *clientDevice = [NSKeyedUnarchiver unarchiveObjectWithData:context];
    clientDevice.peerIdObject = peerID;
    [self.acceptedInvitations addObject:clientDevice];
    for (MCPeerID *peer in self.activeMCSession.connectedPeers) {
        if ([peer.displayName isEqualToString:peerID.displayName]) {
            P2PEventLog(@"This Peer: %@ is still connected", peerID.displayName);
            return;
        }
    }
    invitationHandler(YES, self.activeMCSession);
}

#pragma mark - MCNearbyServiceBrowserDelegate Methods

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    P2P_Device *device = [self deviceFromPeerId:peerID discoveryInfo:info];
    P2PEventLog(@"Found Server: %@", peerID.displayName);
    if (device) {
        [self.serversFound addObject:device];
// Uncomment to get a fake device added to the available servers
// Use it to test not being able to connect to a device
// or changing servers while in a client session
//        
//        P2P_Device *device2 = [self deviceFromPeerId:peerID discoveryInfo:info];
//        device2.name = @"Fake Server";
//        device2.peerId = @"Fake Peer Id";
//        [self.serversFound addObject:device2];
        [self.delegate serverFoundWithDisplayName:peerID.displayName];
        [self postNotification:P2PFoundPeerNotification];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    P2P_Device *removeThis = nil;
    P2PEventLog(@"Lost Server: %@", peerID.displayName);
    for (P2P_Device *device in self.serversFound) {
        if ([device.peerId isEqualToString:[peerID displayName]]) {
            removeThis = device;
            break;
        }
    }
    if (removeThis) {
        [self.serversFound removeObject:removeThis];
        [self.delegate serverLostWithDisplayName:peerID.displayName];
        [self postNotification:P2PLostPeerNotification];
    }
}

@end
