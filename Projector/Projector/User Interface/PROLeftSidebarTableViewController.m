/*!
 * PROLeftSidebarTableViewController.m
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#import "PROLeftSidebarTableViewController.h"

#import "PCOAppState.h"

// View Controllers
#import "PRONavigationController.h"
#import "HelpViewController.h"
#import "PROSettingsViewController.h"

// Views
#import "LeftSidebarProfileView.h"
#import "LeftSidebarFooterView.h"

@interface PROLeftSidebarTableViewController ()

@property (nonatomic, weak) LeftSidebarProfileView *profileView;

@property (nonatomic, weak) PCOView *contentView;

@property (nonatomic, weak) LeftSidebarFooterView *footerView;

@end

@implementation PROLeftSidebarTableViewController

- (void)loadView {
    [super loadView];
    [self updateProfileView];
    
    PCOKitLazyLoad(self.tabController);
    
    [self.footerView.logoutButton addTarget:self action:@selector(logoutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView.helpButton addTarget:self action:@selector(helpButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView.settingsButton addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark - Profile
- (void)updateProfileView {
    self.profileView.organization = [PCOOrganization current];
    self.profileView.user = [PCOUserData current];
}
- (LeftSidebarProfileView *)profileView {
    if (!_profileView) {
        LeftSidebarProfileView *profileView = [LeftSidebarProfileView newAutoLayoutView];
        
        _profileView = profileView;
        [self.view addSubview:profileView];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                     @"V:|[profileView]",
                                                                                     @"H:|[profileView]|"
                                                                                     ]
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(profileView)]];
    }
    return _profileView;
}
- (LeftSidebarFooterView *)footerView {
    if (!_footerView) {
        LeftSidebarFooterView *footerView = [LeftSidebarFooterView newAutoLayoutView];
        
        _footerView = footerView;
        [self.view addSubview:footerView];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                     @"V:[footerView]|",
                                                                                     @"H:|[footerView]|"
                                                                                     ]
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(footerView)]];
    }
    return _footerView;
}
- (PCOView *)contentView {
    if (!_contentView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        
        _contentView = view;
        [self.view addSubview:view];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                     @"V:[head]-padding-[view]-padding-[foot]",
                                                                                     @"H:|[view]|"
                                                                                     ]
                                                                           metrics:@{
                                                                                     @"padding": @(PCOKitMainScreenHairLine(1.0))
                                                                                     }
                                                                             views:@{
                                                                                     @"head": self.profileView,
                                                                                     @"view": view,
                                                                                     @"foot": self.footerView
                                                                                     }]];
    }
    return _contentView;
}

- (PROSidebarTabController *)tabController {
    if (!_tabController) {
        PROSidebarTabController *sidebar = [[PROSidebarTabController alloc] initWithNibName:nil bundle:nil];
        [self addChildViewController:sidebar];
        sidebar.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:sidebar.view];
        
        [self.contentView addConstraints:[NSLayoutConstraint fitView:sidebar.view inView:self.contentView insets:UIEdgeInsetsZero]];
        
        [sidebar didMoveToParentViewController:self];
        _tabController = sidebar;
    }
    return _tabController;
}

#pragma mark -
#pragma mark - Logout
- (void)logoutButtonAction:(id)sender {
    if ([PCOAppState isDemoModeEnabled]) {
        MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Demo Mode", nil)
                                                          message:NSLocalizedString(@"Projector is currently in demo mode.  Logout has been disabled.", nil)
                                                cancelButtonTitle:NSLocalizedString(@"OK", nil)];
        [alert show];
        return;
    }
    [[PCOAuthentication defaultAuthentication] logoutWithConformation];
}

#pragma mark -
#pragma mark - Help
- (void)helpButtonAction:(id)sender {
    HelpViewController *help = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:[NSBundle mainBundle]];
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:help];
    navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navigation.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Settings
- (void)settingsButtonAction:(id)sender {
    PROSettingsViewController *settings = [[PROSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:settings];
    navigation.modalPresentationStyle = UIModalPresentationPopover;
    navigation.popoverPresentationController.sourceView = sender;
    navigation.popoverPresentationController.sourceRect = CGRectMake(PCOKitRectGetHalfWidth([sender bounds]), 0.0, 0.0, 0.0);
    
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark -
#pragma mark - PCOSlidingSideViewControllerDelegate
- (void)willShowFromSlideController:(PCOSlidingSideViewController *)slideController {
    [self updateProfileView];
}
- (void)didShowFromSlideController:(PCOSlidingSideViewController *)slideController {
    
}
- (void)wasDismissedFromSlideController:(PCOSlidingSideViewController *)slideController {
    
}

@end
