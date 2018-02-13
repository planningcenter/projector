//
//  P2P_Multipeer_Manager.h
//  Music Stand
//
//  Created by Peter Fokos on 10/22/13.
//

#import "P2P_NetworkingProtocolManager.h"
@import MultipeerConnectivity;

@interface P2P_Multipeer_Manager : P2P_NetworkingProtocolManager <MCSessionDelegate,
MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate> {
}

- (id)initWithDisplayName:(NSString *)displayName;

@end
