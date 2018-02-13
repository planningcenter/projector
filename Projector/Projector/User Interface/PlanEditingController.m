//
//  PlanEditingController.m
//  Projector
//
//  Created by Peter Fokos on 11/7/14.
//

#import "PlanEditingController.h"
#import "ProjectorP2P_SessionManager.h"

id static _sharedEditingController = nil;

@implementation PlanEditingController

#pragma mark -
#pragma mark - Singleton

+ (instancetype)sharedController {
    @synchronized (self) {
        if (!_sharedEditingController) {
            _sharedEditingController = [[[self class] alloc] init];
        }
        return _sharedEditingController;
    }
}

#pragma mark -
#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)savePlanOrderChanges:(PCOPlan *)plan completionBlock:(void (^)(void))completionBlock {
    [[PCOCoreDataManager sharedManager] save:NULL];
    
    [[[PCOCoreDataManager sharedManager] plansController] savePlanOrder:plan completion:^(BOOL success) {
        [[ProjectorP2P_SessionManager sharedManager] serverSendPlanItemChanged:nil];
        if (!success) {
            MCTAlertView *errorAlert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Save Error", nil)
                                                                   message:NSLocalizedString(@"Failed to save order of service.", nil)
                                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)];
            [errorAlert show];
        }
        completionBlock();
    }];
}

- (void)deleteItem:(PCOItem *)item inPlan:(PCOPlan *)plan completionBlock:(void (^)(void))completionBlock {
    [plan removeItemsObject:item];
    NSUInteger sequence = 1;
    for (PCOItem *i in [plan orderedItems]) {
        i.sequence = @(sequence);
        sequence++;
    }
    
    [[[PCOCoreDataManager sharedManager] itemsController] deleteItem:item completion:^(NSError *error) {
        if (error) {
            MCTAlertView *errorAlert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't Delete Item", nil)
                                                                   message:[error localizedDescription]
                                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)];
            [errorAlert show];
        }
        completionBlock();
    }];
}

- (void)saveItem:(PCOItem *)item inPlan:(PCOPlan *)plan completionBlock:(void (^)(void))completionBlock{
    [[[PCOCoreDataManager sharedManager] itemsController] saveItem:item planID:plan.remoteId completion:^(NSError *error) {
        if (error) {
            MCTAlertView *errorAlert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't Save Item", nil)
                                                                   message:[error localizedDescription]
                                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)];
            [errorAlert show];
            completionBlock();
        } else {
            [[[PCOCoreDataManager sharedManager] itemsController] updateSlideSequenceAndSectionsForItem:item completion:^(NSError *error) {
                completionBlock();
            }];
        }
    }];
}

- (void)unlinkSongFromItem:(PCOItem *)item inPlan:(PCOPlan *)plan {
    [item unlinkSong];
}

@end
