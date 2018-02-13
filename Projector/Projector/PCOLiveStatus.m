//
//  PCOLiveStatus.m
//  Projector
//
//  Created by Peter Fokos on 7/24/14.
//

#import "PCOLiveStatus.h"
#import "PCODateFormatter.h"

#define PCOLIVE_START_DATE_FORMAT @"yyyy/MM/dd HH:mm:ss"
#define PCOLIVE_JUST_DATE_FORMAT @"MM/dd"
#define PCOLIVE_JUST_TIME_FORMAT @"hh:mm a"

@interface PCOLiveStatus ()

@property (strong, nonatomic) NSString *controlledBy;
@property (strong, nonatomic) NSNumber *controlledById;
@property (strong, nonatomic) NSNumber *statusId;
@property (strong, nonatomic) NSNumber *itemId;
@property (strong, nonatomic) NSNumber *nextItemId;
@property (strong, nonatomic) NSNumber *nextId;
@property (strong, nonatomic) NSString *scheduledStart;
@property (strong, nonatomic) NSString *startsAt;
@property (nonatomic, strong) NSDateFormatter *startDateFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation PCOLiveStatus

- (id)initWithStatusDictionary:(NSDictionary *)dict {
	self = [super init];
	if (self) {
		_controlledBy = [self stringInDictionary:dict atKey:@"controlled_by"];
		_controlledById = [self numberInDictionary:dict atKey:@"controlled_by_id"];
        
        if ([[self stringInDictionary:dict atKey:@"type"] isEqualToString:@"Time"]) {
            _type = PCOLiveStatusTypeTime;
        }
        else if([[self stringInDictionary:dict atKey:@"type"] isEqualToString:@"PlanItemTime"]) {
            _type = PCOLiveStatusTypePlanItemTime;
        }
        else {
            _type = PCOLiveStatusTypeEnded;
        }
        
		_statusId = [self numberInDictionary:dict atKey:@"id"];
		_itemId = [self numberInDictionary:dict atKey:@"item_id"];
        _nextItemId = [self numberInDictionary:dict atKey:@"next_item_id"];
        _nextId = [self numberInDictionary:dict atKey:@"next_id"];
        _scheduledStart = [self stringInDictionary:dict atKey:@"scheduled_start"];
        _startsAt = [self stringInDictionary:dict atKey:@"starts_at"];
        
        _startDateFormatter = [[NSDateFormatter alloc] init];
        [_startDateFormatter setDateFormat:PCOLIVE_START_DATE_FORMAT];
        _startDateFormatter.locale = [NSLocale currentLocale];

        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:PCOLIVE_JUST_DATE_FORMAT];
        _dateFormatter.locale = [NSLocale currentLocale];

        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:PCOLIVE_JUST_TIME_FORMAT];
        _timeFormatter.locale = [NSLocale currentLocale];

	}
	return self;
}

- (NSNumber *)numberInDictionary:(NSDictionary *)Dictionary atKey:(NSString *)key {
    if ([[Dictionary objectForKey:key] isKindOfClass:[NSNumber class]]) {
        return [Dictionary objectForKey:key];
    }
    return nil;
}

- (BOOL)boolInDictionary:(NSDictionary *)Dictionary atKey:(NSString *)key {
    if ([[Dictionary objectForKey:key] isKindOfClass:[NSNumber class]]) {
        return [[Dictionary objectForKey:key] boolValue];
    }
    return NO;
}

- (NSString *)stringInDictionary:(NSDictionary *)Dictionary atKey:(NSString *)key {
    if ([[Dictionary objectForKey:key] isKindOfClass:[NSString class]]) {
        return [Dictionary objectForKey:key];
    }
    return @"";
}

- (BOOL)isControlled {
    if (self.type == PCOLiveStatusTypeEnded) {
        return YES;
    }
    if (self.controlledById) {
        return YES;
    }
    return NO;
}

- (BOOL)isControlledByUserId:(NSNumber *)userId{
    if ([self.controlledById isEqualToNumber: userId]) {
        return YES;
    }
    return NO;
}

- (BOOL)hasNextServiceTime {
    if (self.type == PCOLiveStatusTypePlanItemTime && _nextId) {
        return YES;
    }
    return NO;
}

- (BOOL)isEndOfServiceNext {
    if (self.nextId) {
        return NO;
    }
    return YES;
}


- (NSNumber *)timeId {
    switch (self.type) {
        case PCOLiveStatusTypeTime:
            return self.nextId;
            break;
        case PCOLiveStatusTypePlanItemTime:
            return self.statusId;
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSNumber *)itemId {
    switch (self.type) {
        case PCOLiveStatusTypeTime:
            return self.nextItemId;
            break;
        case PCOLiveStatusTypePlanItemTime:
            return _itemId;
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSDate *)serviceStartTime {
    return [self.startDateFormatter dateFromString:[self serviceStartString]];
}

- (NSString *)serviceStartString {
    switch (self.type) {
        case PCOLiveStatusTypeTime:
            return [self.startsAt substringToIndex:19];
            break;
        case PCOLiveStatusTypePlanItemTime:
            return [self.scheduledStart substringToIndex:19];
            break;
            
        default:
            break;
    }
    return nil;
}


- (NSString *)formattedServiceStartTime
{
    NSString *date = [self.dateFormatter stringFromDate:[self serviceStartTime]];
    NSString *time = [self.timeFormatter stringFromDate:[self serviceStartTime]];
    
    return [NSString stringWithFormat:@"%@ at %@", date, time];
    
}

- (void)setControlledByName:(NSString *)controlledByName controlledById:(NSNumber *)controlledById {
    _controlledBy = controlledByName;
    _controlledById = controlledById;
}

+ (PCOLiveStatus *)liveStatusFromDictionary:(NSDictionary *)dict {
    PCOLiveStatus *status = [[PCOLiveStatus alloc] initWithStatusDictionary:dict];
    return status;
}

@end
