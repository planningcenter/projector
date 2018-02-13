//
//  LoopingPlaylistManager.m
//  Projector
//
//  Created by Peter Fokos on 11/23/11.
//

#import "LoopingPlaylistManager.h"
#import "MCTAlertView.h"
#import "PCOPlan.h"

static LoopingPlaylistManager * sharedManager = nil;

@interface LoopingPlaylistManager () {
    BOOL timerSet;
}

@end

@implementation LoopingPlaylistManager

#pragma mark - Setup Methods

- (id)init {
	if ((self = [super init]))
	{
		
	}
    return self;
}

- (void)startLoopingTimerForItem:(PCOItem *)planItem {
    if ([planItem.looping boolValue]) {
        if (timerSet) {
            timerSet = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
        }
        NSInteger seconds = [planItem.secondsPerSlide integerValue];
        [self performSelector:@selector(loopingTimeExpiredForItem:) withObject:planItem afterDelay:seconds inModes:@[NSRunLoopCommonModes]];
        timerSet = YES;
    }
}

- (void)loopingTimeExpiredForItem:(PCOItem *)planItem {
    timerSet = NO;
    if ([planItem.looping boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PlanItemLooping_TimeForNextSlide_Notification object:planItem];
    }
}

#pragma mark - Looping Data Methods

- (NSString *)loopingBaseKeyForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    NSString *loopKey = [NSString stringWithFormat:@"Loop_PlanID_%d_ItemID_%d", [plan.remoteId intValue], [planItem.remoteId intValue]];
    return loopKey;
}

- (NSString *)loopingBaseKeyForItem:(PCOItem *)planItem {
    return [self loopingBaseKeyForPlan:self.plan Item:planItem];
}

- (NSString *)loopingBaseKeyForIndex:(NSInteger)planItemIndex {
    PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:planItemIndex];
    return [self loopingBaseKeyForPlan:self.plan Item:planItem];
}

// Looping State key methods

- (NSString *)loopingStateKeyForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    NSString *loopKey = [NSString stringWithFormat:@"%@_State", [self loopingBaseKeyForPlan:plan Item:planItem]];
    return loopKey;
}

- (NSString *)loopingStateKeyForPlanItem:(PCOItem *)planItem {
    return [self loopingStateKeyForPlan:self.plan Item:planItem];
}

- (NSString *)loopingStateKeyForIndex:(NSInteger)planItemIndex {
    PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:planItemIndex];
    return [self loopingStateKeyForPlan:self.plan Item:planItem];
}

// Looping Seconds key methods

- (NSString *)loopingSecondsKeyForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    NSString *loopKey = [NSString stringWithFormat:@"%@_Seconds", [self loopingBaseKeyForPlan:plan Item:planItem]];
    return loopKey;
}

- (NSString *)loopingSecondsKeyForPlanItem:(PCOItem *)planItem {
    return [self loopingSecondsKeyForPlan:self.plan Item:planItem];
}

- (NSString *)loopingSecondsKeyForIndex:(NSInteger)planItemIndex {
    PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:planItemIndex];
    return [self loopingSecondsKeyForPlan:self.plan Item:planItem];
}

// Looping PlaylistID key methods

- (NSString *)loopingPlaylistIDKeyForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    NSString *loopKey = [NSString stringWithFormat:@"%@_PlaylistID", [self loopingBaseKeyForPlan:plan Item:planItem]];
    return loopKey;
}

- (NSString *)loopingPlaylistIDKeyForPlanItem:(PCOItem *)planItem {
    return [self loopingPlaylistIDKeyForPlan:self.plan Item:planItem];
}

- (NSString *)loopingPlaylistIDKeyForIndex:(NSInteger)planItemIndex {
    PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:planItemIndex];
    return [self loopingPlaylistIDKeyForPlan:self.plan Item:planItem];
}

// Save looping State information methods

- (void)saveLoopingState:(BOOL)loopState ForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    if (loopState != [planItem.looping boolValue]) {
        planItem.looping = @(loopState);
        [[[PCOCoreDataManager sharedManager] itemsController] saveLoopingChangesForItem:planItem completion:^(NSError *error) {
            if (error) {
                MCTAlertView * errorAlertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't save looping settings", nil) message:[error localizedDescription] cancelButtonTitle:NSLocalizedString(@"OK", nil)];
                [errorAlertView show];
            }
        }];
    }
}

- (void)saveLoopingState:(BOOL)loopState forItem:(PCOItem *)planItem {
    [self saveLoopingState:loopState ForPlan:nil Item:planItem];
    if (!loopState) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loopingTimeExpiredForItem:) object:planItem];
        timerSet = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PlanItemLooping_StateChanged_Notification object:planItem];
    });
}

- (void)saveLoopingState:(BOOL)loopState forIndex:(NSInteger)planItemIndex {
    PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:planItemIndex];
    [self saveLoopingState:loopState ForPlan:nil Item:planItem];
}

// Save looping Seconds information methods

- (void)saveLoopingSeconds:(NSInteger)seconds ForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    if (seconds != [planItem.secondsPerSlide integerValue]) {
        planItem.secondsPerSlide = @(seconds);
        
        [[[PCOCoreDataManager sharedManager] itemsController] saveLoopingChangesForItem:planItem completion:^(NSError *error) {
            if (error) {
                MCTAlertView * errorAlertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't save looping settings", nil) message:[error localizedDescription] cancelButtonTitle:NSLocalizedString(@"OK", nil)];
                [errorAlertView show];
            }
        }];
    }
}

- (void)saveLoopingSeconds:(NSInteger)seconds forItem:(PCOItem *)planItem {
    [self saveLoopingSeconds:seconds ForPlan:nil Item:planItem];
}

- (void)saveLoopingSeconds:(NSInteger)seconds forIndex:(NSInteger)planItemIndex {
    PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:planItemIndex];
    [self saveLoopingSeconds:seconds ForPlan:nil Item:planItem];
}


// Save looping PlaylistID information methods

- (void)saveLoopingPlaylistID:(NSNumber *)playlistID ForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    [[NSUserDefaults standardUserDefaults] setObject:playlistID forKey:[self loopingPlaylistIDKeyForPlan:plan Item:planItem]];
}

- (void)saveLoopingPlaylistID:(NSNumber *)playlistID forItem:(PCOItem *)planItem {
    [[NSUserDefaults standardUserDefaults] setObject:playlistID forKey:[self loopingPlaylistIDKeyForPlanItem:planItem]];
}

- (void)saveLoopingPlaylistID:(NSNumber *)playlistID forIndex:(NSInteger)planItemIndex {
    [[NSUserDefaults standardUserDefaults] setObject:playlistID forKey:[self loopingPlaylistIDKeyForIndex:planItemIndex]];
}

// Get looping State information methods



- (BOOL)getLoopingStateForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    return [planItem.looping boolValue];
}

- (BOOL)getLoopingStateForItem:(PCOItem *)planItem {
    return [planItem.looping boolValue];
}

- (BOOL)getLoopingStateForIndex:(NSInteger)planItemIndex {
    if ((NSInteger)[[self.plan orderedItems] count] < planItemIndex + 1) return NO;
    PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:planItemIndex];
    return [planItem.looping boolValue];
}




- (NSInteger)getLoopingSecondsForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    return [planItem.secondsPerSlide integerValue];
}

- (NSInteger)getLoopingSecondsForItem:(PCOItem *)planItem {
    return [planItem.secondsPerSlide integerValue];
}

- (NSInteger)getLoopingSecondsForIndex:(NSInteger)planItemIndex {
    PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:planItemIndex];
    return [planItem.secondsPerSlide integerValue];
}

// Get looping PlaylistID information methods

- (NSNumber *)getLoopingPlaylistIDForPlan:(PCOPlan *)plan Item:(PCOItem *)planItem {
    return [NSNumber numberWithUnsignedLongLong:[[[NSUserDefaults standardUserDefaults] objectForKey:[self loopingPlaylistIDKeyForPlan:plan Item:planItem]] unsignedLongLongValue]];
}

- (NSNumber *)getLoopingPlaylistIDForItem:(PCOItem *)planItem {
    return [NSNumber numberWithUnsignedLongLong:[[[NSUserDefaults standardUserDefaults] objectForKey:[self loopingPlaylistIDKeyForPlanItem:planItem]] unsignedLongLongValue]];
}

- (NSNumber *)getLoopingPlaylistIDForIndex:(NSInteger)planItemIndex {
    return [NSNumber numberWithUnsignedLongLong:[[[NSUserDefaults standardUserDefaults] objectForKey:[self loopingPlaylistIDKeyForIndex:planItemIndex]] unsignedLongLongValue]];
}

- (BOOL)isCurrentItemLooping {
    if (self.currentlyPlayingItem.arrangement || [self getLoopingStateForItem:self.currentlyPlayingItem]) {
        return YES;
    }
    return NO;
}

- (BOOL)doesCurrentItemHaveCustomSlides {
    if ([[self.currentlyPlayingItem orderedCustomSlides] count] > 0) {
        return YES;
    }
    return NO;
}

- (void)forceStartNextSlide {
    [self loopingTimeExpiredForItem:self.currentlyPlayingItem];
}

#pragma mark - Singleton implementation
+ (LoopingPlaylistManager *)sharedPlaylistManager {
	@synchronized (self) {
		if (sharedManager == nil) {
			sharedManager = [[self alloc] init];
		}
	}
	
	return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized (self) {
		if (sharedManager == nil) {
			sharedManager = [super allocWithZone:zone];
			return sharedManager;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

_PCO_EXTERN_STRING PlanItemLooping_StateChanged_Notification = @"PlanItemLooping_StateChanged_Notification";
_PCO_EXTERN_STRING PlanItemLooping_TimeForNextSlide_Notification = @"PlanItemLooping_TimeForNextSlide_Notification";
_PCO_EXTERN_STRING PlanItemLooping_PlaylistChanged_Notification = @"PlanItemLooping_PlaylistChanged_Notification";


@end