//
//  P2P_NetworkingProtocolManager.h
//  Music Stand
//
//  Created by Peter Fokos on 10/3/13.
//

#import <Foundation/Foundation.h>

@class P2P_NetworkingProtocolManager;
@class P2P_Device;

@protocol P2P_NetworkingProtocolManager <NSObject>

@required

- (NSString *)productName;
- (NSDictionary *)getSessionInfo;
- (void)processP2PCommand:(NSArray *)array from:(NSString *)peerId;
- (void)connectionFailed:(P2P_NetworkingProtocolManager *)protocol withPeerID:(NSString *)peerID withError:(NSError *)error;
- (void)connectionDisconnected;
- (void)connectionWithDisplayNameConnected:(NSString *)displayName;
- (void)connectionWithDisplayNameDisconnected:(NSString *)displayName;
- (void)connectionWithDisplayNameDidNotConnect:(NSString *)displayName;
- (void)severSendingPlanToPlay:(NSString *)peerId;
- (void)serverFoundWithDisplayName:(NSString *)displayName;
- (void)serverLostWithDisplayName:(NSString *)displayName;

@end

@interface P2P_NetworkingProtocolManager : NSObject {
    
}

@property (unsafe_unretained) id<P2P_NetworkingProtocolManager> delegate;

- (NSArray *)availableServers;
- (NSArray *)connectedDevices;
- (NSString *)displayNameForPeerId:(NSString *)peerId;
- (void)createServerSession;
- (void)closeServerSession;
- (void)disconnectFromServer:(P2P_Device *)device;
- (void)createClientSession;
- (void)closeSessionManager;
- (BOOL)sendDataToAllPeers:(NSData *)data;
- (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peers;
- (BOOL)sessionActive;
- (NSString *)sessionPeerId;

- (void)connectToServer:(P2P_Device *)device;

- (BOOL)serverSendData:(NSArray *)array;
- (BOOL)serverSendData:(NSArray *)array toPeerId:(NSString *)peerId;
- (BOOL)isServer;
- (BOOL)isClient;
- (NSString *)protocolName;
- (NSString *)protocolInitial;
- (NSString *)peerIdForServerNamed:(NSString *)serverName;
- (void)resetSession;
- (void)resetConnection;

- (void)postNotification:(NSString *)notification;
- (void)clearAvailableServersList;

- (void)restartServerIfStopped;
- (void)reconnectClient;
- (void)applicationDidEnterBackground:(P2P_Device *)device;

@end

