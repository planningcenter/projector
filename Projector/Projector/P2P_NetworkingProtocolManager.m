//
//  P2PNetworkingProtocolManager.m
//  Music Stand
//
//  Created by Peter Fokos on 10/3/13.
//

#import "P2P_NetworkingProtocolManager.h"
#import "P2P_Device.h"

@implementation P2P_NetworkingProtocolManager

- (NSArray *)availableServers
{
    return nil;
}

- (NSArray *)connectedDevices
{
    return nil;
}

- (NSString *)displayNameForPeerId:(NSString *)peerId
{
    return nil;
}

- (void)createServerSession
{
    
}

- (void)closeServerSession {

}

- (void)createClientSession
{
    
}

- (void)closeSessionManager
{
    
}

- (BOOL)sendDataToAllPeers:(NSData *)data
{
    return NO;
}

- (BOOL)sendData:(NSData *)data toPeers:(NSArray *)peers
{
    return false;
}

- (BOOL)sessionActive
{
    return false;
}

- (NSString *)sessionPeerId
{
    return nil;
}

- (void)connectToServer:(P2P_Device *)device {
}

- (void)disconnectFromServer:(P2P_Device *)device
{
    
}

- (BOOL)serverSendData:(NSArray *)array
{
    return false;
}

- (BOOL)serverSendData:(NSArray *)array toPeerId:(NSString *)peerId
{
    return false;
}

- (BOOL)isServer
{
    return false;
}

- (BOOL)isClient
{
    return false;
}

- (NSString *)peerIdForServerNamed:(NSString *)serverName
{
    return @"";
}

- (NSString *)protocolName {
    return @"Base";
}

- (NSString *)protocolInitial {
    return [[self protocolName] substringToIndex:1];
}

- (void)resetSession
{
    
}

- (void)resetConnection {
    
}

- (void)clearAvailableServersList {

}

- (void)postNotification:(NSString *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
    });
}

- (void)restartServerIfStopped {
    
}

- (void)reconnectClient {
    
}

- (void)applicationDidEnterBackground:(P2P_Device *)device {
    
}

@end
