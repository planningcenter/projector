/*!
 * LayoutEditorLayoutInfoViewController.m
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#import "LayoutEditorLayoutInfoViewController.h"

@interface LayoutEditorLayoutInfoViewController ()

@property (nonatomic, weak) PCOSlideLayout *layout;
@property (nonatomic, weak) PCOSlideTextLayout *textLayout;

@end

@implementation LayoutEditorLayoutInfoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor layoutEditorBackgroundColor];
    
    self.nameLabel.textColor = [UIColor layoutEditorTabTextColor];
    self.descriptionLabel.textColor = [UIColor layoutEditorTabTextColor];
    
    self.layoutNameField.textColor = [UIColor whiteColor];
    self.layoutNameField.backgroundColor = [UIColor projectorBlackColor];
    self.layoutNameField.textInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    
    self.layoutDescription.textColor = [UIColor whiteColor];
    self.layoutDescription.backgroundColor = [UIColor projectorBlackColor];
    self.layoutDescription.textContainerInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    self.layoutDescription.contentInset = UIEdgeInsetsZero;
}

- (void)updatePreferredFontSize {
    [super updatePreferredFontSize];
    self.nameLabel.font = [UIFont defaultFontOfSize_14];
    self.descriptionLabel.font = [UIFont defaultFontOfSize_14];
    self.layoutNameField.font = [UIFont defaultFontOfSize_16];
    self.layoutDescription.font = [UIFont defaultFontOfSize_16];
}

- (void)updateCurrentTextLayout {
    
}

- (void)setLayout:(PCOSlideLayout *)layout {
    _layout = layout;
    
    self.layoutNameField.text = layout.name;
    self.layoutDescription.text = layout.layoutDescription;
}

- (void)updateUserInterfaceForObjectChanges {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.layout.name = textField.text;
}
- (void)textViewDidChange:(UITextView *)textView {
    self.layout.layoutDescription = textView.text;
}

@end
