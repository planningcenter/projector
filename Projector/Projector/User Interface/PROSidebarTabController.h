/*!
 * PROSidebarTabController.h
 *
 *
 * Created by Skylar Schipper on 3/17/14
 */

#ifndef PROSidebarTabController_h
#define PROSidebarTabController_h

#import "PCOViewController.h"

@interface PROSidebarTabController : PCOViewController

@property (nonatomic, weak, readonly) UIViewController *currentViewController;

@property (nonatomic, assign, readonly) NSUInteger currentSelectedIndex;

- (void)presentPlanViewAnimated:(BOOL)animated;
- (void)presentFilesViewAnimated:(BOOL)animated;
- (void)presentSessionViewAnimated:(BOOL)animated;

@end

#endif
