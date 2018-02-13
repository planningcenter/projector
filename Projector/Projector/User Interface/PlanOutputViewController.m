/*!
 * PlanOutputViewController.m
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#import "PlanOutputViewController.h"
#import "PlanShowOnScreenView.h"
#import "PROPlanContainerViewController.h"
#import "PlanViewGridViewController.h"
#import "PlanOutputCurrentBottomBar.h"
#import "PROLogoPickerViewController.h"

#import "PRONavigationController.h"
#import "LayoutPickerTableViewController.h"

#import "PROLogoPickerView.h"
#import "PROLogoPickerViewController.h"

#import "PRODisplayController.h"

#import "PROLogo.h"
#import "PROLogoDisplayItem.h"
#import "PROBlackItem.h"
#import "BlackScreenButton.h"

#import "PCOStrokeView.h"

#import "PROAlertView.h"

#import "PROSlideManager.h"

#import "LoopingPlaylistManager.h"
#import "P2P_SessionManager.h"
#import "NSString+FileTypeAdditions.h"


#define BORDER_WIDTH 2.0

@interface PlanOutputViewController () <PROLogoPickerViewControllerDelegate>

@property (nonatomic, strong) PRODisplayItem *currentItem;
@property (nonatomic, strong) PRODisplayItem *nextItem;

@property (nonatomic, weak) PRODisplayView *currentDisplayView;
@property (nonatomic, weak) PRODisplayView *nextDisplayView;

@property (nonatomic, strong) NowPlayingInterfaceController *nowPlayingInterfaceController;

@property (nonatomic) CGFloat aspect;

@property (nonatomic, weak) PlanShowOnScreenView *screenView;

@property (nonatomic, weak) PlanOutputCurrentBottomBar *bottomBar;
@property (nonatomic, weak) PCOLabel *nextUpLabel;
@property (nonatomic, weak) PCOLabel *showOnScreenLabel;

@property (nonatomic, strong) PROLogo *logo;

@property (nonatomic, strong) PROFullScreenCurrentViewController *fullScreenController;
@end

@implementation PlanOutputViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor planOutputBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aspectRatioDidChange:) name:kProjectorDefaultAspectRatioSetting object:nil];
    self.aspect = ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]);

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showCurrentLogoInButton];
    [self.nowPlayingInterfaceController configureNowPlayingInterface];
    _fullScreenController = nil;
}

- (PROLogo *)currentLogo {
    return self.logo;
}

#pragma mark - Layout
#pragma mark -

- (void)updateLandscapeConstraints {
    [self updateCurrentDisplayViewConstraints];
    [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.bottomBar offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
    [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.nextUpLabel offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextUpLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.bottomBar attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint height:40.0 forView:self.nextUpLabel]];
    [self.view addConstraint:[NSLayoutConstraint centerHorizontal:self.nextDisplayView inView:self.view]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextDisplayView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nextUpLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PlanOutputViewControllerPadding * 2.0]];
    [self.view addConstraint:[NSLayoutConstraint height:140.0 forView:self.nextDisplayView]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nextDisplayView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.nextDisplayView attribute:NSLayoutAttributeHeight multiplier:self.aspect constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.showOnScreenLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nextDisplayView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PlanOutputViewControllerPadding * 2.0]];
    [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.showOnScreenLabel offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
    [self.view addConstraint:[NSLayoutConstraint height:40.0 forView:self.showOnScreenLabel]];
    [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.screenView offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.screenView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.showOnScreenLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:PlanOutputViewControllerPadding]];
}

- (void)updateCurrentDisplayViewConstraints {
    [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:self.currentDisplayView offset:PlanOutputViewControllerPadding edges:UIRectEdgeLeft | UIRectEdgeTop | UIRectEdgeRight]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.currentDisplayView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.currentDisplayView attribute:NSLayoutAttributeHeight multiplier:self.aspect constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.currentDisplayView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}

- (void)updateViewConstraints {
    [self.view removeAllConstraints];
    [super updateViewConstraints];
    
    [self updateLandscapeConstraints];
}

#pragma mark -
#pragma mark - Notifications

- (void)aspectRatioDidChange:(NSNotification *)notif {
    PCOKitOnMainThread(^{
        self.aspect = ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]);
        [self.view setNeedsUpdateConstraints];
    });
}

- (void)returnFromBackground {
    [self.nowPlayingInterfaceController configureNowPlayingInterface];
}

#pragma mark -
#pragma mark - Events
- (void)registerForController:(PROPlanContainerViewController *)controller {
    if (_container) {
        [self.screenView.alertButton removeTarget:_container action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    _container = controller;
    [self.screenView.alertButton addTarget:_container action:@selector(presentAlertEntryView:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark - Display Item Change

- (void)currentItemDidChange:(PRODisplayItem *)currentItem {
    self.currentItem = currentItem;
    self.bottomBar.nameLabel.text = currentItem.titleString;
    self.bottomBar.loopingIcon.hidden = YES;
    if (currentItem.indexPath.section < (NSInteger)[[self.container.plan orderedItems] count]) {
        PCOItem *planItem = [[self.container.plan orderedItems] objectAtIndex:currentItem.indexPath.section];
        self.bottomBar.loopingIcon.hidden = ![planItem.looping boolValue];
    }
    
    self.screenView.logoIsCurrent = [currentItem isKindOfClass:[PROLogoDisplayItem class]];
    self.screenView.blackIsCurrent = [currentItem isKindOfClass:[PROBlackItem class]];
}

- (void)upNextItemDidChange:(PRODisplayItem *)nextItem {
    self.nextItem = nextItem;
    
    self.screenView.logoIsNext = [nextItem isKindOfClass:[PROLogoDisplayItem class]];
    self.screenView.blackIsNext = [nextItem isKindOfClass:[PROBlackItem class]];
}

- (void)setCurrentItem:(PRODisplayItem *)currentItem {
    _currentItem = currentItem;
    
    if ([currentItem isKindOfClass:[PROLogoDisplayItem class]]) {
        [PCOEventLogger logEvent:@"Playing Logo"];
    } else if ([currentItem isKindOfClass:[PROBlackItem class]]) {
        [PCOEventLogger logEvent:@"Playing Black Screen"];
    }
    else {
        [PCOEventLogger logEvent:@"Playing Slide"];
    }
    
    [[PRODisplayController sharedController] displayCurrentItem:currentItem];
    [self.currentDisplayView bringSubviewToFront:self.nowPlayingInterfaceController.nowPlayingControlView];

    [[LoopingPlaylistManager sharedPlaylistManager] setCurrentlyPlayingItem:nil];

    [self.container.gridController.helper controlLoopingForCurrentItem:currentItem];
    
    [self.nowPlayingInterfaceController configureNowPlayingDisplay];
}

- (void)setNextItem:(PRODisplayItem *)nextItem {
    _nextItem = nextItem;
    [[PRODisplayController sharedController] displayUpNextItem:nextItem];
}

- (void)setCurrentToBlack:(UIButton *)sender {
    if (self.screenView.blackIsNext) {
        [self.container.helper setCurrentToBlack];
    } else if (!self.screenView.blackIsCurrent) {
        [self.container.helper setNextToBlack];
    }
}
- (void)setCurrentToLogo:(UIButton *)sender {
    if (self.screenView.logoIsCurrent) {
        _logo = nil;
        [self.container replaceLogoAsCurrent:self.logo];
    }
    else if (self.screenView.logoIsNext) {
        [self.container showLogoAsCurrent:self.logo];
    } else if (!self.screenView.logoIsCurrent) {
        [self.container showLogoAsNext:self.logo];
    }
}

#pragma mark -
#pragma mark - Lazy Loaders

- (PRODisplayView *)currentDisplayView {
    if (!_currentDisplayView) {
        PRODisplayView *view = [PRODisplayView newAutoLayoutView];
        view.layer.borderColor = [[UIColor currentItemGreenColor] CGColor];
        view.layer.borderWidth = BORDER_WIDTH;
        view.priority = PRODisplayViewPriorityLiveScreen;
        
        [[PRODisplayController sharedController] registerView:view];
        
        _currentDisplayView = view;
        [self.view addSubview:view];
    }
    return _currentDisplayView;
}
- (PRODisplayView *)nextDisplayView {
    if (!_nextDisplayView) {
        PRODisplayView *view = [PRODisplayView newAutoLayoutView];
        view.layer.borderColor = [[UIColor nextUpItemBlueColor] CGColor];
        view.layer.borderWidth = BORDER_WIDTH;
        view.priority = PRODisplayViewPriorityUpNext;
        
        [[PRODisplayController sharedController] registerView:view];
        
        _nextDisplayView = view;
        [self.view addSubview:view];
    }
    return _nextDisplayView;
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

- (PlanShowOnScreenView *)screenView {
    if (!_screenView) {
        PlanShowOnScreenView *view = [PlanShowOnScreenView newAutoLayoutView];
        [view.blackScreenButton addTarget:self action:@selector(setCurrentToBlack:) forControlEvents:UIControlEventTouchUpInside];
        view.backgroundColor = [UIColor planOutputBackgroundColor];
        
        [view.logoView addTarget:self action:@selector(setCurrentToLogo:) forControlEvents:UIControlEventTouchUpInside];
        
        [view.logoView.innerButton addTarget:self action:@selector(presentLogoPickerFromSender:) forControlEvents:UIControlEventTouchUpInside];
        
        _screenView = view;
        [self.view addSubview:view];
    }
    return _screenView;
}
- (PlanOutputCurrentBottomBar *)bottomBar {
    if (!_bottomBar) {
        PlanOutputCurrentBottomBar *bar = [PlanOutputCurrentBottomBar newAutoLayoutView];
        bar.backgroundColor = self.view.backgroundColor;
        _bottomBar = bar;
        [self.view addSubview:bar];
    }
    return _bottomBar;
}
- (PCOLabel *)nextUpLabel {
    if (!_nextUpLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = [UIColor projectorBlackColor];
        label.textColor = [UIColor planOutputSlateColor];
        label.font = [UIFont defaultFontOfSize_16];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"Next Up", nil);
        
        [label pco_addStrokeView:[PCOStrokeView newStrokeWithWidth:0.5 color:[UIColor planOutputSlateColor] edge:PCOViewEdgeBottom]];
        
        _nextUpLabel = label;
        [self.view addSubview:label];
    }
    return _nextUpLabel;
}
- (PCOLabel *)showOnScreenLabel {
    if (!_showOnScreenLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = [UIColor projectorBlackColor];
        label.textColor = [UIColor planOutputSlateColor];
        label.font = [UIFont defaultFontOfSize_12];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"Show on Screen", nil);
        
        [label pco_addStrokeView:[PCOStrokeView newStrokeWithWidth:0.5 color:[UIColor planOutputSlateColor] edge:PCOViewEdgeBottom]];
        [label pco_addStrokeView:[PCOStrokeView newStrokeWithWidth:0.5 color:[UIColor planOutputSlateColor] edge:PCOViewEdgeTop]];
        
        _showOnScreenLabel = label;
        [self.view addSubview:label];
    }
    return _showOnScreenLabel;
}

- (PROLogo *)logo {
    if (!_logo) {
        _logo = [PROLogo logoForUUID:[[PROStateSaver sharedState] currentLogoUUID]];
    }
    return _logo;
}

#pragma mark -
#pragma mark - Logo Picker
- (void)presentLogoPickerFromSender:(PCOButton *)button {
    PROLogoPickerViewController *controller = [[PROLogoPickerViewController alloc] initWithStyle:UITableViewStylePlain];
    controller.plan = self.container.plan;
    controller.delegate = self;
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:controller];
    navigation.modalPresentationStyle = UIModalPresentationPopover;
    navigation.popoverPresentationController.sourceView = button;
    navigation.popoverPresentationController.sourceRect = CGRectMake(PCOKitRectGetHalfWidth(button.bounds), -2.0, 0.0, 0.0);
    
    [self presentViewController:navigation animated:YES completion:nil];
}
- (void)logoPicker:(PROLogoPickerViewController *)picker didSelectLogo:(PROLogo *)logo {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.logo = logo;
    [self showCurrentLogoInButton];
    
    if ([self.container.helper isLogoIndexPath:self.container.helper.currentIndexPath]) {
        [self.container.helper setCurrentToLogo:logo];
    }
    if ([self.container.helper isLogoIndexPath:self.container.helper.nextIndexPath]) {
        [self.container.helper setNextToLogo:logo];
    }
}


#pragma mark -
#pragma mark - Action Methods

#pragma mark -
#pragma mark - Show Full Screen
- (void)presentCurrentDisplayViewInFullScreen {
    if (!_fullScreenController) {
        self.fullScreenController = [[PROFullScreenCurrentViewController alloc] initWithNibName:nil bundle:nil];
        self.fullScreenController.plan = self.container.plan;
        self.fullScreenController.delegate = self.nowPlayingInterfaceController;
        self.fullScreenController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:self.fullScreenController animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - Helper Methods

- (void)showCurrentLogoInButton {
    self.screenView.logoView.aspectImageView.image = nil;
    welf();
    [self.logo loadThumbnailWithCompletion:^(UIImage *image, NSError *error) {
        welf.screenView.logoView.aspectImageView.image = image;
    }];
}

- (void)sendControlButtonActionTo:(id)object nextButtonSelector:(SEL)nextSelector previousButtonSelector:(SEL)previousSelector {
    [self.bottomBar.leftArrowButton addTarget:object action:previousSelector forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.rightArrowButton addTarget:object action:nextSelector forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark - NowPlayingInterfaceControllerDelegate Methods

- (void)playSlideAtIndex:(NSInteger)slideIndex withPlanItemIndex:(NSInteger)planItemIndex andScrubPosition:(float)scrubPosition shouldPause:(BOOL)shouldPause {
    [self.container.gridController playSlideAtIndex:slideIndex withPlanItemIndex:planItemIndex andScrubPosition:scrubPosition shouldPause:shouldPause];
}

- (UIView *)nowPlayingControlViewContainerView {
    return [self bottomBar];
}

- (PRODisplayView *)displayViewControlViewContainerView {
    return self.currentDisplayView;
}

- (UIView *)nextContainerView {
    return self.nextDisplayView;
}

- (UIView *)mainView {
    return self.view;
}

- (PRODisplayView *)fullScreenCurrentDisplayView {
    return self.currentDisplayView;
}

- (void)restoreDisplayView {
    [self.view addSubview:self.currentDisplayView];
    self.currentDisplayView.controlsView.hidden = NO;
    self.currentDisplayView.layer.borderWidth = BORDER_WIDTH;
    [self updateCurrentDisplayViewConstraints];
}

- (void)playPreviousSlide {
    [self.container.helper playPreviousSlide];
}

- (void)playNextSlide {
    [self.container.helper playNextSlide];
}

- (void)playBlackScreen {
    [self.container.helper setCurrentToBlack];
}

- (void)playLogo {
    [self.container.helper setCurrentToLogo:self.logo];
}

- (void)showFullScreen {
    [self presentCurrentDisplayViewInFullScreen];
}

- (NSString *)currentItemTitleText {
    return self.currentItem.titleString;
}

- (NSString *)previousItemTitleText {
    NSIndexPath *indexPath = [self.container.helper previousValidIndexPathBeforeIndexPath:self.container.helper.currentIndexPath];
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
    return self.container.gridController.helper.currentIndexPath;
}

- (BOOL)shouldPresentLogoPicker {
    if (!self.currentLogo) {
        return YES;
    }
    if ([self.container.helper isLogoIndexPath:self.container.helper.currentIndexPath]) {
        return NO;
    }
    if ([self.container.helper isLogoIndexPath:self.container.helper.nextIndexPath]) {
        [self.container.helper setCurrentToLogo:self.currentLogo];
    } else {
        [self.container.helper setNextToLogo:self.currentLogo];
    }
    return NO;
}

@end

CGFloat const PlanOutputViewControllerPadding = 8.0;
