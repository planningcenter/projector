//
//  LayoutEditorTabletContainerController.m
//  Projector
//
//  Created by Peter Fokos on 12/18/14.
//

#import "LayoutEditorTabletContainerController.h"

@interface LayoutEditorTabletContainerController ()

@property (nonatomic, weak) PCOButton *saveButton;
@property (nonatomic, weak) PCOButton *cancelButton;

@end

@implementation LayoutEditorTabletContainerController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loadView {
    [super loadView];
    
    self.titleBar.backgroundColor = pco_kit_RGB(31,31,35);
    
    [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIActivityIndicatorView *loading = [UIActivityIndicatorView newAutoLayoutView];
    loading.hidesWhenStopped = YES;
    
    [self.titleBar addSubview:loading];
    [self.titleBar addConstraint:[NSLayoutConstraint centerViewVerticalyInSuperview:loading]];
    [self.titleBar addConstraint:[NSLayoutConstraint constraintWithItem:loading attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.saveButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    self.loadingView = loading;
}

// MARK: - Lazy Loaders
- (PCOButton *)saveButton {
    if (!_saveButton) {
        PCOButton *button = [self commonNavButton];
        
        _saveButton = button;
        [self.titleBar addSubview:button];
        
        [self.titleBar addConstraint:[NSLayoutConstraint centerViewVerticalyInSuperview:button]];
        [self.titleBar addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:10.0 edges:UIRectEdgeRight]];
    }
    return _saveButton;
}
- (PCOButton *)cancelButton {
    if (!_cancelButton) {
        PCOButton *button = [self commonNavButton];
        
        _cancelButton = button;
        [self.titleBar addSubview:button];
        
        [self.titleBar addConstraint:[NSLayoutConstraint centerViewVerticalyInSuperview:button]];
        [self.titleBar addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:10.0 edges:UIRectEdgeLeft]];
    }
    return _cancelButton;
}

- (PCOButton *)commonNavButton {
    PCOButton *button = [PCOButton newAutoLayoutView];
    button.minimumIntrinsicContentSize = CGSizeMake(60.0, 0.0);
    button.titleLabel.font = [UIFont defaultFontOfSize_14];
    [button setTitleColor:[UIColor layoutControllerToolbarDoneButtonColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor layoutControllerToolbarDoneButtonColor];
    [button setBackgroundColor:[UIColor projectorBlackColor] forState:UIControlStateHighlighted];
    return button;
}

#pragma mark -
#pragma mark - Save

- (void)saveButtonAction:(id)sender {
    [self.layout.managedObjectContext.undoManager endUndoGrouping];
    
    [self.loadingView startAnimating];
    self.saveButton.hidden = YES;
    self.cancelButton.hidden = YES;

    [self saveCurrentLayoutWithCompletion:^(NSError *error) {
        self.saveButton.hidden = NO;
        self.cancelButton.hidden = NO;
        [self.loadingView stopAnimating];
        if (error) {
            [MCTAlertView showError:error];
            return;
        }
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
