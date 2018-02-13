//
//  CustomSlidesEditorViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/20/14.
//

#import "PCOViewController.h"
#import "PROSwitch.h"
#import "MCTTooltip.h"

@class CustomSlidesEditorViewController;

@protocol CustomSlidesEditorViewControllerDelegate <NSObject>

- (void)slideEditor:(CustomSlidesEditorViewController *)editor didSaveChangesForSlideWithObjectID:(NSManagedObjectID *)objectID;
- (void)slideEditorDidDeleteSlideWithObjectID:(NSManagedObjectID *)slideObjectID;

@end

@interface CustomSlidesEditorViewController : PCOViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, assign) id<CustomSlidesEditorViewControllerDelegate> delegate;

@property (nonatomic, weak) PCOItem *selectedItem;
@property (nonatomic, weak) PCOPlan *plan;
@property (nonatomic, assign) NSInteger newSlideNumber;
@property (nonatomic, assign) NSInteger newOrderIndex;
@property (nonatomic, strong) NSManagedObjectID * slideObjectID;

@property (nonatomic, weak) IBOutlet PCOTextField *textField;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet PCOButton *deleteButton;
@property (nonatomic, weak) IBOutlet PCOView *settingsView;
@property (nonatomic, weak) IBOutlet PROSwitch *smartLayoutSwitch;
@property (weak, nonatomic) IBOutlet UILabel *smartLayoutLabel;
@property (weak, nonatomic) IBOutlet MCTTooltip *tooltipButton;
@property (weak, nonatomic) IBOutlet UILabel *textViewPlaceholderLabel;

- (IBAction)deleteButtonAction:(id)sender;
- (IBAction)smartLayoutSwitchAction:(id)sender;

@end
