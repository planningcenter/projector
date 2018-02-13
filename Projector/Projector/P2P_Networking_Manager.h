//
//  P2P_Networking_Manager.h
//  Music Stand
//
//  Created by Peter Fokos on 8/15/13.
//

#import <Foundation/Foundation.h>
#import "P2P_NetworkingProtocolManager.h"

#define P2P_TIMEOUT_DURATION 30.0

#define P2P_INFO_DICT_DEVICE_OS_KEY @"deviceOS"
#define P2P_INFO_DICT_CONNECTION_TYPE @"connectionType"
#define P2P_INFO_DICT_NAME_KEY @"name"
#define P2P_INFO_DICT_PEERID_KEY @"peerId"
#define P2P_INFO_DICT_UUID_KEY @"uuid"
#define P2P_INFO_DICT_ORGID_KEY @"orgId"
#define P2P_INFO_DICT_PLANID_KEY @"planId"
#define P2P_INFO_DICT_COMMAND_ARRAY_KEY @"commandArray"

#define P2P_MSG_COMMAND_KEY @"command"
#define P2P_MSG_PEER_ID_KEY @"UDID"
#define P2P_MSG_U_ID_KEY @"uid"
#define P2P_MSG_PAGE_KEY @"page"
#define P2P_MSG_ITEM_INDEX_KEY @"itemIndex"
#define P2P_MSG_PLAN_ID_KEY @"planId"
#define P2P_MSG_SERVICE_TYPE_ID_KEY @"serviceTypeId"
#define P2P_MSG_ORG_ID_KEY @"orgId"
#define P2P_MSG_ORG_NAME_KEY @"orgName"
#define P2P_MSG_REFRESH_TYPE_KEY @"refreshType"
#define P2P_MSG_USER_ID_KEY @"userId"

#define LOG_P2P_EVENTS 0
#if LOG_P2P_EVENTS
#define P2PEventLog(msg, ...) PCOLogInfo(msg, ##__VA_ARGS__)
#else
#define P2PEventLog(msg, ...)
#endif

@protocol P2P_Networking_ManagerDelegate <NSObject>

@required

- (NSString *)productName;
- (void)processP2PCommand:(NSArray *)array from:(NSString *)peerId;
- (void)severSendingPlanToPlay:(NSString *)displayName;
- (void)connectionWithDisplayNameConnected:(NSString *)displayName;
- (void)connectionWithDisplayNameDisconnected:(NSString *)displayName;
- (void)connectionWithDisplayNameDidNotConnect:(NSString *)displayName;
- (void)serverFoundWithDisplayName:(NSString *)displayName;
- (void)serverLostWithDisplayName:(NSString *)displayName;

@end


@interface P2P_Networking_Manager : NSObject <P2P_NetworkingProtocolManager>{
}

@property (unsafe_unretained) id<P2P_Networking_ManagerDelegate> delegate;

- (void)restartNetworkProtocolManagers;

- (NSArray *)availableServers;
- (NSArray *)connectedDevices;

- (NSString *)displayName;
- (NSString *)displayNameForPeerId:(NSString *)peerId;
- (NSString *)peerId;

- (void)createP2PServerSession;
- (void)closeServerSession;
- (void)createP2PClientSession;
- (void)closeSessionManager;
- (void)resetConnection;
- (void)connectToServer:(P2P_Device *)device;
- (void)disconnectFromServer:(P2P_Device *)device;
- (NSDictionary *)sessionInfo;

- (BOOL)isServer;
- (BOOL)isClient;
- (BOOL)sessionActive;
- (BOOL)serverSendData:(NSArray *)array;
- (BOOL)serverSendData:(NSArray *)array toDisplayName:(NSString *)displayName;

- (NSString *)protocolInitials;
- (void)clearAvailableServersList;

- (void)restartServerIfStopped;
- (void)reconnectClient;
- (void)applicationDidEnterBackground:(P2P_Device *)device;

@end

