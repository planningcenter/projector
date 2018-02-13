/*!
 * PROAppDelegate_phone.m
 *
 *
 * Created by Skylar Schipper on 3/12/14
 */

#import "PROAppDelegate_phone.h"

#import "PROPlanContainerMobileViewController.h"
#import "PROPlanNavigationController.h"
#import "PortraitSlidingSideViewController.h"

@interface PROAppDelegate_phone ()

@end

@implementation PROAppDelegate_phone

- (PCOSlidingSideViewController *)newMainUserInterfaceViewController {
    PROPlanContainerMobileViewController *planContainer = [[PROPlanContainerMobileViewController alloc] initWithNibName:nil bundle:nil];
    PROPlanNavigationController *navigation = [[PROPlanNavigationController alloc] initWithRootViewController:planContainer];
    
    PortraitSlidingSideViewController *slider = [[PortraitSlidingSideViewController alloc] initWithLeftViewController:[[PROLeftSidebarTableViewController alloc] initWithNibName:nil bundle:nil]
                                                                                        rightViewController:nil
                                                                                      contentViewController:navigation];
    
    slider.contentViewPanGesture.enabled = NO;
    return slider;
}

@end
