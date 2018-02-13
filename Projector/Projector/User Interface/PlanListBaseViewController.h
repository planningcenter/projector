/*!
 * PlanListBaseViewController.h
 *
 *
 * Created by Skylar Schipper on 3/17/14
 */

#ifndef PlanListBaseViewController_h
#define PlanListBaseViewController_h

#import "PROSidebarTableViewController.h"

@interface PlanListBaseViewController : PROSidebarTableViewController <PCOTableViewControllerPullToRefreshDelegate>

@property (nonatomic, strong) NSNumber *parentID;

@end

#endif
