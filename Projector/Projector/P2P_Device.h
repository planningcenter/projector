//
//  P2P_Device.h
//  Projector
//
//  Created by Peter Fokos on 6/24/14.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, P2P_Device_Status) {
    P2P_Device_Status_NotConnected = 0,
    P2P_Device_Status_Connecting = 1,
    P2P_Device_Status_Connected = 2,
    P2P_Device_Status_Disconnecting = 3,
};

@interface P2P_Device : NSObject <NSCoding>

@property (strong, nonatomic) NSString *operatingSystem;
@property (strong, nonatomic) NSString *protocolName;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *peerId;
@property (strong, nonatomic) NSString *UUID;
@property (strong, nonatomic) NSNumber *orgId;
@property (strong, nonatomic) NSNumber *planId;
@property (nonatomic) P2P_Device_Status status;

@property (strong, nonatomic) id peerIdObject;

+ (P2P_Device*)deviceWithPeerId:(NSString *)peerId;

@end
