//
//  PCOLiveStatus.h
//  Projector
//
//  Created by Peter Fokos on 7/24/14.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PCOLiveStatusType) {
    PCOLiveStatusTypeTime           = 0,
    PCOLiveStatusTypePlanItemTime   = 1,
    PCOLiveStatusTypeEnded          = 2,
};

@class PCODateFormatter;

@interface PCOLiveStatus : NSObject

@property (nonatomic) PCOLiveStatusType type;

- (BOOL)isControlled;
- (BOOL)isControlledByUserId:(NSNumber *)userId;
- (BOOL)hasNextServiceTime;
- (BOOL)isEndOfServiceNext;

- (NSNumber *)timeId;
- (NSNumber *)itemId;
- (NSDate *)serviceStartTime;
- (NSString *)formattedServiceStartTime;

- (void)setControlledByName:(NSString *)controlledByName controlledById:(NSNumber *)controlledById;

+ (PCOLiveStatus *)liveStatusFromDictionary:(NSDictionary *)dict;

@end
