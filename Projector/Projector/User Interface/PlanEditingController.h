//
//  PlanEditingController.h
//  Projector
//
//  Created by Peter Fokos on 11/7/14.
//

#import <Foundation/Foundation.h>

@interface PlanEditingController : NSObject

+ (instancetype)sharedController;

- (void)savePlanOrderChanges:(PCOPlan *)plan completionBlock:(void (^)(void))completionBlock;
- (void)deleteItem:(PCOItem *)item inPlan:(PCOPlan *)plan completionBlock:(void (^)(void))completionBlock;
- (void)saveItem:(PCOItem *)item inPlan:(PCOPlan *)plan completionBlock:(void (^)(void))completionBlock;
- (void)unlinkSongFromItem:(PCOItem *)item inPlan:(PCOPlan *)plan;

@end
