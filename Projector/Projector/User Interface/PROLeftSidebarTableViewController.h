/*!
 * PROLeftSidebarTableViewController.h
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#ifndef PROLeftSidebarTableViewController_h
#define PROLeftSidebarTableViewController_h

#import "PCOViewController.h"
#import "PCOSlidingSideViewController.h"
#import "PROSidebarTabController.h"

@interface PROLeftSidebarTableViewController : PCOViewController <PCOSlidingSideViewControllerDelegate>

@property (nonatomic, weak) PROSidebarTabController *tabController;

@end

#endif
