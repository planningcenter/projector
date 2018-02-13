/*!
 * PlanViewGridViewController.h
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#ifndef PlanViewGridViewController_h
#define PlanViewGridViewController_h

#import "PCOCollectionViewController.h"
#import "ProjectorP2P_SessionManager.h"
#import "PCOLiveController.h"

#import "PlanGridHelper.h"

@class PROPlanContainerViewController;
@class PRODisplayItem;
@class PROLogo;

@interface PlanViewGridViewController : PCOCollectionViewController <PCOLiveControllerDelegate>

@property (nonatomic, weak, readonly) PROPlanContainerViewController *container;

@property (nonatomic, strong) PlanGridHelper *helper;

- (void)willBeginRefresh;
- (void)didEndRefresh;
- (void)playSlideAtIndex:(NSInteger)slideIndex withPlanItemIndex:(NSInteger)planItemIndex andScrubPosition:(float)scrubPosition shouldPause:(BOOL)shouldPause;
- (void)startCollectionViewReload;

@end

#endif
