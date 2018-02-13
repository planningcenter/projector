//
//  HelpEmailSupportViewController.m
//  Projector
//
//  Created by Skylar Schipper on 6/9/14.
//

#import "HelpEmailSupportViewController.h"
#import "UIBarButtonItem+PCOKitAdditions.h"
#import "PROAppDelegate.h"
#import "MCTHelpDesk.h"
#import "PROSlideManager.h"

@interface HelpEmailSupportViewController ()

@property (nonatomic, strong) NSString *bodyPlaceHolderString;

@end

@implementation HelpEmailSupportViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor projectorOrangeColor];
    
    self.bodyPlaceHolderString = NSLocalizedString(@"What can we help you with?", nil);
    self.bodyView.font = [UIFont defaultFontOfSize_14];
    [self textViewDidEndEditing:self.bodyView];
    
    self.title = NSLocalizedString(@"Email Support", nil);
    
    self.subjectField.font = [UIFont defaultFontOfSize_18];
    self.subjectField.textInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    
    [self setupSendButton];
}

- (void)setupSendButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(sendSupportEmailButtonAction:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor projectorOrangeColor];
    
    if (self.navigationController.topViewController == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(p_cancelButtonAction:)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.subjectField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.reportError) {
        self.subjectField.text = NSLocalizedString(@"Projector Error", nil);
        self.bodyView.text = [NSString stringWithFormat:@"\n\n\n---------------\n%@ %td",self.reportError.domain,self.reportError.code];
    }
}

- (void)sendSupportEmailButtonAction:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (![self isMessageValid]) {
        [self showInvalidEmailAlert];
        return;
    }
    [self sendValidEmail];
}
- (void)sendValidEmail {
    MCTHelpTicket *ticket = [MCTHelpTicket ticketWithTitle:self.subjectField.text body:self.bodyView.text];
    ticket.userInfo[@"current_plan_id"] = PCOSafe([[[PROSlideManager sharedManager] plan] remoteId]);
    ticket.userInfo[@"current_aspect_ratio"] = @([[ProjectorSettings userSettings] aspectRatio]);
    ticket.userInfo[@"current_number_of_screens"] = @([[UIScreen screens] count]);
    [ticket setReportError:self.reportError];
    
    [self.view endEditing:YES];
    
    [[MCTHelpDesk sharedDesk] sendTicket:ticket completion:^(BOOL success) {
        if (success) {
            [[[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Thanks!", @"Send submission title")
                                        message:NSLocalizedString(@"We'll be in touch soon.", nil)
                              cancelButtonTitle:NSLocalizedString(@"Done", nil)] show];
            if (self.navigationController.topViewController == self) {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
            [self setupSendButton];
        } else {
            [[[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                        message:[NSString stringWithFormat:NSLocalizedString(@"Something went wrong.  Please try again", nil)]
                              cancelButtonTitle:ProjectorOkString] show];
            [self setupSendButton];
        }
    }];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if ([item.customView respondsToSelector:@selector(setColor:)]) {
        [((UIActivityIndicatorView *)item.customView) setColor:[UIColor projectorOrangeColor]];
    }
    if ([item.customView respondsToSelector:@selector(startAnimating)]) {
        [((UIActivityIndicatorView *)item.customView) startAnimating];
    }
    self.navigationItem.rightBarButtonItem = item;
}

- (void)showInvalidEmailAlert {
    MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil)
                                                      message:NSLocalizedString(@"Looks like something is missing.  Your message needs to have a subject and something we can help you with.", nil)
                                            cancelButtonTitle:ProjectorOkString];
    [alert show];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark -
#pragma mark - Dismiss
- (void)p_cancelButtonAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Mail Helpers
- (BOOL)isSubjectValid {
    return (self.subjectField.text.length != 0);
}
- (BOOL)isMessageBodyValid {
    return (self.bodyView.text.length != 0 && ![self.bodyView.text isEqualToString:self.bodyPlaceHolderString]);
}
- (BOOL)isMessageValid {
    return ([self isSubjectValid] && [self isMessageBodyValid]);
}

#pragma mark -
#pragma mark - Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:self.bodyPlaceHolderString]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (!textView.text || [textView.text isEqualToString:@""] || [textView.text isEqualToString:self.bodyPlaceHolderString]) {
        textView.text = self.bodyPlaceHolderString;
        textView.textColor = [UIColor lightGrayColor];
    }
}

#pragma mark -
#pragma mark - keyboard
- (void)keyboardWillHideWithAnimationDuration:(NSTimeInterval)animationDuration options:(UIViewAnimationOptions)options userInfo:(NSDictionary *)userInfo {
    [UIView animateWithDuration:animationDuration delay:0.0 options:options animations:^{
        self.bodyView.contentInset = UIEdgeInsetsZero;
    } completion:nil];
}
- (void)keyboardWillShowEndFrame:(CGRect)endFrame animationDuration:(NSTimeInterval)animationDuration options:(UIViewAnimationOptions)options userInfo:(NSDictionary *)userInfo {
    CGRect localRect = [[[PROAppDelegate delegate] window] convertRect:endFrame toView:self.bodyView];
    
    CGFloat bottomDiff = CGRectGetHeight(self.bodyView.bounds) - CGRectGetMinY(localRect);
    if (bottomDiff > 0) {
        self.bodyView.contentInset = UIEdgeInsetsMake(0, 0, bottomDiff, 0);
    }
}

@end
