/*!
 * PROAppDelegate.h
 *
 *
 * Created by Skylar Schipper on 3/12/14
 */

#ifndef PROAppDelegate_h
#define PROAppDelegate_h

@import Foundation;
@import UIKit;

#import "PCOAuthentication.h"

#import "PROWindow.h"
#import "PROLeftSidebarTableViewController.h"
#import "MCTAlertView.h"

@class PCOSlidingSideViewController;

@interface PROAppDelegate : NSObject <UIApplicationDelegate, PCOAuthenticationAppDelegate, MCTAlertViewErrorDelegate>

@property (nonatomic, strong) PROWindow *window;
@property (nonatomic, weak, readonly) PCOSlidingSideViewController *rootViewController;

+ (instancetype)delegate;

- (BOOL)isPad;

#pragma mark -
#pragma mark - User Interface
- (void)presentLoginInterface;
- (void)presentMainUserInterface;

- (PCOSlidingSideViewController *)newMainUserInterfaceViewController;

- (void)presentSplashScreen;

@end

#endif
