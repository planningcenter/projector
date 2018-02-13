/*!
 * PlanViewMobileGridTableViewController.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/2/14
 */

#ifndef Projector_PlanViewMobileGridTableViewController_h
#define Projector_PlanViewMobileGridTableViewController_h

#import "PCOTableViewController.h"
#import "PROContainerViewControllerEventListener.h"
#import "PlanGridHelper.h"
#import "PCOLiveController.h"

@interface PlanViewMobileGridTableViewController : PCOTableViewController <PlanGridHelperDelegate, PROContainerViewControllerEventListener, PCOLiveControllerDelegate>

@property (nonatomic, strong, readonly) PlanGridHelper *helper;
@property (nonatomic, weak, readonly) PROPlanContainerViewController *container;

- (void)pro_setContainer:(PROPlanContainerViewController *)container;
- (void)willBeginRefresh;
- (void)didEndRefresh;

@end

#endif
