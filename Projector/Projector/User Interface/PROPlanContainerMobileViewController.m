/*!
 * PROPlanContainerMobileViewController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/1/14
 */

#import "PROPlanContainerMobileViewController.h"
#import "PRODisplayController.h"
#import "PlanViewMobileGridTableViewController.h"
#import "PlanViewMobileGridTopBarView.h"
#import "PlanViewMobileInfoView.h"
#import "PROLogoDisplayItem.h"
#import "PROBlackItem.h"
#import "LoopingPlaylistManager.h"
#import "PROSlideManager.h"
#import "PROOptionsButton.h"
#import "PlanViewMobileGridOptionsTableViewController.h"
#import "PROLogoPickerViewController.h"
#import "PRONavigationController.h"
#import "PROUIOptimization.h"
#import "PRORecordingController.h"
#import "PRORecordingsListViewController.h"

static CGFloat PROPlanContainerMobileButtonOffset = 10.0;

@interface PROPlanContainerMobileViewController () <PROContainerViewControllerEventListener, PlanViewMobileGridOptionsTableViewControllerDelegate, PROLogoPickerViewControllerDelegate>

@property (nonatomic, weak) PRODisplayView *outputView;
@property (nonatomic, weak) PlanViewMobileInfoView *infoView;

@property (nonatomic, weak) PROOptionsButton *optionsButton;
@property (nonatomic, weak) NSLayoutConstraint *optionsButtonBottomOffset;
@property (nonatomic, weak) PCOView *optionsContainerView;
@property (nonatomic, weak) NSLayoutConstraint *optionsViewButtonOffsetConstraint;
@property (nonatomic, weak) PlanViewMobileGridOptionsTableViewController *optionsController;

@property (nonatomic, weak) PlanViewMobileGridTableViewController *mobileGridController;

@property (nonatomic, weak) NSLayoutConstraint *outputViewHeight;
@property (nonatomic, weak) NSLayoutConstraint *outputViewWidth;

@property (nonatomic, strong) PRODisplayItem *currentItem;
@property (nonatomic, strong) PRODisplayItem *nextItem;

@property (nonatomic, strong) NowPlayingInterfaceController *nowPlayingInterfaceController;
@property (nonatomic, strong) PROLogo *currentLogo;

@property (nonatomic, strong) PROFullScreenCurrentViewController *fullScreenController;

@end

@implementation PROPlanContainerMobileViewController

// MARK: - Play Slides
- (void)currentItemDidChange:(PRODisplayItem *)currentItem {
    self.currentItem = currentItem;
    
    self.infoView.textLabel.text = currentItem.titleString;
    self.infoView.loopingIcon.hidden = YES;
    if ([self.currentItem isMemberOfClass:[PRODisplayItem class]] && [self.helper isValidIndexPath:self.currentItem.indexPath]) {
        PCOItem *planItem = [self.helper itemForIndexPath:self.currentItem.indexPath];
        self.infoView.loopingIcon.hidden = ![planItem.looping boolValue];
    }
    
//    self.screenView.logoIsCurrent = [currentItem isKindOfClass:[PROLogoDisplayItem class]];
//    self.screenView.blackIsCurrent = [currentItem isKindOfClass:[PROBlackItem class]];
}

- (void)upNextItemDidChange:(PRODisplayItem *)nextItem {
    self.nextItem = nextItem;
    
//    self.screenView.logoIsNext = [nextItem isKindOfClass:[PROLogoDisplayItem class]];
//    self.screenView.blackIsNext = [nextItem isKindOfClass:[PROBlackItem class]];
}

- (void)setCurrentItem:(PRODisplayItem *)currentItem {
    _currentItem = currentItem;
    
    if ([currentItem isKindOfClass:[PROLogoDisplayItem class]]) {
        [PCOEventLogger logEvent:@"Playing Logo"];
    } else if ([currentItem isKindOfClass:[PROBlackItem class]]) {
        [PCOEventLogger logEvent:@"Playing Black Screen"];
    } else {
        [PCOEventLogger logEvent:@"Playing Slide"];
    }
    
    [[PRODisplayController sharedController] displayCurrentItem:currentItem];
    [self.outputView bringSubviewToFront:self.nowPlayingInterfaceController.nowPlayingControlView];
    
    [[LoopingPlaylistManager sharedPlaylistManager] setCurrentlyPlayingItem:nil];
    
    [self.mobileGridController.helper controlLoopingForCurrentItem:currentItem];
    
    [self.nowPlayingInterfaceController configureNowPlayingDisplay];
}

- (void)setNextItem:(PRODisplayItem *)nextItem {
    _nextItem = nextItem;
    [[PRODisplayController sharedController] displayUpNextItem:nextItem];
}

// MARK: - View Lifecycle
- (void)loadView {
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aspectRatioDidChange:) name:kProjectorDefaultAspectRatioSetting object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInterfaceWillRefresh) name:PRODisplayControllerDidSetAlertNotification object:nil];
    
    [self aspectRatioDidChange:nil];
    [self prepareSubControllers];
    
    [self addEventListener:self];
    [self hideOptionsViewAnimated:NO];
    [self.optionsButton addTarget:self action:@selector(optionsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nowPlayingInterfaceController configureNowPlayingInterface];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    _fullScreenController = nil;

}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (NSArray *)newRightNavigationButtons {
    if ([[PRORecordingController sharedController] isRecording] || [[PRORecordingController sharedController] readyToRecord]) {
        UIBarButtonItem * recordButtonItem = [[PRORecordingController sharedController] recordBarButtonItem];
        [(UIButton *)[recordButtonItem customView] addTarget:self action:@selector(recordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return @[recordButtonItem];
    }
    return nil;
}

- (void)updateNavButtons {
    self.navigationItem.rightBarButtonItems = [self newRightNavigationButtons];
}

- (void)recordButtonAction:(id)sender {
    NSLog(@"Record Button Touched");
    if ([[PRORecordingController sharedController] isRecording]) {
        self.outputView.layer.borderColor = nil;
        self.outputView.layer.borderWidth = 0.0;
        [[PRORecordingController sharedController] stopRecording];
        [self updateNavButtons];
        self.outputView.cameraButton.hidden = YES;
        self.outputView.recLabel.hidden = YES;
        [self.outputView.recLabel.layer removeAllAnimations];
    }
    else if ([[PRORecordingController sharedController] readyToRecord]){
        self.outputView.layer.borderColor = [[UIColor redColor] CGColor];
        self.outputView.layer.borderWidth = 3.0;
        [[PRORecordingController sharedController] startRecording];
        [self updateNavButtons];
        self.outputView.cameraButton.hidden = YES;
        self.outputView.recLabel.hidden = NO;
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.outputView.recLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.outputView.recLabel.alpha = 1.0;
        }];
    }
    else {
        [self.helper setCurrentToBlack];
        PRORecordingsListViewController *recordingList = [[PRORecordingsListViewController alloc] initWithNibName:nil bundle:nil];
        recordingList.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:recordingList animated:YES completion:nil];
    }
}

// MARK: - Notification Handlers

- (void)deviceDidChangeOrientation:(NSNotification *)notif {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [self performSelector:@selector(presentCurrentDisplayViewInFullScreen) withObject:nil afterDelay:0.01];
    }
}

- (void)returnFromBackground {
    [self.nowPlayingInterfaceController configureNowPlayingInterface];
}

- (void)aspectRatioDidChange:(NSNotification *)notif {
    if (self.outputViewHeight) {
        [self.view removeConstraint:self.outputViewHeight];
    }
    if (self.outputViewWidth) {
        [self.view removeConstraint:self.outputViewWidth];
    }
    
    NSLayoutConstraint *height = ProjectorCreateAspectConstraint([[ProjectorSettings userSettings] aspectRatio], self.outputView);
    _outputViewHeight = height;
    
    CGFloat sizeMulti = 1.0;
    if (CGRectGetHeight([[UIScreen mainScreen] bounds]) < 500) {
        if ([[ProjectorSettings userSettings] aspectRatio] == ProjectorAspectRatio_4_3) {
            sizeMulti = 0.7;
        }
    }
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.outputView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:sizeMulti constant:0.0];
    _outputViewWidth = width;
    
    [self.view addConstraints:@[width, height]];
    
    [self.view setNeedsLayout];
}

// MARK: - Helper
- (PlanGridHelper *)helper {
    return self.mobileGridController.helper;
}

// MARK: - Button helpers
- (void)optionsButtonAction:(id)sender {
    if ([self.optionsButton isSelected]) {
        [self hideOptionsViewAnimated:YES];
    } else {
        [self showOptionsViewAnimated:YES];
    }
}
- (void)showOptionsViewAnimated:(BOOL)flag {
    [self teardownOptionsView];
    
    PlanViewMobileGridOptionsTableViewController *controller = [[PlanViewMobileGridOptionsTableViewController alloc] initWithNibName:nil bundle:nil];
    
    [self addChildViewController:controller];
    
    _optionsController = controller;
    controller.delegate = self;
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat height = controller.preferredContentSize.height - PROPlanContainerMobileButtonOffset;
    
    PCOView *containerView = [PCOView newAutoLayoutView];
    containerView.backgroundColor = [UIColor clearColor];
    
    [containerView addSubview:controller.view];
    
    _optionsContainerView = containerView;
    [self.view insertSubview:containerView belowSubview:self.optionsButton];
    
    [containerView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:controller.view offset:0.0 edges:UIRectEdgeAll]];
    
    [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:containerView offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    heightConstraint.priority = UILayoutPriorityRequired;
    [self.view addConstraint:heightConstraint];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    bottom.priority = UILayoutPriorityDefaultHigh;
    [self.view addConstraint:bottom];
    
    CGFloat startOffset = PROPlanContainerMobileButtonOffset + PCOKitRectGetHalfHeight(self.optionsButton.bounds);
    
    NSLayoutConstraint *buttonOffset = [NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.optionsButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:startOffset];
    _optionsViewButtonOffsetConstraint = buttonOffset;
    [self.view addConstraint:buttonOffset];
    
    [UIView performWithoutAnimation:^{
        [self.view layoutIfNeeded];
        [controller prepareToAnimateIn];
    }];
    
    [controller didMoveToParentViewController:self];
    
    if (flag) {
        [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:0 animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.6 animations:^{
                self.optionsButton.selected = YES;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.9 animations:^{
                self.optionsButtonBottomOffset.constant = (-height) - 8.0;
                buttonOffset.constant = -12.0;
                [self.view layoutIfNeeded];
            }];
            [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
                self.optionsButtonBottomOffset.constant = -height;
                buttonOffset.constant = -2.0;
                [self.view layoutIfNeeded];
            }];
            [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.7 animations:^{
                [controller animateIn];
            }];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView performWithoutAnimation:^{
            self.optionsButton.selected = YES;
            [controller animateIn];
            [self.view layoutIfNeeded];
        }];
    }
}
- (void)hideOptionsViewAnimated:(BOOL)flag {
    self.optionsButtonBottomOffset.constant = -PROPlanContainerMobileButtonOffset;
    self.optionsViewButtonOffsetConstraint.constant = PROPlanContainerMobileButtonOffset + PCOKitRectGetHalfHeight(self.optionsButton.bounds);
    
    if (flag) {
        [UIView animateKeyframesWithDuration:0.2 delay:0.0 options:0 animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.6 animations:^{
                self.optionsButton.selected = NO;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
                [self.optionsController animateOut];
                [self.view layoutIfNeeded];
            }];
        } completion:^(BOOL finished) {
            [self teardownOptionsView];
        }];
    } else {
        [UIView performWithoutAnimation:^{
            [self.optionsController animateOut];
            self.optionsButton.selected = NO;
            [self.view layoutIfNeeded];
        }];
        [self teardownOptionsView];
    }
}

- (void)teardownOptionsView {
    if (_optionsController) {
        [_optionsController willMoveToParentViewController:nil];
        
        [_optionsController removeFromParentViewController];
        
        [_optionsController.view removeFromSuperview];
        
        [_optionsController didMoveToParentViewController:nil];
        
        _optionsController = nil;
    }
    if (_optionsContainerView) {
        [_optionsContainerView removeFromSuperview];
        _optionsContainerView = nil;
    }
}

// MARK: - Lazy Loaders
- (PRODisplayView *)outputView {
    if (!_outputView) {
        PRODisplayView *view = [PRODisplayView newAutoLayoutView];
        view.priority = PRODisplayViewPriorityLiveScreen;
        view.backgroundColor = [UIColor blackColor];
        view.showActionButtons = YES;
        
        [[PRODisplayController sharedController] registerView:view];
        
        [[view actionAlertButton] addTarget:self action:@selector(presentAlertEntryView:) forControlEvents:UIControlEventTouchUpInside];
        [[view actionBlackButton] addTarget:self action:@selector(blackScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [[view actionLogoButton] addTarget:self action:@selector(showLogoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [[view recLabel] setHidden:YES];
        [[view cameraButton] addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _outputView = view;
        [self.view addSubview:view];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint centerViewHorizontalyInSuperview:view]];
    }
    return _outputView;
}
- (PlanViewMobileInfoView *)infoView {
    if (!_infoView) {
        PlanViewMobileInfoView *view = [PlanViewMobileInfoView newAutoLayoutView];
        view.backgroundColor = [UIColor mobilePlanViewBlackColor];
        
        [view.leftButton addTarget:self action:@selector(playPreviousSlide) forControlEvents:UIControlEventTouchUpInside];
        [view.rightButton addTarget:self action:@selector(playNextSlide) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:view];
        _infoView = view;
        
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
        [self.view addConstraint:[NSLayoutConstraint height:44.0 forView:view]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.outputView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
    return _infoView;
}
- (PROOptionsButton *)optionsButton {
    if (!_optionsButton) {
        PROOptionsButton *button = [PROOptionsButton newAutoLayoutView];
        
        _optionsButton = button;
        [self.view addSubview:button];
        
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:button offset:PROPlanContainerMobileButtonOffset edges:UIRectEdgeRight]];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-PROPlanContainerMobileButtonOffset];
        self.optionsButtonBottomOffset = constraint;
        [self.view addConstraint:constraint];
    }
    return _optionsButton;
}

- (NowPlayingInterfaceController *)nowPlayingInterfaceController {
    if (!_nowPlayingInterfaceController) {
        NowPlayingInterfaceController *controller = [[NowPlayingInterfaceController alloc] init];
        controller.delegate = self;
        [controller configureNowPlayingInterface];
        _nowPlayingInterfaceController = controller;
    }
    return _nowPlayingInterfaceController;
}

// MARK: - Prepare Sub
- (void)prepareSubControllers {
    PlanViewMobileGridTableViewController *controller = [[PlanViewMobileGridTableViewController alloc] initWithNibName:nil bundle:nil];
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    controller.view.backgroundColor = [UIColor projectorBlackColor];
    
    [self addChildViewController:controller];
    
    [self.view addSubview:controller.view];
    [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:controller.view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.infoView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    [controller pro_setContainer:self];
    
    _mobileGridController = controller;
    
    [controller didMoveToParentViewController:self];
    
    [self addEventListener:controller];
    
    [self.view setNeedsLayout];
}

- (void)updatePlanWithCompletion:(void (^)(void))completion {
    [[PROUIOptimization sharedOptimizer] planStartedUpdating];
    
    welf();
    [self.mobileGridController willBeginRefresh];
    [[[PCOCoreDataManager sharedManager] plansController] updatePlan:self.plan includeSlides:YES completion:^(BOOL success, PCOPlan *updatePlan) {
        [[PROUIOptimization sharedOptimizer] planFinishedUpdating];
        [welf setPlan:updatePlan skipUpdate:YES];
        [welf planUpdated];
        [welf.mobileGridController didEndRefresh];
        if (completion) {
            completion();
        }
    }];
}

// MARK: - Disable iPad things
- (void)setupInterface {
    // This can't call to super because it will setup the iPad UI
}

// MARK: - Info Actions
- (void)blackScreenButtonAction:(id)sender {
    if ([self.helper isBackScreenIndexPath:self.helper.currentIndexPath]) {
        return;
    }
    if ([self.helper isBackScreenIndexPath:self.helper.nextIndexPath]) {
        [self.helper setCurrentToBlack];
    } else {
        [self.helper setNextToBlack];
    }
}

// MARK: - Interface
- (void)userInterfaceWillRefresh {
    if ([self.helper isBackScreenIndexPath:self.helper.currentIndexPath]) {
        [[self.outputView actionBlackButton] setActionState:PRODisplayViewActionButtonStateCurrent];
    } else if ([self.helper isBackScreenIndexPath:self.helper.nextIndexPath]) {
        [[self.outputView actionBlackButton] setActionState:PRODisplayViewActionButtonStateNext];
    } else {
        [[self.outputView actionBlackButton] setActionState:PRODisplayViewActionButtonStateOff];
    }

    if ([self.helper isLogoIndexPath:self.helper.currentIndexPath]) {
        [[self.outputView actionLogoButton] setActionState:PRODisplayViewActionButtonStateCurrent];
    } else if ([self.helper isLogoIndexPath:self.helper.nextIndexPath]) {
        [[self.outputView actionLogoButton] setActionState:PRODisplayViewActionButtonStateNext];
    } else {
        [[self.outputView actionLogoButton] setActionState:PRODisplayViewActionButtonStateOff];
    }
    
    if ([[PRODisplayController sharedController] isAnAlertActive]) {
        [[self.outputView actionAlertButton] setActionState:PRODisplayViewActionButtonStateCurrent];
    } else {
        [[self.outputView actionAlertButton] setActionState:PRODisplayViewActionButtonStateOff];
    }
}

// MARK: - Options Delegate
- (void)showLogoButtonAction:(id)sender {
    if (!self.currentLogo) {
        [self presentLogoPicker:sender];
    }
    if ([self.helper isLogoIndexPath:self.helper.currentIndexPath]) {
        return;
    }
    if ([self.helper isLogoIndexPath:self.helper.nextIndexPath]) {
        [self.helper setCurrentToLogo:self.currentLogo];
        [self hideOptionsViewAnimated:YES];
    } else {
        [self.helper setNextToLogo:self.currentLogo];
    }
}
- (void)presentLogoPicker:(id)sender {
    PROLogoPickerViewController *controller = [[PROLogoPickerViewController alloc] initWithStyle:UITableViewStylePlain];
    controller.plan = self.helper.plan;
    controller.delegate = self;
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:controller];
    
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(logoPickerDoneButtonAction:)];
    
    [self presentViewController:navigation animated:YES completion:nil];
}
- (PlanGridHelper *)gridHelperForController:(PlanViewMobileGridOptionsTableViewController *)controller {
    return self.helper;
}

- (void)optionsControllerRecordingsAction:(PlanViewMobileGridOptionsTableViewController *)controller {
    if ([[PRORecordingController sharedController] isRecording]) {
        [self recordButtonAction:nil];
        [self recordButtonAction:nil];
    }
    else if ( [[PRORecordingController sharedController] readyToRecord]) {
        [[PRORecordingController sharedController] cancelPendingRecording];
        [self recordButtonAction:nil];
    }
    else {
        [self recordButtonAction:nil];
    }
}

- (void)optionsControllerChangeLogoAction:(PlanViewMobileGridOptionsTableViewController *)sender {
    [self presentLogoPicker:sender];
}
- (void)optionsControllerOrderOfServiceAction:(PlanViewMobileGridOptionsTableViewController *)controller {
    [self editButtonAction:nil];
}
- (void)optionsControllerLayoutsAction:(PlanViewMobileGridOptionsTableViewController *)controller {
    [self layoutButtonAction:nil];
}

// MARK: - Logo
- (PROLogo *)currentLogo {
    if (!_currentLogo) {
        _currentLogo = [PROLogo logoForUUID:[[PROStateSaver sharedState] currentLogoUUID]];
    }
    return _currentLogo;
}

- (void)logoPicker:(PROLogoPickerViewController *)picker didSelectLogo:(PROLogo *)logo {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.currentLogo = logo;
    
    if ([self.helper isLogoIndexPath:self.helper.currentIndexPath]) {
        [self.helper setCurrentToLogo:logo];
    }
    if ([self.helper isLogoIndexPath:self.helper.nextIndexPath]) {
        [self.helper setNextToLogo:logo];
    }
}

- (void)logoPickerDoneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Title
- (NSString *)planTitle {
    return [self.helper.plan dates];
}

#pragma mark -
#pragma mark - Show Full Screen

- (void)presentCurrentDisplayViewInFullScreen {
    if (!_fullScreenController) {
        self.fullScreenController = [[PROFullScreenCurrentViewController alloc] initWithNibName:nil bundle:nil];
        self.fullScreenController.plan = self.helper.plan;
        self.fullScreenController.delegate = self.nowPlayingInterfaceController;
        self.fullScreenController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:self.fullScreenController animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - NowPlayingInterfaceControllerDelegate Methods

- (void)playSlideAtIndex:(NSInteger)slideIndex withPlanItemIndex:(NSInteger)planItemIndex andScrubPosition:(float)scrubPosition shouldPause:(BOOL)shouldPause {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:slideIndex inSection:planItemIndex];
    if ([self.helper isSlideIndexPath:indexPath] && [self.helper isValidIndexPath:indexPath]) {
        if (self.helper.currentIndexPath == nil || self.helper.currentIndexPath.section != indexPath.section || self.helper.currentIndexPath.row != indexPath.row) {
            [self.helper updateNextIndexPathPath:indexPath];
            [self.helper updateSelectedIndexPathsForSelection:indexPath];
            [self.mobileGridController scrollToIndexPath:indexPath animated:YES];
        }
    }
}

- (UIView *)nowPlayingControlViewContainerView {
    return self.infoView;
}

- (PRODisplayView *)displayViewControlViewContainerView {
    return self.outputView;
}

- (UIView *)nextContainerView {
    return nil;
}

- (UIView *)mainView {
    return self.view;
}

- (PRODisplayView *)fullScreenCurrentDisplayView {
    return nil;
}

- (void)playPreviousSlide {
    [self.helper playPreviousSlide];
}

- (void)playNextSlide {
    [self.helper playNextSlide];
}

- (void)playBlackScreen {
    [self.helper setCurrentToBlack];
}

- (void)playLogo {
    [self.helper setCurrentToLogo:[self.helper.delegate currentLogo]];
}

- (void)showFullScreen {
    [self presentCurrentDisplayViewInFullScreen];
}

- (NSString *)currentItemTitleText {
    return self.currentItem.titleString;
}

- (NSString *)previousItemTitleText {
    NSIndexPath *indexPath = [self.helper previousValidIndexPathBeforeIndexPath:self.helper.currentIndexPath];
    if (indexPath) {
        PROSlide *slide = [[PROSlideManager sharedManager] slideForIndexPath:indexPath];
        return slide.label;
    }
    return @"";
}

- (NSString *)nextItemTitleText {
    return self.nextItem.titleString;
}

- (NSIndexPath *)currentIndexPath {
    return self.helper.currentIndexPath;
}

- (BOOL)shouldPresentLogoPicker {
    if (!self.currentLogo) {
        return YES;
    }
    if ([self.helper isLogoIndexPath:self.helper.currentIndexPath]) {
        return NO;
    }
    if ([self.helper isLogoIndexPath:self.helper.nextIndexPath]) {
        [self.helper setCurrentToLogo:self.currentLogo];
        [self hideOptionsViewAnimated:YES];
    } else {
        [self.helper setNextToLogo:self.currentLogo];
    }
    return NO;
}

@end
