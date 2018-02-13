//
//  CustomSlidesEditorViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/20/14.
//

#import "CustomSlidesEditorViewController.h"
#import "CommonNavButton.h"
#import "PCOCustomSlide.h"

#define DELETE_BUTTONS_HEIGHT 60

@interface CustomSlidesEditorViewController ()

@property (nonatomic, weak) PCOCustomSlide * currentSlide;

@end

@implementation CustomSlidesEditorViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor lyricsEditorBackgroundColor];
    
    self.settingsView.backgroundColor = [UIColor lyricsEditorBackgroundColor];
    
    if (self.textField) {
        self.textField.layer.borderColor = [HEX(0x0F1116) CGColor];
        self.textField.layer.borderWidth = 1.0;
        self.textField.textInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        self.textField.font = [UIFont defaultFontOfSize_16];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 44.0)];
        toolbar.tintColor = [UIColor projectorOrangeColor];
        toolbar.barStyle = UIBarStyleDefault;
        toolbar.items = @[
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonAction:)]
                          ];
        
        self.textField.inputAccessoryView = toolbar;
    }
    
    if (self.textView) {
        self.textView.layer.borderColor = [HEX(0x0F1116) CGColor];
        self.textView.layer.borderWidth = 1.0;
        self.textView.textContainerInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        self.textView.font = [UIFont defaultFontOfSize_16];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 44.0)];
        toolbar.tintColor = [UIColor projectorOrangeColor];
        toolbar.barStyle = UIBarStyleDefault;
        toolbar.items = @[
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonAction:)]
                          ];
        
        self.textView.inputAccessoryView = toolbar;
    }

    self.textViewPlaceholderLabel.font = [UIFont defaultFontOfSize_16];
    self.textViewPlaceholderLabel.textColor = HEX(0x2E2F39);
    
    [self.deleteButton setTitleColor:[UIColor customSlidesDeleteColor] forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[[UIColor customSlidesDeleteColor] darkerColor] forState:UIControlStateHighlighted];
    [self.deleteButton setBackgroundColor:[UIColor lyricsEditorBackgroundColor] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundColor:[[UIColor lyricsEditorBackgroundColor] darkerColor] forState:UIControlStateHighlighted];
    self.deleteButton.layer.borderWidth = 1.0;
    self.deleteButton.layer.borderColor = [[UIColor customSlidesBorderColor] CGColor];
    self.deleteButton.titleLabel.font = [UIFont defaultFontOfSize_16];
    
    self.smartLayoutLabel.textColor = HEX(0x3C3D42);
    self.smartLayoutLabel.font = [UIFont defaultFontOfSize_16];
    
    self.tooltipButton.tintColor = HEX(0x3C3D42);
    self.tooltipButton.preferredTooltipSize = CGSizeMake(300.0, 30.0);
    self.tooltipButton.message = NSLocalizedString(@"Smart Formatting wraps lines and optimizes slides breaks.\n\nDisabling it uses manual line breaks, scales text down to fit, and starts new slides based on the number of lines in your layout.", nil);
    self.tooltipButton.infoFont = [UIFont defaultFontOfSize_16];
    [self.tooltipButton configurePopupView:^(UIView *view) {
        view.backgroundColor = [UIColor lyricsEditorBackgroundColor];
        view.layer.cornerRadius = 8.0;
        view.layer.masksToBounds = YES;
        view.layer.borderColor = [[UIColor customSlidesBorderColor] CGColor];
        view.layer.borderWidth = 1.0;
    }];
    [self.tooltipButton configureMessageLabel:^(UILabel *label) {
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont defaultFontOfSize_16];
    }];
    
    [self updateSlideUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Edit Slide", nil);
    
    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Save", nil)
                                                                                                              color:[UIColor customSlideSaveButtonColor]
                                                                                                             action:@selector(saveButtonAction:)
                                                                                                          backArrow:NO]];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Slides", nil)
                                                                                                                color:[UIColor sequenceTableViewBorderColor]
                                                                                                               action:@selector(cancelButtonAction:)
                                                                                                            backArrow:YES]];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark -
#pragma mark - Helper Methods

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector backArrow:(BOOL)backArrow {
    CGRect frame = [CommonNavButton frameWithText:text backArrow:backArrow];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    if (backArrow) {
        [button showBackArrow];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShowEndFrame:(CGRect)endFrame animationDuration:(NSTimeInterval)animationDuration options:(UIViewAnimationOptions)options userInfo:(NSDictionary *)userInfo {
    NSDictionary *dict = userInfo;
    
    CGRect dialogRect = self.view.frame;
    CGSize kbSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat inset = 0.0;
    
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds;
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    
    //  #TODO: the 40.0 being added makes this work but we should find the best way to account for this.
    inset = kbSize.height - (fullScreenRect.size.height - statusBarRect.size.height - dialogRect.size.height);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, inset, 0.0);
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
    [UIView commitAnimations];
    
}

- (void)keyboardWillHideWithAnimationDuration:(NSTimeInterval)animationDuration options:(UIViewAnimationOptions)options userInfo:(NSDictionary *)userInfo {
    NSDictionary *dict = userInfo;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.textView.contentInset = UIEdgeInsetsZero;
    self.textView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [UIView commitAnimations];
    
}

#pragma mark -
#pragma mark - Setters

- (void)setSelectedItem:(PCOItem *)selectedItem {
    _selectedItem = selectedItem;
    [selectedItem.managedObjectContext.undoManager beginUndoGrouping];
    [selectedItem.managedObjectContext.undoManager setActionName:@"Custom Slide Edit"];

}

- (void)setSlideObjectID:(NSManagedObjectID *)slideObjectID {
    _slideObjectID = slideObjectID;
    if (_selectedItem) {
        [self updateSlideUI];
    }
}
- (void)updateSlideUI {
    if (!self.slideObjectID) {
        PCOCustomSlide * newSlide = [PCOCustomSlide objectInContext:self.selectedItem.managedObjectContext];
        //newSlide.label = [NSString stringWithFormat:@"Slide %d", self.newSlideNumber];
        newSlide.order = @(self.newOrderIndex);
        [newSlide obtainPermanentID];
        self.slideObjectID = [newSlide objectID];
        [self.selectedItem addCustomSlidesObject:newSlide];
        _currentSlide = newSlide;
    } else {
        PCOCustomSlide * selectedSlide = [[PCOCoreDataManager sharedManager] objectWithID:self.slideObjectID inContext:self.selectedItem.managedObjectContext];
        self.textField.text = selectedSlide.label;
        [self configureLabelPlaceholder];
        self.textView.text = [selectedSlide.body stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
        [self configureBodyPlaceholder];
        _currentSlide = selectedSlide;
    }
    
    [self.smartLayoutSwitch setOn:[[_currentSlide performSmartFormatting] boolValue] animated:YES];
}

- (void)smartLayoutSwitchAction:(id)sender {
    _currentSlide.performSmartFormatting = @([self.smartLayoutSwitch isOn]);
}

#pragma mark -
#pragma mark - UITextView Delegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    [self configureBodyPlaceholder];
}

#pragma mark -
#pragma mark - Action Methods

- (void)doneBarButtonAction:(id)sender {
    [self.view endEditing:YES];
}

- (void)saveButtonAction:(id)sender {
    if ([self.textField.text length] > 0) {
        self.currentSlide.label = self.textField.text;
    } else {
        self.currentSlide.label = [NSString stringWithFormat:NSLocalizedString(@"Slide %tu", nil),self.newSlideNumber];
    }
    if ([self.textView.text length] > 0) {
        self.currentSlide.body = self.textView.text;
    } else {
        self.currentSlide.body = @"";
    }
    [self.selectedItem.managedObjectContext.undoManager endUndoGrouping];
    [self.delegate slideEditor:self didSaveChangesForSlideWithObjectID:self.slideObjectID];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender {
    [self.selectedItem.managedObjectContext.undoManager endUndoGrouping];
    [self.selectedItem.managedObjectContext.undoManager undoNestedGroup];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonAction:(id)sender {
    [self.selectedItem removeCustomSlidesObject:self.currentSlide];
    [self.selectedItem.managedObjectContext.undoManager endUndoGrouping];
    [self.delegate slideEditorDidDeleteSlideWithObjectID:self.slideObjectID];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidChange:(id)sender {
    [self configureLabelPlaceholder];
}

- (void)configureLabelPlaceholder {
    if ([self.textField.text length] > 0) {
//        self.labelPlaceholder.hidden = YES;
    } else {
//        self.labelPlaceholder.hidden = NO;
    }
    
}

- (void)configureBodyPlaceholder {
    if ([self.textView.text length] > 0) {
        self.textViewPlaceholderLabel.hidden = YES;
    } else {
        self.textViewPlaceholderLabel.hidden = NO;
    }
    
}

@end
