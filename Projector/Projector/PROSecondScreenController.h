/*!
 * PROSecondScreenController.h
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#ifndef PROSecondScreenController_h
#define PROSecondScreenController_h

@import UIKit;
@import Foundation;
@class PRODisplayItem;

@class SecondScreenViewController;

@interface PROSecondScreenController : NSObject

+ (instancetype)sharedController;

- (void)presentMainUserInterface;

#pragma mark -
#pragma mark - Screens
- (BOOL)hasSecondScreenConnected;
- (void)startListeningForScreenChanges;
- (void)stopListeningForScreenChanges;
- (void)teardownSecondScreenIfNeeded;

- (UIScreen *)secondScreen;

- (BOOL)isDisplayingToSecondScreen;

#pragma mark -
#pragma mark - Settings
@property (nonatomic, assign, getter = isSecondScreenEnabled) BOOL secondScreenEnabled;

#pragma mark -
#pragma mark - Views
- (SecondScreenViewController *)newSecondScreenViewController;
- (SecondScreenViewController *)secondScreenViewController;

- (void)displayItem:(PRODisplayItem *)item;

@end

#endif
