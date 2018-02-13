//
//  P2P_Pusher_Manager.h
//  Music Stand
//
//  Created by Peter Fokos on 8/15/13.
//

#import <Foundation/Foundation.h>
#import "P2P_NetworkingProtocolManager.h"
#import "Pusher.h"

// sent by a server that just connected to the org channel
#define PUSHER_NEW_SERVER_AVAILABLE_EVENT @"NewServerAvailable"

// sent by a client to see what servers are available on the org channel
#define PUSHER_REQUEST_SERVER_ROLLCALL_EVENT @"ServerRollCall"

// sent by a server to see what clients are on the plan channel
#define PUSHER_REQUEST_CLIENT_ROLLCALL_EVENT @"ClientRollCall"

// sent by a client on org or plan channels when client info is requested
#define PUSHER_CLIENT_INFO_EVENT @"ClientInfo"

// sent by a server on org channel when server info is requested
#define PUSHER_SEND_SERVER_INFO_EVENT @"ServerInfo"

// sent by a server when it is closing a session
#define PUSHER_SERVER_CLOSING_SESSION_EVENT @"ServerClosingSession"

// sent by a client when it is disconnecting from a session
#define PUSHER_CLIENT_DISCONNECT_EVENT @"ClientDisconnect"

// sent by server or commanding client with a command dict included
#define PUSHER_P2P_COMMAND_EVENT @"P2PCommand"

typedef enum {
    PusherSessionModeNone,
    PusherSessionModeClientSearching,
	PusherSessionModeServer,
    PusherSessionModeServerSlave,
	PusherSessionModeClient,
    PusherSessionModeClientMaster
} PusherSessionMode;

@interface P2P_Pusher_Manager : P2P_NetworkingProtocolManager <PTPusherDelegate> {
    BOOL pusherConnected;
}

@property (strong, nonatomic) NSMutableArray *availablePusherServers;
@property (strong, nonatomic) NSMutableArray *connectedPusherDevices;
@property (strong, nonatomic) PTPusher *pusherConnection;
@property (strong, nonatomic) NSString *orgChannelName;
@property (strong, nonatomic) NSString *planChannelName;
@property (assign, nonatomic) PusherSessionMode pusherSessionMode;
@property (strong, nonatomic) P2P_Device *connectingToServerDevice;

- (void)subscribeToPlanChannelWithOrgId:(NSString *)orgId planId:(NSString *)planId uuid:(NSString *)uuid;
- (BOOL)serverSendData:(NSDictionary *)dict;

@end
