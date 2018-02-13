/*!
 * HelpViewController.h
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#ifndef HelpViewController_h
#define HelpViewController_h

#import "PCOViewController.h"

@interface HelpViewController : PCOViewController

@property (nonatomic, weak) IBOutlet PCOLabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *giveRatingLabel;
@property (weak, nonatomic) IBOutlet UIButton *starsButton;

- (IBAction)newSupportRequestButtonAction:(id)sender;
- (IBAction)documentationButtonAction:(id)sender;
- (IBAction)existingRequestsButtonAction:(id)sender;
- (IBAction)openServicesButtonAction:(id)sender;
- (IBAction)rateUsButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsTopConstraint;

@end

#endif
