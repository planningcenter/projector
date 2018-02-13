/*!
 * PROFirstLaunchViewController.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 1/8/15
 */

#ifndef Projector_PROFirstLaunchViewController_h
#define Projector_PROFirstLaunchViewController_h

#import "PCOViewController.h"

@interface PROFirstLaunchViewController : PCOViewController

+ (void)presentFromViewController:(UIViewController *)controller;

@property (weak, nonatomic) IBOutlet UISegmentedControl *aspectPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gridSizePicker;

- (IBAction)doneButtonAction:(id)sender;

@end

#endif
