/*!
 * PROAppDelegate.m
 *
 *
 * Created by Skylar Schipper on 3/12/14
 */

// Frameworks
#import <Crashlytics/Crashlytics.h>
#import <MCTFileDownloader/MCTFileDownloader.h>

// Random
#import "PROAppDelegate.h"
#import "PROSidebarBlurVendor.h"
#import "MCTAlertView.h"
#import "PCOKeyValueStore.h"
#import "MCTHelpDesk.h"
#import "ProjectorP2P_SessionManager.h"
#import "MCTDataStore.h"
#import "PCOURLActionHandler.h"
#import "PROSlideshow.h"

// View Controllers
#import "PCOLoginViewController.h"
#import "SplashScreenViewController.h"
#import "PROPlanNavigationController.h"
#import "PROPlanContainerViewController.h"
#import "HelpEmailSupportViewController.h"
#import "PROFirstLaunchViewController.h"

// Models
#import "PCOEmailAddress.h"

// Random
#import "PROLogo.h"
#import <AVFoundation/AVFoundation.h>
#import "PROUIOptimization.h"
#import "PCOAppState.h"

@interface PROAppDelegate () <MCTFDDownloaderAuthenticationDelegate>

@end

@implementation PROAppDelegate

#pragma mark -
#pragma mark - App Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    PCOLogDebug(@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);

    [self setupCrashReporting];
    
    [PCOEventLogger setup];
    [PCOEventLogger logEvent:@"Projector Running" timed:YES];
    
    [[PROUIOptimization sharedOptimizer] appColdStarted];
    
    [ProjectorSettings setDefaultValues];
    
    [self setupCoreDataStack];
    
    [self deleteOldFiles];
    
    [self setupURLHandlers];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupDefaultAppearance];
    });
    
    [[PROSecondScreenController sharedController] startListeningForScreenChanges];
    
    [[MCTHelpDesk sharedDesk] setAppName:@"projector_ios"];
    
    if (![PROSlideshow load]) {
        PCOLogError(@"Failed to load slideshows");
    }
    
    [[PRODownloader sharedDownloader] setDelegate:self];
    
    [self presentSplashScreen];
    [self setupAuthAndLogin];

    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];

    return YES;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.idleTimerDisabled = YES;
    [[PROUIOptimization sharedOptimizer] appWarmStarted];
    [[ProjectorP2P_SessionManager sharedManager] appDidBecomeActive];
    [[PROSecondScreenController sharedController] setSecondScreenEnabled:[[ProjectorSettings userSettings] secondScreenEnabled]];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    application.idleTimerDisabled = NO;
    if (![PROSlideshow save]) {
        PCOLogError(@"Failed to save slideshows");
    }
    [[PROSecondScreenController sharedController] teardownSecondScreenIfNeeded];
    [[ProjectorP2P_SessionManager sharedManager] appDidEnterBackground];
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [PROLogo clear];
}


#pragma mark -
#pragma mark - Helpers
+ (instancetype)delegate {
    return (PROAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)isPad {
    return NO;
}

#pragma mark -
#pragma mark - URL Helpers
- (void)setupURLHandlers {
    PCOURLSchemeAction *staging = [PCOURLSchemeStagingAction newStagingActionWithHandler:^(BOOL e) {
        [PCOServer setUsingStaging:e];
    }];
    [[PCOURLActionHandler appHandler] addAction:staging];
    
    
    PCOURLSchemeAction *resetState = [PCOURLSchemeAction schemeWithHost:@"reset" pattern:@"/state"];
    resetState.URLHandler = ^ BOOL (NSURL *URL, NSArray *matches) {
        [[PROStateSaver sharedState] flushState];
        return YES;
    };
    [[PCOURLActionHandler appHandler] addAction:resetState];
    
    
    PCOURLSchemeAction *resetKeychain = [PCOURLSchemeAction schemeWithHost:@"reset" pattern:@"/keychain"];
    resetKeychain.URLHandler = ^ BOOL (NSURL *URL, NSArray *matches) {
        [[PCOAuthentication defaultAuthentication] clearKeychainItemsAndLogout:YES];
        return YES;
    };
    [[PCOURLActionHandler appHandler] addAction:resetKeychain];
    
    PCOURLSchemeAction *resetCache = [PCOURLSchemeAction schemeWithHost:@"reset" pattern:@"/cache"];
    resetCache.URLHandler = ^ BOOL (NSURL *URL, NSArray *matches) {
        return [[MCTDataCacheController sharedCache] flush];
    };
    [[PCOURLActionHandler appHandler] addAction:resetCache];
    
    PCOURLSchemeAction *refreshPlan = [PCOURLSchemeAction schemeWithHost:@"refresh" pattern:@"/current-plan"];
    refreshPlan.URLHandler = ^ BOOL (NSURL *URL, NSArray *matches) {
        [[PROPlanContainerViewController currentContainer] updatePlanWithCompletion:nil];
        return YES;
    };
    [[PCOURLActionHandler appHandler] addAction:refreshPlan];

    PCOURLSchemeAction *demoMode = [PCOURLSchemeAction schemeWithHost:@"demo" pattern:@""];
    demoMode.URLHandler = ^ BOOL (NSURL *URL, NSArray *matches) {
        [PCOAppState setDemoModeEnabled:[URL.path isEqualToString:@"/enabled"]];
        return YES;
    };
    [[PCOURLActionHandler appHandler] addAction:demoMode];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[PCOURLActionHandler appHandler] handleURL:url]) {
        PCOLogDebug(@"Open URL with handler %@",url);
        return YES;
    } else {
        PCOLogDebug(@"****** No URL action for %@",url);
    }
    return YES;
}

#pragma mark -
#pragma mark - User Interface
- (PCOSlidingSideViewController *)rootViewController {
    PCOSlidingSideViewController *viewController = (PCOSlidingSideViewController *)self.window.rootViewController;
    if (![viewController isKindOfClass:[PCOSlidingSideViewController class]]) {
        return nil;
    }
    return viewController;
}
- (void)presentLoginInterface {
    [self presentSplashScreen];
    
    PCOLoginViewController *viewController = [PCOLoginViewController loginViewController];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}
- (void)presentMainUserInterface {
    if ([self.window.rootViewController isKindOfClass:[PCOSlidingSideViewController class]]) {
        return;
    }
    PROWindow *window = [[PROWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.tintColor = [UIColor projectorOrangeColor];
    window.rootViewController = [self newMainUserInterfaceViewController];
    [window makeKeyAndVisible];
    self.window = window;
    [[PROSecondScreenController sharedController] presentMainUserInterface];
    
    PCOPlan *plan = [[PROStateSaver sharedState] lastOpenPlan];
    if (plan) {
        [[PROUIOptimization sharedOptimizer] loadingAFreshPlan];
        [PROPlanContainerViewController displayPlan:plan];
    } else {
        [self.rootViewController showLeftMenuViewAnimated:NO completion:nil];
    }
}
- (PCOSlidingSideViewController *)newMainUserInterfaceViewController {
    PROPlanContainerViewController *planContainer = [[PROPlanContainerViewController alloc] initWithNibName:nil bundle:nil];
    PROPlanNavigationController *navigation = [[PROPlanNavigationController alloc] initWithRootViewController:planContainer];
    
    PCOSlidingSideViewController *slider = [[PCOSlidingSideViewController alloc] initWithLeftViewController:[[PROLeftSidebarTableViewController alloc] initWithNibName:nil bundle:nil]
                                                                                        rightViewController:nil
                                                                                      contentViewController:navigation];
    return slider;
}
- (void)presentSplashScreen {
    if ([self.window.rootViewController isKindOfClass:[SplashScreenViewController class]]) {
        return;
    }
    PROWindow *splashWindow = [[PROWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    splashWindow.rootViewController = [[SplashScreenViewController alloc] initWithNibName:@"SplashScreenViewController" bundle:[NSBundle mainBundle]];
    [((SplashScreenViewController *)splashWindow.rootViewController) showLoadingIndicator];
    [splashWindow makeKeyAndVisible];
    self.window = splashWindow;
}


- (void)setupCrashReporting {
}
- (void)setupCoreDataStack {
    [PCOCoreDataManager setManagedObjectModelName:@"PCODataModel"];
}
- (void)setupAuthAndLogin {
    [[PCOAuthentication defaultAuthentication] setConsumerKey:nil consumerSecret:nil];
    [[PCOAuthentication defaultAuthentication] loginWithDelegate:self];
    [PCOEventLogger logEvent:@"Logged In"];
}

#pragma mark -
#pragma mark - Auth Delegate
- (BOOL)authentication:(PCOAuthentication *)authentication appEnabledForOrganization:(PCOOrganization *)organization {
    return [[organization projectorEnabled] boolValue];
}
- (void)authentication:(PCOAuthentication *)authentication didLoginWithUser:(PCOUserData *)user organization:(PCOOrganization *)organization {
    NSString *userInfo = [NSString stringWithFormat:@"%@:%@",user.accountCenterId,organization.accountCenterId];
    [[Crashlytics sharedInstance] setUserIdentifier:userInfo];
    PCOEmailAddress *address = [[user.emailAddresses allObjects] firstObject];
    NSString *email = address.address;
    [[Crashlytics sharedInstance] setUserEmail:email];
    [[Crashlytics sharedInstance] setUserName:[user fullName]];
    
    [[[PCOCoreDataManager sharedManager] peopleController] updateAllDataForCurrentUserCompletion:nil];
    
    NSString *infoString = [NSString stringWithFormat:@"%@:%@:%@:%@",user.remoteId,[user fullName],user.permissions,user.accountCenterId];
    [[PCOLumberYard foreman] logData:[infoString dataUsingEncoding:NSUTF8StringEncoding]];
    [self presentMainUserInterface];
    [[ProjectorP2P_SessionManager sharedManager] restoreSavedSession];
    
    [PROFirstLaunchViewController presentFromViewController:self.rootViewController];
}

- (void)authentication:(PCOAuthentication *)authentication didFailWithError:(NSError *)error {
    if (error.code == PCOAuthenticationErrorFailedToGetTokens && ![PCOServer networkReachable]) {
        [[[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't log in", nil)
                                     message:NSLocalizedString(@"Your device appears to be offline. Please reconnect to the internet and try again.", nil)
                           cancelButtonTitle:ProjectorOkString] show];
        return;
    }
    if (error.code == PCOAuthenticationErrorAppNotAvailableForOrganization) {
        [[[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't log in", nil)
                                     message:[error localizedDescription]
                           cancelButtonTitle:ProjectorOkString] show];
    }
    if (error.userInfo[NSUnderlyingErrorKey]) {
        [MCTAlertView showError:error.userInfo[NSUnderlyingErrorKey]];
        return;
    }
    
    [[PCOAuthentication defaultAuthentication] loginWithDelegate:self];
}

- (void)authenticationDidLogout:(PCOAuthentication *)authentication withError:(NSError *)error {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    [[PROStateSaver sharedState] flushState];

    [self presentSplashScreen];
}

- (void)authenticationShouldPresentAuthenticationUserInterface:(PCOAuthentication *)authentication {
    [self presentLoginInterface];
}

- (void)authenticationShouldAskToLogout:(PCOAuthentication *)authentication {
    NSString *title = NSLocalizedString(@"Logout", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    if ([[PCOSavedUsersController sharedController] hasUserWithRemoteID:authentication.currentUser.remoteId]) {
        MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:title message:NSLocalizedString(@"Are you sure you want to logout?", nil) cancelButtonTitle:cancel];
        
        [alert addActionWithTitle:NSLocalizedString(@"Logout", nil) handler:^(MCTAlertViewAction *action) {
            [PCOEventLogger logEvent:@"Logged Out"];
            [[PCOAuthentication defaultAuthentication] logout];
        }];
        
        [alert show];
        
        return;
    }
    MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:title message:NSLocalizedString(@"Save your login to sign in more quickly later?", nil) cancelButtonTitle:cancel];
    
    [alert addActionWithTitle:NSLocalizedString(@"Logout", nil) handler:^(MCTAlertViewAction *action) {
        [PCOEventLogger logEvent:@"Logged Out"];
        [[PCOAuthentication defaultAuthentication] logout];
    }];
    [alert addActionWithTitle:NSLocalizedString(@"Save and Logout", nil) handler:^(MCTAlertViewAction *action) {
        PCOAuthentication *auth = [PCOAuthentication defaultAuthentication];
        PCOSavedUser *user = [PCOSavedUser currentUserObject];
        user.remoteID = auth.currentUser.remoteId;
        user.fullName = [auth.currentUser fullName];
        user.orgName = [auth.currentOrganization localizedDescription];
        
        if ([user isValid] && [[PCOSavedUsersController sharedController] saveUser:user]) {
            PCOLogInfo(@"Saved user %lli",user.objectID);
        }
        
        [PCOEventLogger logEvent:@"Logged Out"];
        [[PCOAuthentication defaultAuthentication] logout];
    }];
    
    [alert show];
}

#pragma mark -
#pragma mark - Appearance
- (void)setupDefaultAppearance {
    [MCTAlertViewConfiguration setTitleFont:[UIFont boldDefaultFontOfSize_18]];
    [MCTAlertViewConfiguration setMessageFont:[UIFont defaultFontOfSize_16]];
    [MCTAlertViewConfiguration setButtonsFont:[UIFont boldDefaultFontOfSize_16]];
    [MCTAlertViewConfiguration setAlertBackingColor:[[UIColor sidebarBackgroundColor] colorWithAlphaComponent:0.6]];
}

#pragma mark -
#pragma mark - Clear Old Files
- (void)deleteOldFiles {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(queue, ^{
        [[PRODownloader sharedDownloader] clearTempFiles];
        NSTimeInterval timeInter = ProjectorFileStorageDurationInterval([[ProjectorSettings userSettings] fileStorageDuration]);
        NSDate *time = [NSDate dateWithTimeIntervalSinceNow:-timeInter];
        NSArray *files = [[MCTDataStore sharedStore] allFilesWithPredicate:[NSPredicate predicateWithFormat:@"%K < %@",kMCTDataStorePredicateLastAccessed,time]];
        for (NSDictionary *file in files) {
            NSError *error = nil;
            if (![[MCTDataStore sharedStore] deleteFileWithName:file[kMCTDataStoreName] key:file[kMCTDataStoreKey] error:&error]) {
                PCOLogError(@"Failed to delte file %@ with error %@",file,error);
            } else {
                PCOLogDebug(@"Deleted file: %@",file[kMCTDataStoreName]);
            }
        }
    });
}

#pragma mark -
#pragma mark - Send Error
- (void)presentHelpDeskEmailSupportWithError:(NSError *)error {
    HelpEmailSupportViewController *controller = [[HelpEmailSupportViewController alloc] initWithNibName:@"HelpEmailSupportViewController" bundle:[NSBundle mainBundle]];
    
    controller.reportError = error;
    
    PCONavigationController *navigation = [[PCONavigationController alloc] initWithRootViewController:controller];
    navigation.navigationBar.translucent = NO;
    navigation.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.window.rootViewController presentViewController:navigation animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Downloader
- (NSURLRequest *)downloader:(PRODownloader *)downloader finializeRequest:(NSURLRequest *)request {
    if ([request.URL isPlanningCenter]) {
        return [PCOServer signedRequestFromRequest:request];
    }
    return request;
}

@end
