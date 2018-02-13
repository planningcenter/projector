//
//  PROUIOptimization.h
//  Projector
//
//  Created by Peter Fokos on 3/20/15.
//

#import <Foundation/Foundation.h>

#define LOG_OPTI_EVENTS 0

#if LOG_OPTI_EVENTS
#define OptiEventLog(msg, ...) PCOLogInfo(msg, ##__VA_ARGS__)
#else
#define OptiEventLog(msg, ...)
#endif

@interface PROUIOptimization : NSObject

+ (instancetype)sharedOptimizer;

- (void)appColdStarted;
- (void)appWarmStarted;

- (void)loadingAFreshPlan;
- (void)planWasSet;
- (void)planStartedUpdating;
- (void)planFinishedUpdating;

- (void)layoutStartedUpdating;
- (void)layoutFinishedUpdating;

- (BOOL)shouldGridReload;
- (BOOL)shouldGridReloadSection;

- (void)startedFullUIReload;
- (void)finishedFullUIReload;
- (BOOL)isFullUIReloading;
- (BOOL)wasFreshPlan;

- (void)setNumberOfRows:(NSInteger)rows inSection:(NSInteger)section;
- (BOOL)isLastCellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastSection:(NSInteger)section;

@end
