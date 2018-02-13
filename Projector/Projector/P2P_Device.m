//
//  P2P_Device.m
//  Projector
//
//  Created by Peter Fokos on 6/24/14.
//

#import "P2P_Device.h"

@implementation P2P_Device

- (id)initWithWithPeerId:(NSString *)peerId {
	self = [super init];
	if (self) {
        _peerId = peerId;
        _status = P2P_Device_Status_NotConnected;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.operatingSystem = [decoder decodeObjectForKey:@"operatingSystem"];
        self.protocolName = [decoder decodeObjectForKey:@"protocolName"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.peerId = [decoder decodeObjectForKey:@"peerId"];
        self.UUID = [decoder decodeObjectForKey:@"UUID"];
        self.orgId = [decoder decodeObjectForKey:@"orgId"];
        self.planId = [decoder decodeObjectForKey:@"planId"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.operatingSystem forKey:@"operatingSystem"];
    [aCoder encodeObject:self.protocolName forKey:@"protocolName"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.peerId forKey:@"peerId"];
    [aCoder encodeObject:self.UUID forKey:@"UUID"];
    [aCoder encodeObject:self.orgId forKey:@"orgId"];
    [aCoder encodeObject:self.planId forKey:@"planId"];
}

+ (P2P_Device*)deviceWithPeerId:(NSString *)peerId {
    P2P_Device *device = [[P2P_Device alloc] initWithWithPeerId:peerId];
    return device;
}

@end
