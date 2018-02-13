/*!
 * PRONavigationController.m
 *
 *
 * Created by Skylar Schipper on 3/12/14
 */

#import "PRONavigationController.h"

@interface PRONavigationController ()

@end

@implementation PRONavigationController

- (void)initializeDefaults {
    [super initializeDefaults];
    self.navigationBar.translucent = NO;
    self.barStyle = PRONavigationControllerBarDefaultStyle;
}

- (void)loadView {
    [super loadView];
    [self updateCurrentBarStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.popoverPresentationController) {
        self.popoverPresentationController.backgroundColor = [UIColor projectorBlackColor];
        if (![[PROAppDelegate delegate] isPad]) {
            self.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissPopoverViewController:)];
        }
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[PROAppDelegate delegate] isPad]) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupAppearance];
    });
}

+ (void)setupAppearance {
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTitleTextAttributes:[self titleTextAttrsForStyle:PRONavigationControllerBarDefaultStyle]];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBarTintColor:[self barTintColorForStyle:PRONavigationControllerBarDefaultStyle]];
    [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTintColor:[self tintColorForStyle:PRONavigationControllerBarDefaultStyle]];
}

+ (NSDictionary *)titleTextAttrsForStyle:(PRONavigationControllerBarStyle)style {
    return @{
             NSFontAttributeName: [UIFont boldDefaultFontOfSize_18],
             NSForegroundColorAttributeName: [self barTextColorForStyle:style]
             };
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setBarStyle:(PRONavigationControllerBarStyle)barStyle {
    _barStyle = barStyle;
    [self updateCurrentBarStyle];
}
- (void)updateCurrentBarStyle {
    self.navigationBar.barTintColor = [[self class] barTintColorForStyle:self.barStyle];
    self.navigationBar.tintColor = [[self class] tintColorForStyle:self.barStyle];
    self.navigationBar.titleTextAttributes = [[self class] titleTextAttrsForStyle:self.barStyle];
}

+ (UIColor *)barTintColorForStyle:(PRONavigationControllerBarStyle)style {
    

    return [UIColor navigationBarDefaultColor];
}
+ (UIColor *)tintColorForStyle:(PRONavigationControllerBarStyle)style {
    
    return [UIColor navigationBarDefaultTintColor];
}
+ (UIColor *)barTextColorForStyle:(PRONavigationControllerBarStyle)style {
    
    return [UIColor whiteColor];
}

// MARK: - Popover
- (void)dismissPopoverViewController:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
