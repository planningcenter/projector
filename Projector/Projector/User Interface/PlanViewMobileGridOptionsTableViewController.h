/*!
 * PlanViewMobileGridOptionsTableViewController.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/10/14
 */

#ifndef Projector_PlanViewMobileGridOptionsTableViewController_h
#define Projector_PlanViewMobileGridOptionsTableViewController_h

#import "PCOTableViewController.h"

@class PlanGridHelper;

@protocol PlanViewMobileGridOptionsTableViewControllerDelegate;

@interface PlanViewMobileGridOptionsTableViewController : PCOTableViewController

@property (nonatomic, assign) id<PlanViewMobileGridOptionsTableViewControllerDelegate> delegate;

- (void)prepareToAnimateIn;
- (void)animateIn;
- (void)animateOut;

@end

@protocol PlanViewMobileGridOptionsTableViewControllerDelegate <NSObject>

- (PlanGridHelper *)gridHelperForController:(PlanViewMobileGridOptionsTableViewController *)controller;

- (void)optionsControllerRecordingsAction:(PlanViewMobileGridOptionsTableViewController *)controller;
- (void)optionsControllerChangeLogoAction:(PlanViewMobileGridOptionsTableViewController *)controller;
- (void)optionsControllerOrderOfServiceAction:(PlanViewMobileGridOptionsTableViewController *)controller;
- (void)optionsControllerLayoutsAction:(PlanViewMobileGridOptionsTableViewController *)controller;

@end

#endif
