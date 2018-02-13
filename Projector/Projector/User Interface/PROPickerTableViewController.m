//
//  PROPickerTableViewController.m
//  Projector
//
//  Created by Peter Fokos on 11/21/14.
//

#import "PROPickerTableViewController.h"
#import "CommonNavButton.h"

@interface PROPickerTableViewController ()

@end

@implementation PROPickerTableViewController

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

- (void)cancelButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
