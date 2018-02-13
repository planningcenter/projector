/*!
 * PlanOutputViewController.h
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#ifndef PlanOutputViewController_h
#define PlanOutputViewController_h

#import "PCOViewController.h"
#import "PROContainerViewControllerEventListener.h"
#import "NowPlayingInterfaceController.h"

@interface PlanOutputViewController : PCOViewController <NowPlayingInterfaceControllerDelegate, PROContainerViewControllerEventListener>

@property (nonatomic, weak, readonly) PROPlanContainerViewController *container;

- (PROLogo *)currentLogo;

#pragma mark -
#pragma mark - Layout
- (void)sendControlButtonActionTo:(id)object nextButtonSelector:(SEL)nextSelector previousButtonSelector:(SEL)previousSelector;

@end

PCO_EXTERN CGFloat const PlanOutputViewControllerPadding;

#endif
