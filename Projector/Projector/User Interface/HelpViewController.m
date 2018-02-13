/*!
 * HelpViewController.m
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#import "HelpViewController.h"
#import "UIApplication+PCOKitAdditions.h"
#import "PRONavigationController.h"
#import "HelpEmailSupportViewController.h"
#import "ZendeskController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Help", nil);
    
    self.view.backgroundColor = [UIColor sidebarBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@ %@ - %@",
                           [[UIApplication sharedApplication] displayNameString],
                           [[UIApplication sharedApplication] shortVersionString],
                           [[UIApplication sharedApplication] versionString]
                           ];
    
    self.infoLabel.textColor = [UIColor sidebarCellTintColor];
    self.giveRatingLabel.textColor = [UIColor sidebarTextColor];
    self.giveRatingLabel.font = [UIFont defaultFontOfSize_14];
    self.starsButton.tintColor = pco_kit_RGB(94,94,104);
    [PCOEventLogger logEvent:@"Help - Entered"];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.view.window.screen.bounds.size.height < 500) {
        self.buttonsTopConstraint.constant = 20.0;
    }
}

#pragma mark -
#pragma mark - Font
- (void)updatePreferredFontSize {
    self.infoLabel.font = [UIFont defaultFontForStyle:UIFontTextStyleBody];
}

#pragma mark -
#pragma mark - Done
- (void)doneButtonAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsDoneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSURL *)pcoAppURL {
    static NSURL *URL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"pcoservices://?ref=projector&v=%@",infoDict[@"CFBundleShortVersionString"]]];
    });
    return URL;
}

#pragma mark -
#pragma mark - Actions
- (IBAction)newSupportRequestButtonAction:(id)sender {
    [PCOEventLogger logEvent:@"Help - Support Request"];
    [[ZendeskController sharedController] openTicketWithNavController:self.navigationController];
}

- (IBAction)documentationButtonAction:(id)sender {
    [PCOEventLogger logEvent:@"Help - Documentation"];
    [[ZendeskController sharedController] openHelpCenterWithNavController:self.navigationController];
    
}

- (IBAction)existingRequestsButtonAction:(id)sender {
    [PCOEventLogger logEvent:@"Help - Existing Requests"];
    [[ZendeskController sharedController] showTicketsWithNavController:self.navigationController];

}

- (IBAction)openServicesButtonAction:(id)sender {
    [PCOEventLogger logEvent:@"Help - Services App"];
    if ([[UIApplication sharedApplication] canOpenURL:[self pcoAppURL]]) {
        [[UIApplication sharedApplication] openURL:[self pcoAppURL]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://ow.ly/qnxMV"]];
    }
}

- (IBAction)rateUsButtonAction:(id)sender {
    [PCOEventLogger logEvent:@"Help - Rate App"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://appstore.com/planningcenterprojector"]];
}

@end
