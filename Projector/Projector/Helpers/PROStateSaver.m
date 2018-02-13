/*!
 * PROStateSaver.m
 *
 *
 * Created by Skylar Schipper on 3/19/14
 */


#import "PROStateSaver.h"
#import "PCOKeyValueStore.h"

static NSString *const kPROStateSaverKVScope = @"user_state";

@interface PROStateSaver ()

@end

@implementation PROStateSaver
@dynamic lastOpenPlanID;
@dynamic lastSidebarTabOpen;
@dynamic sessionClientMode;
@dynamic addLogoSection;
@dynamic currentLogoUUID;
@dynamic sessionType;
@dynamic sessionConnectedToServerNamed;

#pragma mark -
#pragma mark - Singleton
+ (instancetype)sharedState {
    static id shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

- (id)init {
    self = [super init];
    if (self) {
        if (!self.sessionClientMode) {
            self.sessionClientMode = @(1);
        }
        if (!self.sessionType) {
            self.sessionType = @"";
        }
        if (!self.sessionConnectedToServerNamed) {
            self.sessionConnectedToServerNamed = @"";
        }
    }
    return self;
}

#pragma mark -
#pragma mark - Loaders
- (PCOPlan *)lastOpenPlan {
    NSNumber *lastID = self.lastOpenPlanID;
    if (!lastID) {
        return nil;
    }
    return [PCOPlan findOrCreateWithRemoteID:lastID];
}
- (void)flushState {
    [[PCOKeyValueStore defaultStore] deleteAllInScope:kPROStateSaverKVScope];
    [self clearMemoryCache];
}

#pragma mark -
#pragma mark - Data
- (void)setPrimitiveValue:(id)object forKey:(NSString *)key {
    [[PCOKeyValueStore defaultStore] setObject:object forKey:key scope:kPROStateSaverKVScope];
}
- (id)primitiveValueForKey:(NSString *)key {
    return [[PCOKeyValueStore defaultStore] objectForKey:key scope:kPROStateSaverKVScope];
}

@end
