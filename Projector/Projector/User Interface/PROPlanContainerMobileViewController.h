/*!
 * PROPlanContainerMobileViewController.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/1/14
 */

#ifndef Projector_PROPlanContainerMobileViewController_h
#define Projector_PROPlanContainerMobileViewController_h

#import "PROPlanContainerViewController.h"
#import "NowPlayingInterfaceController.h"

@interface PROPlanContainerMobileViewController : PROPlanContainerViewController <NowPlayingInterfaceControllerDelegate>

- (void)playSlideAtIndex:(NSInteger)slideIndex withPlanItemIndex:(NSInteger)planItemIndex andScrubPosition:(float)scrubPosition shouldPause:(BOOL)shouldPause;

@end

#endif
