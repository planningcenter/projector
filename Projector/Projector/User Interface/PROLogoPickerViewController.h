/*!
 * PROLogoPickerViewController.h
 *
 *
 * Created by Skylar Schipper on 6/26/14
 */

#ifndef PROLogoPickerViewController_h
#define PROLogoPickerViewController_h

#import "PCOTableViewController.h"

@class PROLogoPickerViewController;
@class PROLogo;

@protocol PROLogoPickerViewControllerDelegate <NSObject>

- (void)logoPicker:(PROLogoPickerViewController *)picker didSelectLogo:(PROLogo *)logo;

@end

@interface PROLogoPickerViewController : PCOTableViewController

@property (nonatomic, assign) id<PROLogoPickerViewControllerDelegate> delegate;

@property (nonatomic, weak) PCOPlan *plan;

@property (nonatomic) BOOL inPopover;

@end

#endif
