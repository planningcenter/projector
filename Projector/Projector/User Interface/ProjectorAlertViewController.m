/*!
 * ProjectorAlertViewController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/6/14
 */

#import "ProjectorAlertViewController.h"

#import "PROScreenPositionPicker.h"
#import "PROAlertTextStylePicker.h"

#import "PROAlertView.h"
#import "PRODisplayController.h"

static CGFloat const ProjectorAlertViewPadding = 12.0;

@interface ProjectorAlertViewController ()

@property (nonatomic, weak) PCOTextField *alertTextField;
@property (nonatomic, weak) PCOView *positionView;
@property (nonatomic, weak) PCOView *buttonsView;

@property (nonatomic, weak) PROScreenPositionPicker *positionPicker;
@property (nonatomic, weak) PROAlertTextStylePicker *stylePicker;

@property (nonatomic, weak) PCOButton *cancelButton;
@property (nonatomic, weak) PCOButton *showButton;

@end

@implementation ProjectorAlertViewController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Alert", nil);
    
    self.preferredContentSize = CGSizeMake(480.0, 330.0);
    
    self.view.backgroundColor = [UIColor modalViewBackgroundColor];
    self.view.tintColor = [UIColor projectorOrangeColor];
    
    if ([[PROAppDelegate delegate] isPad]) {
        self.navigationController.view.layer.borderColor = [[UIColor sessionsHeaderTextColor] CGColor];
        self.navigationController.view.layer.borderWidth = 1.0;
        self.navigationController.view.layer.cornerRadius = 6.0;
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAlertButtonAction:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Show", nil) style:UIBarButtonItemStyleDone target:self action:@selector(showAlertButtonAction:)];
    }
    
    PCOKitLazyLoad(self.positionPicker);
    PCOKitLazyLoad(self.stylePicker);
    
    [self.cancelButton addTarget:self action:@selector(cancelAlertButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.showButton addTarget:self action:@selector(showAlertButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

// MARK: - Lazy Loaders
- (PCOTextField *)alertTextField {
    if (!_alertTextField) {
        PCOTextField *textField = [PCOTextField newAutoLayoutView];
        textField.keyboardType = [[ProjectorSettings userSettings] alertKeyboardType];
        textField.font = [UIFont defaultFontOfSize_18];
        textField.backgroundColor = [UIColor modalViewTextEntryBackgroundColor];
        textField.textColor = [UIColor modalViewTextColor];
        textField.textInsets = UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
        textField.layer.borderWidth = 1.0;
        textField.layer.borderColor = [[UIColor projectorBlackColor] CGColor];
        textField.keyboardAppearance = UIKeyboardAppearanceDark;
        
        if (textField.keyboardType == UIKeyboardTypeAlphabet) {
            textField.placeholder = NSLocalizedString(@"ABC", nil);
        } else {
            textField.placeholder = NSLocalizedString(@"123", nil);
        }
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 44.0)];
        toolbar.tintColor = [UIColor projectorOrangeColor];
        toolbar.barStyle = UIBarStyleBlack;
        toolbar.items = @[
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonAction:)]
                          ];
        
        textField.inputAccessoryView = toolbar;
        
        _alertTextField = textField;
        [self.view addSubview:textField];
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:textField offset:-1.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeTop]];
        [self.view addConstraint:[NSLayoutConstraint height:50.0 forView:textField]];
    }
    return _alertTextField;
}
- (PCOView *)positionView {
    if (!_positionView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor projectorBlackColor];
        
        _positionView = view;
        [self.view addSubview:view];
        
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.alertTextField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:1.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    }
    return _positionView;
}
- (PCOView *)buttonsView {
    if (!_buttonsView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor sessionsHeaderTextColor];
        
        _buttonsView = view;
        [self.view addSubview:view];
        
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
        [self.view addConstraint:[NSLayoutConstraint height:50.0 forView:view]];
    }
    return _buttonsView;
}
- (PROScreenPositionPicker *)positionPicker {
    if (!_positionPicker) {
        PROScreenPositionPicker *picker = [PROScreenPositionPicker newAutoLayoutView];
        
        _positionPicker = picker;
        [self.positionView addSubview:picker];
        
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor modalPositionTextColor];
        label.text = NSLocalizedString(@"On-Screen Position", nil);
        [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.positionView addSubview:label];
        
        if ([[PROAppDelegate delegate] isPad]) {
            [self.positionView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:ProjectorAlertViewPadding edges:UIRectEdgeLeft | UIRectEdgeTop]];
            [self.positionView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:picker offset:ProjectorAlertViewPadding edges:UIRectEdgeLeft | UIRectEdgeBottom]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:picker attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.positionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-ProjectorAlertViewPadding]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:picker attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ProjectorAlertViewPadding]];
        } else {
            [self.positionView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:ProjectorAlertViewPadding edges:UIRectEdgeLeft | UIRectEdgeTop]];
            [self.positionView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:picker offset:ProjectorAlertViewPadding edges:UIRectEdgeLeft | UIRectEdgeRight]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:picker attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ProjectorAlertViewPadding]];
        }
    }
    return _positionPicker;
}
- (PROAlertTextStylePicker *)stylePicker {
    if (!_stylePicker) {
        PROAlertTextStylePicker *picker = [PROAlertTextStylePicker newAutoLayoutView];
        
        _stylePicker = picker;
        [self.positionView addSubview:picker];
        
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor modalPositionTextColor];
        label.text = NSLocalizedString(@"Background", nil);
        [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.positionView addSubview:label];
        
        if ([[PROAppDelegate delegate] isPad]) {
            [self.positionView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:ProjectorAlertViewPadding edges:UIRectEdgeTop]];
            [self.positionView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:picker offset:ProjectorAlertViewPadding edges:UIRectEdgeRight | UIRectEdgeBottom]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:picker attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:picker attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.positionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:ProjectorAlertViewPadding]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:picker attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ProjectorAlertViewPadding]];
        } else {
            [self.positionView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:picker offset:ProjectorAlertViewPadding edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.positionPicker attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ProjectorAlertViewPadding]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.positionPicker attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:picker attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.positionPicker attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
            [self.positionView addConstraint:[NSLayoutConstraint constraintWithItem:picker attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ProjectorAlertViewPadding]];
        }
    }
    return _stylePicker;
}
- (PCOButton *)cancelButton {
    if (!_cancelButton) {
        PCOButton *btn = [PCOButton newAutoLayoutView];
        [btn setTitleColor:[UIColor projectorDeleteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor modalViewBackgroundColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor modalViewHeaderViewBackgroundColor] forState:UIControlStateHighlighted | UIControlStateSelected];
        [btn setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
        btn.tintColor = [UIColor projectorDeleteColor];
        btn.titleLabel.font = [UIFont boldDefaultFontOfSize_14];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 8.0);
        [btn setImage:[UIImage templateImageNamed:@"red_close"] forState:UIControlStateNormal];
        
        _cancelButton = btn;
        [self.buttonsView addSubview:btn];
        
        [self.buttonsView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:btn offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeBottom]];
        [self.buttonsView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:btn offset:1.0 edges:UIRectEdgeTop]];
        [self.buttonsView addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:-0.5]];
    }
    return _cancelButton;
}
- (PCOButton *)showButton {
    if (!_showButton) {
        PCOButton *btn = [PCOButton newAutoLayoutView];
        [btn setTitleColor:[UIColor projectorConfirmColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor modalViewBackgroundColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor modalViewHeaderViewBackgroundColor] forState:UIControlStateHighlighted | UIControlStateSelected];
        [btn setTitle:NSLocalizedString(@"SHOW", nil) forState:UIControlStateNormal];
        btn.tintColor = [UIColor projectorConfirmColor];
        btn.titleLabel.font = [UIFont boldDefaultFontOfSize_14];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 8.0);
        [btn setImage:[UIImage templateImageNamed:@"lr_white_check_mark"] forState:UIControlStateNormal];
        
        _showButton = btn;
        [self.buttonsView addSubview:btn];
        
        [self.buttonsView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:btn offset:0.0 edges:UIRectEdgeRight | UIRectEdgeBottom]];
        [self.buttonsView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:btn offset:1.0 edges:UIRectEdgeTop]];
        [self.buttonsView addConstraint:[NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.buttonsView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.5]];
    }
    return _showButton;
}

// MARK: - Button Actions
- (void)cancelAlertButtonAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)showAlertButtonAction:(id)sender {
    NSString *text = [self.alertTextField.text copy];
    if (text.length > 0) {
        [PCOEventLogger logEvent:@"Nursery Alert - Show Alert"];
        PROAlertView *alert = [[PROAlertView alloc] initWithText:text];
        [[PRODisplayController sharedController] displayAlert:alert];
    } else {
        [PCOEventLogger logEvent:@"Nursery Alert - Dismiss Alert"];

        [[PRODisplayController sharedController] displayAlert:nil];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneBarButtonAction:(id)sender {
    [self.view endEditing:YES];
}

@end
