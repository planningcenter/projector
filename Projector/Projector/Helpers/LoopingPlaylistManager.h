//
//  LoopingPlaylistManager.h
//  Projector
//
//  Created by Peter Fokos on 11/23/11.
//

#import <Foundation/Foundation.h>

@interface LoopingPlaylistManager : NSObject

@property (nonatomic, weak) PCOPlan *plan;
@property (nonatomic, weak) PCOItem *currentlyPlayingItem;

- (void)saveLoopingState:(BOOL)loopState forItem:(PCOItem *)planItem ;
- (void)saveLoopingState:(BOOL)loopState forIndex:(NSInteger)planItemIndex;

- (void)saveLoopingSeconds:(NSInteger)seconds forItem:(PCOItem *)planItem ;
- (void)saveLoopingSeconds:(NSInteger)seconds forIndex:(NSInteger)planItemIndex;

- (void)saveLoopingPlaylistID:(NSNumber *)playlistID forItem:(PCOItem *)planItem;
- (void)saveLoopingPlaylistID:(NSNumber *)playlistID forIndex:(NSInteger)planItemIndex;

- (BOOL)getLoopingStateForItem:(PCOItem *)planItem;
- (BOOL)getLoopingStateForIndex:(NSInteger)planItemIndex;

- (NSInteger)getLoopingSecondsForItem:(PCOItem *)planItem;
- (NSInteger)getLoopingSecondsForIndex:(NSInteger)planItemIndex;

- (NSNumber *)getLoopingPlaylistIDForItem:(PCOItem *)planItem;
- (NSNumber *)getLoopingPlaylistIDForIndex:(NSInteger)planItemIndex;

- (void)startLoopingTimerForItem:(PCOItem *)planItem;

- (BOOL)isCurrentItemLooping;
- (BOOL)doesCurrentItemHaveCustomSlides;
- (void)forceStartNextSlide;

// global class methods
+ (LoopingPlaylistManager *)sharedPlaylistManager;

@end

PCO_EXTERN_STRING PlanItemLooping_StateChanged_Notification;
PCO_EXTERN_STRING PlanItemLooping_TimeForNextSlide_Notification;
PCO_EXTERN_STRING PlanItemLooping_PlaylistChanged_Notification;
