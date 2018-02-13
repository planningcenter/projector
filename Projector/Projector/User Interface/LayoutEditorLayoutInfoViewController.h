/*!
 * LayoutEditorLayoutInfoViewController.h
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#ifndef LayoutEditorLayoutInfoViewController_h
#define LayoutEditorLayoutInfoViewController_h

#import "PCOViewController.h"
#import "LayoutEditorInterfaceContainerController.h"


@interface LayoutEditorLayoutInfoViewController : PCOViewController <LayoutEditorInterfaceContainerSubController, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet PCOLabel *nameLabel;
@property (weak, nonatomic) IBOutlet PCOLabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet PCOTextField *layoutNameField;
@property (weak, nonatomic) IBOutlet UITextView *layoutDescription;

@end

#endif
