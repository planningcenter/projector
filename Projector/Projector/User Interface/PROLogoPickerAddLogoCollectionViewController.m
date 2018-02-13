/*!
 * PROLogoPickerAddLogoCollectionViewController.m
 *
 *
 * Created by Skylar Schipper on 6/30/14
 */

#import "PROLogoPickerAddLogoCollectionViewController.h"
#import "LogoPickerPlanMediaViewController.h"
#import "LogoPickerAllMediaViewController.h"
#import "NSArrayAdditions.h"
#import "PROStateSaver.h"

@interface PROLogoPickerAddLogoCollectionViewController ()

@property (nonatomic, weak) PCOView *headerView;

@property (nonatomic, weak) UIViewController *currentSegmentController;

@property (nonatomic, weak) PCOButton *allMediaButton;
@property (nonatomic, weak) PCOButton *planMediaButton;

@end

@implementation PROLogoPickerAddLogoCollectionViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor mediaSelectedCellBackgroundColor];
    
    [self showSegment:[[[PROStateSaver sharedState] addLogoSection] integerValue] animated:NO];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                 @"H:|[all]-1-[plan(==all)]|"
                                                                                 ]
                                                                       metrics:nil
                                                                         views:@{
                                                                                 @"all": self.allMediaButton,
                                                                                 @"plan": self.planMediaButton
                                                                                 }]];
    
    self.title = NSLocalizedString(@"Add Logo", nil);
    [self addBackButtonWithString:NSLocalizedString(@"Logo", nil)];
}

- (void)showSegment:(NSInteger)segment animated:(BOOL)animated {
    UIViewController *controller = [self newSegmentControllerForSegment:segment];
    UIViewController *oldController = self.currentSegmentController;
    
    if (segment == 0) {
        self.allMediaButton.selected = YES;
        self.planMediaButton.selected = NO;
    } else {
        self.allMediaButton.selected = NO;
        self.planMediaButton.selected = YES;
    }
    
    [[PROStateSaver sharedState] setAddLogoSection:@(segment)];
    
    self.currentSegmentController = controller;
    
    controller.preferredContentSize = self.preferredContentSize;
    
    [oldController willMoveToParentViewController:nil];
    
    if (controller) {
        [self addChildViewController:controller];
        
        controller.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:controller.view];
        controller.view.alpha = 0.0;
        
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:controller.view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.headerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
    
    void(^animation)(void) = ^{
        controller.view.alpha = 1.0;
    };
    void(^completion)(BOOL) = ^(BOOL f) {
        [oldController removeFromParentViewController];
        [oldController.view removeFromSuperview];
        [oldController didMoveToParentViewController:nil];
        [controller didMoveToParentViewController:self];
    };
    
    [UIView performWithoutAnimation:^{
        [self.view layoutIfNeeded];
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:animation completion:completion];
    } else {
        animation();
        completion(YES);
    }
}

- (UIViewController *)newSegmentControllerForSegment:(NSInteger)segment {
    PROLogoPickerAddLogoSubViewController *controller = nil;
    if (segment == 0) {
        controller = [[LogoPickerAllMediaViewController alloc] initWithNibName:nil bundle:nil];
    }
    if (segment == 1) {
        controller = [[LogoPickerPlanMediaViewController alloc] initWithNibName:nil bundle:nil];
    }
    controller.plan = self.plan;
    return controller;
}

#pragma mark -
#pragma mark - Lazy Loaders
- (PCOView *)headerView {
    if (!_headerView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor logoPickerStrokeColor];
        view.clipsToBounds = YES;
        
        _headerView = view;
        [self.view addSubview:view];
        
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeTop]];
        [self.view addConstraint:[NSLayoutConstraint height:44.0 forView:view]];
    }
    return _headerView;
}
- (PCOButton *)allMediaButton {
    if (!_allMediaButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        [button setTitleColor:[UIColor logoPickerStrokeColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor projectorOrangeColor] forState:UIControlStateSelected];
        [button setBackgroundColor:[UIColor mediaSelectedCellBackgroundColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor mediaSelectedCellBackgroundColor] forState:UIControlStateSelected];
        [button setBackgroundColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [button setTitle:NSLocalizedString(@"All Media", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(allMediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [PCOFont defaultFontOfSize_16];
        
        _allMediaButton = button;
        [self.headerView addSubview:button];
        
        [self.headerView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:1.0 edges:UIRectEdgeBottom]];
        [self.headerView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:0.0 edges:UIRectEdgeTop]];
    }
    return _allMediaButton;
}
- (PCOButton *)planMediaButton {
    if (!_planMediaButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        [button setTitleColor:[UIColor logoPickerStrokeColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor projectorOrangeColor] forState:UIControlStateSelected];
        [button setBackgroundColor:[UIColor mediaSelectedCellBackgroundColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor mediaSelectedCellBackgroundColor] forState:UIControlStateSelected];
        [button setBackgroundColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [button setTitle:NSLocalizedString(@"Plan Media", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(planMediaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [PCOFont defaultFontOfSize_16];
        
        _planMediaButton = button;
        [self.headerView addSubview:button];
        
        [self.headerView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:1.0 edges:UIRectEdgeBottom]];
        [self.headerView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:0.0 edges:UIRectEdgeTop]];
    }
    return _planMediaButton;
}

#pragma mark -
#pragma mark - Actions
- (void)allMediaButtonAction:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    [self showSegment:0 animated:YES];
}
- (void)planMediaButtonAction:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    [self showSegment:1 animated:YES];
}

@end
