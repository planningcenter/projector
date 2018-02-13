//
//  P2P_SessionManager.m
//  Music Stand
//
//  Created by Peter Fokos on 5/18/12.
//

#import "P2P_SessionManager.h"
#import "P2P_Device.h"

static P2P_SessionManager *sharedManager = nil;

@implementation P2P_SessionManager {
}

#pragma mark -
#pragma mark - PUBLIC METHODS
#pragma mark -
#pragma mark - Public P2P Control Methods

- (void)createNewServerSession {
    if ([networkManager sessionActive])
    {
        if ([networkManager isServer])
        {
            return;
        }
        else [networkManager closeSessionManager];
    }
    
    [networkManager createP2PServerSession];
    [PCOEventLogger logEvent:@"Sessions - Server session started"];
    
    if ([networkManager sessionActive]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:P2PServerCreatedNotification object:nil];
    }
}

- (void)closeServerSession {
    [networkManager closeServerSession];
}

- (void)createNewClientSession {
    if ([networkManager sessionActive])
    {
        if ([networkManager isClient])
        {
            return;
        }
        else [networkManager closeSessionManager];
    }
    
    [networkManager createP2PClientSession];

    if ([networkManager sessionActive]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:P2PClientCreatedNotification object:nil];
    }
}

- (void)connectToServer:(P2P_Device *)device {
    self.connectedServerDevice = device;
    device.status = P2P_Device_Status_Connecting;
    [networkManager connectToServer:device];
    [PCOEventLogger logEvent:@"Sessions - Client connected to server"];
}

- (void)disconnectFromServer:(P2P_Device *)device {
    [networkManager disconnectFromServer:device];
    self.connectedServerDevice = nil;
    device.status = P2P_Device_Status_NotConnected;
    [[NSNotificationCenter defaultCenter] postNotificationName:P2PSessionDisconnectedNotification object:nil];
}

- (void)closeSessionManager {
    [networkManager closeSessionManager];
}

- (void)resetConnection {
    [networkManager resetConnection];
}

- (void)postNotification:(NSString *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
    });
}

- (void)restartNetworkProtocolManagers {
    [networkManager restartNetworkProtocolManagers];
}

- (void)saveActiveSession {
}

- (void)restoreSavedSession {
}

- (void)clearAvailableServersList {
    [networkManager clearAvailableServersList];
}

#pragma mark - Public Status and Data Methods

- (BOOL)sessionActive {
    return [networkManager sessionActive];
}

- (BOOL)isServer {
    return [networkManager isServer];
}

- (BOOL)isClient {
    return [networkManager isClient];
}

- (BOOL)isConnectedClient {
    BOOL result = NO;
    if ([networkManager isClient] && self.connectedServerDevice) {
        result = YES;
    }
    return result;
}

- (BOOL)isInControl {
    if ([networkManager isServer]) {
        if (self.connectedToAltServerPeerId) {
            return NO;
        }
        return YES;
    }
    else {
        if ([self.connectedToAltServerPeerId isEqualToString:[self displayName]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSearchingClient {
    BOOL result = NO;
    if ([networkManager isClient] && !self.connectedServerDevice) {
            result = YES;
        }
    return result;
}

- (NSString *)peerId {
    return [networkManager peerId];
}

- (NSString *)displayName {
    return [networkManager displayName];
}

- (NSArray *)availableServers {
    return [networkManager availableServers];
}

- (NSArray *)connectedDevices {
    return [networkManager connectedDevices];
}

- (BOOL)isConnectedToDevice:(P2P_Device *)device {
    if (_connectedToAltServerPeerId && [self.connectedServerDevice.peerId isEqualToString:device.peerId]) {
        return YES;
    }
    return NO;
}

- (NSString *)displayNameForPeerId:(NSString *)peerId {
    return [networkManager displayNameForPeerId:peerId];
}

- (NSString *)protocolInitials {
    return [networkManager protocolInitials];
}

- (void)appDidEnterBackground {
    
}

- (void)appDidBecomeActive {
    
}

- (void)controllingIdChanged:(NSString *)peerId {
    
}

#pragma mark - Instance implementation

- (id)init {
	if ((self = [super init]))
	{
        networkManager = [[P2P_Networking_Manager alloc] init];
        networkManager.delegate = self;
	}
    return self;
}

- (void)refresh {
	if (![PCOServer networkReachable]) return;
}

- (void)setControlledByClientPeerId:(NSString *)controlledByClientPeerId {
    if ([self.controlledByClientPeerId isEqualToString:controlledByClientPeerId]) {
        _controlledByClientPeerId = nil;
        [self controllingIdChanged:self.peerId];
    }
    else {
        _controlledByClientPeerId = controlledByClientPeerId;
        [self controllingIdChanged:_controlledByClientPeerId];
    }
    [self postNotification:P2PSessionStateChangedNotification];
}


#pragma mark - Singleton implementation

+ (P2P_SessionManager *)sharedManager {
	@synchronized (self) {
		if (sharedManager == nil) {
			sharedManager = [[self alloc] init];
		}
	}
	
	return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized (self) {
		if (sharedManager == nil) {
			sharedManager = [super allocWithZone:zone];
			return sharedManager;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

#pragma mark -
#pragma mark - P2P_Networking_Manager Delegate Methods
#pragma mark -

- (void)processP2PCommand:(NSArray *)array from:(NSString *)peerId {
    
}

- (void)severSendingPlanToPlay:(NSString *)displayName {
    
}

- (void)connectionWithDisplayNameConnected:(NSString *)displayName {
    
}

- (void)connectionWithDisplayNameDisconnected:(NSString *)displayName {
    
}

- (void)connectionWithDisplayNameDidNotConnect:(NSString *)displayName {
    
}

- (void)serverFoundWithDisplayName:(NSString *)displayName {
    
}

- (void)serverLostWithDisplayName:(NSString *)displayName {
    
}

- (NSString *)productName {
    return _productName;
}

#pragma mark - Private Server/Client Send Methods

- (BOOL)serverSendData:(NSArray *)array {
    BOOL result = NO;

    if (clientCommand)
    {
        clientCommand = NO;
        //        P2PEventLog(@"Client command cleared");
        return YES;
    }

    result = [networkManager serverSendData:array];
    
    return result;
}

- (BOOL)serverSendData:(NSArray *)array toDisplayName:(NSString *)displayName {
    BOOL result = NO;
    
    result = [networkManager serverSendData:array toDisplayName:displayName];
    
    return result;
}

- (BOOL)clientSendData:(NSArray *)array {
    BOOL result = NO;
    
    result = [networkManager serverSendData:array toDisplayName:self.connectedServerDevice.peerId];
    
    return result;
}

- (NSString *)uniqueIdForMessage {
    return [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
}

@end

NSString * const P2PServerCreatedNotification = @"P2PServerCreatedNotification";
NSString * const P2PClientCreatedNotification = @"P2PClientCreatedNotification";
NSString * const P2PLostPeerNotification = @"P2PLostPeerNotification";
NSString * const P2PFoundPeerNotification = @"P2PFoundPeerNotification";
NSString * const P2PSessionConnectedNotification = @"P2PSessionConnectedNotification";
NSString * const P2PSessionDisconnectedNotification = @"P2PSessionDisconnectedNotification";
NSString * const P2PSessionStateChangedNotification = @"P2PSessionStateChangedNotification";
NSString * const P2PSessionReceivedCommandNotification = @"P2PSessionReceivedCommandNotification";
NSString * const P2PSessionClientCouldNotConnectNotification = @"P2PSessionClientCouldNotConnectNotification";
