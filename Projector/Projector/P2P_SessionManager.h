//
//  P2P_SessionManager.h
//  Music Stand
//
//  Created by Peter Fokos on 5/18/12.
//

#import <Foundation/Foundation.h>
#import "P2P_Networking_Manager.h"

@class P2P_Device;

PCO_EXTERN_STRING P2PServerCreatedNotification;
PCO_EXTERN_STRING P2PClientCreatedNotification;
PCO_EXTERN_STRING P2PLostPeerNotification;
PCO_EXTERN_STRING P2PFoundPeerNotification;
PCO_EXTERN_STRING P2PSessionConnectedNotification;
PCO_EXTERN_STRING P2PSessionDisconnectedNotification;
PCO_EXTERN_STRING P2PSessionStateChangedNotification;
PCO_EXTERN_STRING P2PSessionReceivedCommandNotification;
PCO_EXTERN_STRING P2PSessionClientCouldNotConnectNotification;

@interface P2P_SessionManager : NSObject <P2P_Networking_ManagerDelegate> {
    P2P_Networking_Manager *networkManager;
    BOOL wasLoadPlan;
    BOOL clientCommand;
}

@property (strong, nonatomic) NSString *productName;
//@property (strong, nonatomic) NSString *connectedToServerPeerId;
//@property (strong, nonatomic) NSString *connectedToServerDisplayName;
@property (strong, nonatomic) NSString *connectedToAltServerPeerId;
@property (strong, nonatomic) NSString *controlledByClientPeerId;

@property (strong, nonatomic) P2P_Device *connectedServerDevice;

@property (assign, nonatomic) NSInteger refreshTypeID;

- (void)createNewServerSession;
- (void)closeServerSession;

- (void)createNewClientSession;

- (void)closeSessionManager;
- (void)resetConnection;

- (BOOL)serverSendData:(NSArray *)array;
- (BOOL)serverSendData:(NSArray *)array toDisplayName:(NSString *)displayName;

- (BOOL)clientSendData:(NSArray *)array;

- (void)connectToServer:(P2P_Device *)device;
- (void)disconnectFromServer:(P2P_Device *)device;

- (BOOL)sessionActive;
- (BOOL)isServer;
- (BOOL)isClient;
- (BOOL)isConnectedClient;
- (BOOL)isSearchingClient;
- (BOOL)isInControl;

- (BOOL)isConnectedToDevice:(P2P_Device *)device;

- (NSString *)peerId;

- (NSArray *)availableServers;
- (NSArray *)connectedDevices;

- (NSString *)uniqueIdForMessage;

- (void)postNotification:(NSString *)notification;

- (NSString *)protocolInitials;

- (void)restartNetworkProtocolManagers;

- (void)saveActiveSession;
- (void)restoreSavedSession;
- (void)clearAvailableServersList;

- (void)appDidEnterBackground;
- (void)appDidBecomeActive;

- (void)controllingIdChanged:(NSString *)peerId;

// global class methods
+ (P2P_SessionManager *)sharedManager;

@end
