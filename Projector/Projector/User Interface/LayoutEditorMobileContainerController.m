//
//  LayoutEditorMobileContainerController.m
//  Projector
//
//  Created by Peter Fokos on 12/17/14.
//

#import "LayoutEditorMobileContainerController.h"
#import "CommonNavButton.h"

@interface LayoutEditorMobileContainerController ()

@end

@implementation LayoutEditorMobileContainerController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loadView {
    [super loadView];

    self.title = NSLocalizedString(@"Edit Layout", nil);
    [self addBackButtonWithString:NSLocalizedString(@"Cancel", nil)];
    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Save", nil)
                                                                                                              color:[UIColor projectorOrangeColor]
                                                                                                             action:@selector(saveButtonAction:)
                                                                                                          backArrow:NO]];
    self.navigationItem.rightBarButtonItem = saveButtonItem;

    UIActivityIndicatorView *loading = [UIActivityIndicatorView newAutoLayoutView];
    loading.hidesWhenStopped = YES;
    
    self.loadingView = loading;
}

- (void)addBackButtonWithString:(NSString *)string {
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:string
                                                                                                                color:[UIColor sequenceTableViewBorderColor]
                                                                                                               action:@selector(cancelButtonAction:)
                                                                                                            backArrow:YES]];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
}

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector backArrow:(BOOL)backArrow {
    CGRect frame = [CommonNavButton frameWithText:text backArrow:backArrow];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    if (backArrow) {
        [button showBackArrow];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

// MARK: - Lazy Loaders

#pragma mark -
#pragma mark - Save

- (void)saveButtonAction:(id)sender {
    [self.layout.managedObjectContext.undoManager endUndoGrouping];
    [self saveCurrentLayoutWithCompletion:^(NSError *error) {
        if (error) {
            [MCTAlertView showError:error];
            return;
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.layout.managedObjectContext.undoManager = nil;
}

- (void)cancelButtonAction:(id)sender {
    for (UIViewController <LayoutEditorInterfaceContainerSubController> *controller in [self layoutSubControllers]) {
        for (UIView *view in [controller.view subviews]) {
            if ([view isFirstResponder]) {
                [view resignFirstResponder];
            }
        }
    }
    [self.layout.managedObjectContext.undoManager endUndoGrouping];
    [self.layout.managedObjectContext.undoManager undo];
    self.layout.managedObjectContext.undoManager = nil;
    if ([self.layout isNew]) {
        [self.layout.managedObjectContext deleteObject:self.layout];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
