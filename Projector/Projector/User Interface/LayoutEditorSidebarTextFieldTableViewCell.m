//
//  LayoutEditorSidebarTextFieldTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 12/19/14.
//

#import "LayoutEditorSidebarTextFieldTableViewCell.h"

@interface LayoutEditorSidebarBaseTableViewCell () <UITextFieldDelegate>

@end

@implementation LayoutEditorSidebarTextFieldTableViewCell

- (void)initializeDefaults {
    [super initializeDefaults];
    PCOKitLazyLoad(self.textField);
}

#pragma mark -
#pragma mark - Lazy Loader

- (PCOTextField *)textField {
    if (!_textField) {
        PCOTextField *field = [PCOTextField newAutoLayoutView];
        field.backgroundColor = [UIColor projectorBlackColor];
        field.textColor = [UIColor whiteColor];
        field.font = [UIFont defaultFontOfSize_16];
        field.delegate = self;
        _textField = field;
        [self.contentView addSubview:field];
        
        [self.contentView addConstraints:[[NSLayoutConstraint offsetViewEdgesInSuperview:field offset:16.0 edges:UIRectEdgeRight | UIRectEdgeLeft] each:^(id obj) {
            [obj setPriority:UILayoutPriorityDefaultHigh];
        }]];

        [self.contentView addConstraints:[[NSLayoutConstraint offsetViewEdgesInSuperview:field offset:4.0 edges:UIRectEdgeTop | UIRectEdgeBottom] each:^(id obj) {
            [obj setPriority:UILayoutPriorityDefaultHigh];
        }]];
    }
    return _textField;
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.textFieldStringChangeHandler) {
        self.textFieldStringChangeHandler(textField.text);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *current = [textField.text mutableCopy];
    [current replaceCharactersInRange:range withString:string];
    if (self.textFieldStringChangeHandler) {
        self.textFieldStringChangeHandler([current copy]);
    }
    return YES;
}

@end
