/*!
 * PROSecondScreenController.m
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */


#import "PROSecondScreenController.h"
#import "PCOKeyValueStore.h"
#import "ProjectorSettings.h"

// View Controllers
#import "SecondScreenViewController.h"

id static _sharedPROSecondScreenController = nil;

@interface PROSecondScreenController ()

@property (nonatomic, strong) PROWindow *window;

@end

@implementation PROSecondScreenController


#pragma mark -
#pragma mark - Initialization
- (id)init {
	self = [super init];
	if (self) {
        welf();
        [[NSNotificationCenter defaultCenter] addObserverForName:kProjectorSecondScreenEnabledSetting object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [welf _updateSecondScreenState];
        }];
        [self _updateSecondScreenState];
	}
	return self;
}
- (void)dealloc {
    [self stopListeningForScreenChanges];
}

#pragma mark -
#pragma mark - Singleton
+ (instancetype)sharedController {
	@synchronized (self) {
        if (!_sharedPROSecondScreenController) {
            _sharedPROSecondScreenController = [[[self class] alloc] init];
        }
        return _sharedPROSecondScreenController;
    }
}

#pragma mark -
#pragma mark - Screen Notifications
- (void)startListeningForScreenChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidAddScreen:) name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRemoveScreen:) name:UIScreenDidDisconnectNotification object:nil];
}
- (void)stopListeningForScreenChanges {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
}
- (void)deviceDidAddScreen:(NSNotification *)notif {
    if ([self isSecondScreenEnabled]) {
        [PCOEventLogger logEvent:@"External Screen Connected"];
        [self setupSecondScreenIfNeeded];
    }
}
- (void)deviceDidRemoveScreen:(NSNotification *)notif {
    [PCOEventLogger logEvent:@"External Screen Disconnected"];
    [self teardownSecondScreenIfNeeded];
}

- (UIScreen *)secondScreen {
    if (![self hasSecondScreenConnected]) {
        return nil;
    }
    return [[UIScreen screens] lastObject];
}

- (void)presentMainUserInterface {
    if ([self hasSecondScreenConnected] && [self isSecondScreenEnabled]) {
        [self setupSecondScreenIfNeeded];
    }
}

- (BOOL)isDisplayingToSecondScreen {
    return ([self hasSecondScreenConnected] && self.window != nil);
}

#pragma mark -
#pragma mark - Second Screen
- (BOOL)hasSecondScreenConnected {
    return ([[UIScreen screens] count] > 1);
}

- (void)setupSecondScreenIfNeeded {
    UIScreen *screen = [self secondScreen];
    if (!self.window && screen) {
        screen.overscanCompensation = UIScreenOverscanCompensationInsetApplicationFrame;
        self.window = [[PROWindow alloc] initWithFrame:[screen applicationFrame]];
        self.window.screen = screen;
        self.window.rootViewController = [self newSecondScreenViewController];
        PCOLogDebug(@"Setting up second screen window");
    }
    [self.window makeKeyAndVisible];
}
- (void)teardownSecondScreenIfNeeded {
    if (self.window) {
        PCOLogDebug(@"Tearing down second screen window");
        [self.window.rootViewController.view removeFromSuperview];
        [self.window removeFromSuperview];
        self.window = nil;
    }
}

- (void)setSecondScreenEnabled:(BOOL)secondScreenEnabled {
    [[ProjectorSettings userSettings] setSecondScreenEnabled:secondScreenEnabled];
    [self _updateSecondScreenState];
}
- (BOOL)isSecondScreenEnabled {
    return [[ProjectorSettings userSettings] secondScreenEnabled];
}
- (void)_updateSecondScreenState {
    if (!self.secondScreenEnabled) {
        [self teardownSecondScreenIfNeeded];
    } else {
        [self setupSecondScreenIfNeeded];
    }
}

#pragma mark -
#pragma mark - Views
- (SecondScreenViewController *)newSecondScreenViewController {
    return [[SecondScreenViewController alloc] initWithNibName:nil bundle:nil];
}

- (SecondScreenViewController *)secondScreenViewController {
    return (SecondScreenViewController *)self.window.rootViewController;
}

- (void)displayItem:(PRODisplayItem *)item {
    [[[self secondScreenViewController] displayView] setItem:item animated:YES];
}

@end
