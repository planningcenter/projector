//
//  PCOLiveController.h
//  Projector
//
//  Created by Peter Fokos on 7/21/14.
//

#import <Foundation/Foundation.h>
#import "PCOLiveStatus.h"
#import "Pusher.h"

PCO_EXTERN_STRING PCOLiveStateChangedNotification;

@protocol PCOLiveControllerDelegate <NSObject>

@optional

- (void)scrollToPlanItemId:(NSNumber *)planItemId;
- (void)statusDidUpdate:(PCOLiveStatus *)status;

@end

@interface PCOLiveController : NSObject <PTPusherDelegate> {
    BOOL pusherConnected;
}

+ (instancetype)sharedController;

@property (strong, nonatomic) PCOLiveStatus *liveStatus;
@property (strong, nonatomic) PCOPlan *livePlan;
@property (strong, nonatomic) NSNumber *currentUserId;
@property (strong, nonatomic) NSNumber *sessionServerUserId;

- (void)addDelegate:(id<PCOLiveControllerDelegate>)delegate;
- (void)removeDelegate:(id<PCOLiveControllerDelegate>)delegate;

- (void)getLiveStatusWithSuccessCompletion:(void (^)(PCOLiveStatus *status))success errorCompletion:(void (^)(NSError * error))errorBlock;
- (void)takeControlOfLiveSessionWithSuccessCompletion:(void (^)(PCOLiveStatus *status))success errorCompletion:(void (^)(NSError * error))errorBlock;

- (void)startLiveItemAtPlanItemIndex:(NSInteger)planItemIndex;
- (void)startLiveItemAtPlanItemIndex:(NSInteger)planItemIndex successCompletion:(void (^)(NSDictionary *status))successBlock errorCompletion:(void (^)(NSError * error))errorBlock;
- (void)liveNextAtPlanItemIndex:(NSInteger)planItemIndex;
- (void)livePrevious;
- (void)livePreviousAtPlanItemIndex:(NSInteger)planItemIndex;
- (void)livePreviousWithSuccessCompletion:(void (^)(void))successBlock errorCompletion:(void (^)(NSError * error))errorBlock;
- (void)moveLiveToEndOfServiceFromPlanItemIndex:(NSInteger)planItemIndex;

- (void)updateStatusWithControlledByName:(NSString *)controlledByName controlledById:(NSNumber *)controlledById;
- (void)releaseControlOfLiveSessionByUserId:(NSNumber *)userId;
- (BOOL)isLiveActive;
- (BOOL)isLiveControlledByUser;
- (BOOL)canControl;

- (BOOL)hasPreviousServiceTime;
- (BOOL)hasNextServiceTime;
- (BOOL)isLiveStatusEnded;


@end
