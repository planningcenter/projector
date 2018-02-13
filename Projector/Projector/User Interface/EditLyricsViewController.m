//
//  EditLyricsViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/15/14.
//

//  #TODO: Make the keyboard adjust the text edit box so all text is visible
//  #TODO: If no lyrics text to edit but there is CCLI then put up a dialog and ask to download it

#import "EditLyricsViewController.h"
#import "MCTAlertView.h"
#import "CommonNavButton.h"
#import "PlanItemEditingController.h"

@interface EditLyricsViewController ()

@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, strong) NSString *originalText;

@end

@implementation EditLyricsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Edit Lyrics", nil);
    
    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Save", nil)
                                                                                                              color:[UIColor customSlideSaveButtonColor]
                                                                                                             action:@selector(saveButtonAction:)
                                                                                                          backArrow:NO]];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Sequence", nil)
                                                                                                                color:[UIColor sequenceTableViewBorderColor]
                                                                                                               action:@selector(cancelButtonAction:)
                                                                                                            backArrow:YES]];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    PCOKitLazyLoad(self.textView);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor lyricsEditorBackgroundColor];
    [self.view updateConstraintsIfNeeded];
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

- (void)updateUIWithChordChart {
    if (self.selectedItem.arrangement.chordChart && ![self.selectedItem.arrangement.chordChart isKindOfClass:[NSNull class]]) {
        self.textView.text = self.selectedItem.arrangement.chordChart;
    } else {
        self.textView.text = nil;
    }
    
    _originalText = nil;
    
    if (self.selectedItem.arrangement.chordChartFont) {
        self.textView.font = [UIFont fontWithName:self.selectedItem.arrangement.chordChartFont size:14];
    }
    
    self.originalText = self.textView.text;
    
    BOOL currentTextIsBlank = YES;
    
    if (self.selectedItem.arrangement.chordChart && ![self.selectedItem.arrangement.chordChart isKindOfClass:[NSNull class]]) {
        NSString * currentChordChart = [self.selectedItem.arrangement.chordChart stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (currentChordChart && ![currentChordChart isKindOfClass:[NSNull class]]) {
            currentTextIsBlank = [currentChordChart length] == 0;
        }
    }
        
    if (currentTextIsBlank) {
        if ([[[PCOOrganization current] ccliConnected] boolValue]) {
            if (self.selectedItem.song.ccli) {
                if (self.parentViewController == nil) {
                    return;
                }
                MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Import from SongSelect?", nil) message:NSLocalizedString(@"This song has no lyrics yet.\nWould you like to try importing \nfrom SongSelect?", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil)];
                
                [alert addActionWithTitle:NSLocalizedString(@"Import", nil) handler:^(MCTAlertViewAction *action) {
                    [[[PCOCoreDataManager sharedManager] itemsController] getCCLILyricsFromSongSelect:self.selectedItem.song.ccli completion:^(NSString *lyrics, NSError *error) {
                        PCOError(error);
                        if (error) {
                            MCTAlertView *errorAlert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't import lyrics", nil)
                                                                                   message:[NSString stringWithFormat:NSLocalizedString(@"Unable to import lyrics from SongSelect. Error code: %@", nil), [error localizedDescription]]
                                                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)];
                            [errorAlert show];
                        } else {
                            self.textView.text = lyrics;
                            [self.textView becomeFirstResponder];
                        }
                    }];
                }];
                
                [alert show];
            }
        }
    } else {
        [self.textView becomeFirstResponder];
    }
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
    inset = kbSize.height - (fullScreenRect.size.height - statusBarRect.size.height - dialogRect.size.height) + 40.0;
    NSLog(@"inset = %f", inset);
    
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
    [[[PCOCoreDataManager sharedManager] songsController] updateDataForArrangement:self.selectedItem.arrangement completion:^{
        [self updateUIWithChordChart];
    }];
}

#pragma mark -
#pragma mark - Lazy Loaders

- (UITextView *)textView {
    if (!_textView) {
        UITextView *editor = [UITextView newAutoLayoutView];
        editor.font = [UIFont defaultFontOfSize_16];
        editor.textColor = [UIColor lyricsTextViewTextColor];
        editor.backgroundColor = [UIColor lyricsTextViewBackgroundColor];
        editor.layer.borderColor = [[UIColor lyricsTextViewOutlineColor] CGColor];
        editor.layer.borderWidth = 2;
        _textView = editor;
        [self.view addSubview:editor];
        [self.view addConstraints:[NSLayoutConstraint pco_fitView:editor inView:self.view insets:UIEdgeInsetsMake(12,12,12,12)]];
    }
    return _textView;
}

#pragma mark -
#pragma mark - Action Methods

- (void)saveButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[PlanItemEditingController sharedController] saveLyrics:self.textView.text forItem:self.selectedItem inPlan:self.plan];
}

- (void)cancelButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
