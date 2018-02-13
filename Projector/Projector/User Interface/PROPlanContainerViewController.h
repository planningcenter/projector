/*!
 * PROPlanContainerViewController.h
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#ifndef PROPlanContainerViewController_h
#define PROPlanContainerViewController_h

#import "PCOViewController.h"
#import "PROContainerViewControllerEventListener.h"
#import "PRORecordingsListViewController.h"

@class PlanViewGridViewController;
@class PlanOutputViewController;
@class PROLogo;
@class PlanGridHelper;

@interface PROPlanContainerViewController : PCOViewController <PRORecordingsListViewControllerDelegate>

@property (nonatomic, weak) PCOPlan *plan;

@property (nonatomic, weak, readonly) PlanViewGridViewController *gridController;
@property (nonatomic, weak, readonly) PlanOutputViewController *outputController;

@property (nonatomic, strong, readonly) PlanGridHelper *helper;

+ (instancetype)currentContainer;

+ (BOOL)displayPlan:(PCOPlan *)plan;

- (void)reloadData;

- (void)updatePlanWithCompletion:(void(^)(void))completion;

- (NSArray *)newRightNavigationButtons;

#pragma mark -
#pragma mark - Event Listeners
- (void)addEventListener:(id<PROContainerViewControllerEventListener>)eventListener;
- (void)removeEventListener:(id<PROContainerViewControllerEventListener>)eventListener;
- (NSArray *)eventListeners;

- (void)presentAlertEntryView:(id)sender;

- (void)showLogoAsNext:(PROLogo *)logo;
- (void)showLogoAsCurrent:(PROLogo *)logo;
- (void)replaceLogoAsCurrent:(PROLogo *)logo;

@property (nonatomic) BOOL showLayoutPickerOnPresent;

- (void)setupInterface;

- (void)editButtonAction:(id)sender;
- (void)layoutButtonAction:(id)sender;

- (NSString *)planTitle;

- (void)setPlan:(PCOPlan *)plan skipUpdate:(BOOL)skipUpdate;
- (void)planUpdated;

- (void)cameraButtonAction:(id)sender;
- (void)updateNavButtons;

@end

#endif
