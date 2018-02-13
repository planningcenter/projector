/*!
 * PROModalViewController.m
 *
 *
 * Created by Skylar Schipper on 4/14/14
 */

#import "PROModalViewController.h"
#import "PCOModalPresentationController.h"

@interface PROModalViewController ()

@end

@implementation PROModalViewController

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController {
    PROModalNavigationController *nav = [[PROModalNavigationController alloc] initWithRootViewController:contentViewController];
    self = [super initWithContentViewController:nav];
    if (self) {
        
    }
    return self;
}

- (void)configureContainerView:(UIView *)view {
    if ([[UIDevice currentDevice] isPad]) {
        view.backgroundColor = [UIColor modalViewBackgroundColor];
        view.layer.borderColor = [[UIColor modalViewStrokeColor] CGColor];
        view.layer.borderWidth = 1.0;
        view.layer.cornerRadius = 8.0;
        view.layer.masksToBounds = YES;
    }
}

- (CGSize)preferredContentSize {
    return [[((PROModalNavigationController *)self.contentViewController) topViewController] preferredContentSize];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[PCOModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end


@implementation PROModalNavigationController

- (void)initializeDefaults {
    [super initializeDefaults];
    self.navigationBar.translucent = NO;
    self.navigationBar.layer.borderWidth = 1.0;
    self.navigationBar.layer.borderColor = [[UIColor modalViewStrokeColor] CGColor];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setBarTintColor:[UIColor modalViewHeaderViewBackgroundColor]];
        [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTitleTextAttributes:@{
                                                                                                NSFontAttributeName: [UIFont boldDefaultFontOfSize_14],
                                                                                                NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                                                }];
        [[UINavigationBar appearanceWhenContainedIn:[self class], nil] setTintColor:[UIColor navigationBarDefaultTintColor]];
    });
}

@end
