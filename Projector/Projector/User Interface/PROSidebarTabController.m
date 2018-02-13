/*!
 * PROSidebarTabController.m
 *
 *
 * Created by Skylar Schipper on 3/17/14
 */

#import "PROSidebarTabController.h"

// View Controllers
#import "PROLeftSidebarNavigationController.h"
#import "PlanListServiceTypesController.h"
#import "FilesListTableViewController.h"
#import "P2P_SessionsTableViewController.h"

// Elements
#import "SidebarRoundButton.h"

@interface PROSidebarTabController ()

@property (nonatomic, weak) PCOView *switcherView;
@property (nonatomic, weak) PCOView *contentView;

@property (nonatomic, weak) SidebarRoundButton *planButton;
@property (nonatomic, weak) SidebarRoundButton *filesButton;
@property (nonatomic, weak) SidebarRoundButton *sessionsButton;

@property (nonatomic, assign, getter = isAnimating) BOOL animating;

@property (nonatomic, assign, readwrite) NSUInteger currentSelectedIndex;

@end

@implementation PROSidebarTabController

- (void)initializeDefaults {
    [super initializeDefaults];
    self.currentSelectedIndex = NSNotFound;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    NSUInteger lastSection = [[[PROStateSaver sharedState] lastSidebarTabOpen] unsignedLongValue];
    if (lastSection == 1) {
        [self presentFilesViewAnimated:YES];
    } else if (lastSection == 2) {
        [self presentSessionViewAnimated:YES];
    } else {
        [self presentPlanViewAnimated:YES];
    }
    
    PCOKitLazyLoad(self.contentView);
    PCOKitLazyLoad(self.planButton);
    PCOKitLazyLoad(self.filesButton);
    PCOKitLazyLoad(self.sessionsButton);
}

#pragma mark -
#pragma mark - Lazy Loaders
- (PCOView *)contentView {
    if (!_contentView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        
        _contentView = view;
        [self.view insertSubview:view aboveSubview:self.switcherView];
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.switcherView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
    }
    return _contentView;
}
- (PCOView *)switcherView {
    if (!_switcherView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor sessionsCellNormalBackgroundColor];
        
        _switcherView = view;
        [self.view addSubview:view];
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeTop]];
        [self.view addConstraint:[NSLayoutConstraint height:80.0 forView:view]];
    }
    return _switcherView;
}
- (SidebarRoundButton *)planButton {
    if (!_planButton) {
        SidebarRoundButton *button = [SidebarRoundButton newAutoLayoutView];
        [button addTarget:self action:@selector(transitionToViewControllerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.image = [[UIImage imageNamed:@"sidebar_plans"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _planButton = button;
        [self.switcherView addSubview:button];
        
        [self.switcherView addConstraint:[NSLayoutConstraint centerVertical:button inView:self.switcherView]];
        [self.switcherView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.filesButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-20.0]];
    }
    return _planButton;
}
- (SidebarRoundButton *)filesButton {
    if (!_filesButton) {
        SidebarRoundButton *button = [SidebarRoundButton newAutoLayoutView];
        [button addTarget:self action:@selector(transitionToViewControllerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.image = [[UIImage imageNamed:@"sidebar_files"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        _filesButton = button;
        [self.switcherView addSubview:button];
        
        [self.switcherView addConstraints:[NSLayoutConstraint center:button inView:self.switcherView]];
    }
    return _filesButton;
}
- (SidebarRoundButton *)sessionsButton {
    if (!_sessionsButton) {
        SidebarRoundButton *button = [SidebarRoundButton newAutoLayoutView];
        [button addTarget:self action:@selector(transitionToViewControllerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.image = [[UIImage imageNamed:@"sidebar_sessions"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        _sessionsButton = button;
        [self.switcherView addSubview:button];
        
        [self.switcherView addConstraint:[NSLayoutConstraint centerVertical:button inView:self.switcherView]];
        [self.switcherView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.filesButton attribute:NSLayoutAttributeRight multiplier:1.0 constant:20.0]];
    }
    return _sessionsButton;
}

#pragma mark -
#pragma mark - Button Actions
- (void)transitionToViewControllerButtonAction:(id)sender {
    if (sender == self.planButton) {
        [self presentPlanViewAnimated:YES];
    }
    if (sender == self.filesButton) {
        [self presentFilesViewAnimated:YES];
    }
    if (sender == self.sessionsButton) {
        [self presentSessionViewAnimated:YES];
    }
}

- (void)presentPlanViewAnimated:(BOOL)animated {
    [PCOEventLogger logEvent:@"Plans Tab Selected"];
    [self presentTabViewController:[self newPlanListViewController] animated:animated index:0 fromButton:self.planButton];
}
- (void)presentFilesViewAnimated:(BOOL)animated {
    [PCOEventLogger logEvent:@"Files Tab Selected"];
    [self presentTabViewController:[self newFilesViewController] animated:animated index:1 fromButton:self.filesButton];
}
- (void)presentSessionViewAnimated:(BOOL)animated {
    [PCOEventLogger logEvent:@"Sessions Tab Selected"];
    [self presentTabViewController:[self newSessionsViewController] animated:animated index:2 fromButton:self.sessionsButton];
}

#pragma mark -
#pragma mark - Present View controller
- (void)presentTabViewController:(UIViewController *)controller animated:(BOOL)animated index:(NSUInteger)index fromButton:(SidebarRoundButton *)button {
    if ([self isAnimating] || self.currentSelectedIndex == index) {
        return;
    }
    
    self.currentSelectedIndex = index;
    [[PROStateSaver sharedState] setLastSidebarTabOpen:@(index)];
    
    self.planButton.selected = NO;
    self.filesButton.selected = NO;
    self.sessionsButton.selected = NO;
    button.selected = YES;
    
    self.animating = YES;
    UIViewController *currentController = self.currentViewController;
    if (self.currentViewController) {
        [self.currentViewController willMoveToParentViewController:nil];
        [self.currentViewController removeFromParentViewController];
        _currentViewController = nil;
    }
    
    CGRect buttonFrame = [self.contentView convertRect:button.frame fromView:button.superview];
    controller.view.layer.masksToBounds = YES;
    controller.view.frame = buttonFrame;
    [self addChildViewController:controller];
    [self.contentView addSubview:controller.view];
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _currentViewController = controller;
    
    if (!animated) {
        [currentController.view removeFromSuperview];
        [currentController didMoveToParentViewController:nil];
        self.currentViewController.view.frame = self.contentView.bounds;
        [self.currentViewController didMoveToParentViewController:self];
        return;
    }
    
    CGRect startRect = buttonFrame;
    startRect.origin.y = 0;
    
    UIView *overCastView = [[UIView alloc] initWithFrame:buttonFrame];
    overCastView.backgroundColor = [UIColor projectorOrangeColor];
    overCastView.layer.cornerRadius = button.layer.cornerRadius;
    [self.contentView addSubview:overCastView];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.duration = 0.14;
    animation.fromValue = @(button.layer.cornerRadius);
    animation.toValue = @(0.0);
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    [controller.view.layer addAnimation:animation forKey:@"cornerRadius"];
    
    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.7 animations:^{
            currentController.view.alpha = 0.0;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.2 animations:^{
            self.currentViewController.view.frame = startRect;
            overCastView.alpha = 0.0;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.2 animations:^{
            self.currentViewController.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(startRect));
        }];
        [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.6 animations:^{
            self.currentViewController.view.frame = self.contentView.bounds;
        }];
    } completion:^(BOOL finished) {
        [overCastView removeFromSuperview];
        [self.currentViewController didMoveToParentViewController:self];
        self.currentViewController.view.layer.masksToBounds = NO;
        [currentController.view removeFromSuperview];
        [currentController didMoveToParentViewController:nil];
        self.animating = NO;
    }];
}

#pragma mark -
#pragma mark - View Controllers
- (id)newPlanListViewController {
    PlanListServiceTypesController *planList = [[PlanListServiceTypesController alloc] initWithNibName:nil bundle:nil];
    return [[PROLeftSidebarNavigationController alloc] initWithRootViewController:planList];
}
- (id)newFilesViewController {
    FilesListTableViewController *files = [[FilesListTableViewController alloc] initWithNibName:nil bundle:nil];
    return [[PROLeftSidebarNavigationController alloc] initWithRootViewController:files];;
}
- (id)newSessionsViewController {
    P2P_SessionsTableViewController *viewController = [[P2P_SessionsTableViewController alloc] initWithNibName:nil bundle:nil];
    viewController.view.backgroundColor = [UIColor sidebarBackgroundColor];
    return viewController;
}

@end
