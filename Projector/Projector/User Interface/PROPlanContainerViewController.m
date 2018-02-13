/*!
 * PROPlanContainerViewController.m
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#import <MCTFileDownloader/MCTFileDownloader.h>

// View Controllers
#import "PROPlanContainerViewController.h"
#import "PlanViewGridViewController.h"
#import "PlanOutputViewController.h"
#import "PROPlanNavigationController.h"
#import "MCTAlertView.h"

#import "PROModalViewController.h"
#import "PRODisplayController.h"
#import "ProjectorP2P_SessionManager.h"

#import "PROSlideManager.h"
#import "PCOLiveController.h"
#import "ProjectorP2P_SessionManager.h"

#import "LayoutPickerTableViewController.h"

#import "ProjectorAlertViewController.h"

#import "PlanEditorItemReorderViewController.h"
#import "PlanGridHelper.h"

#import "PROUIOptimization.h"

#import "PRORecordingController.h"
#import <MCTFileDownloader/MCTFileDownloader.h>

@interface PROPlanContainerViewController () <MCTFDDownloaderObserver>

@property (nonatomic, weak) PCOView *planGridContainerView;
@property (nonatomic, strong) NSArray *planGridContainerConstraints;

@property (nonatomic, weak) PCOView *planDetailsContainerView;
@property (nonatomic, strong) NSArray *planDetailsContainerConstraints;

@property (nonatomic, strong) NSHashTable *eventListenersHashTable;

@end

@interface PlanViewGridViewController ()

- (void)pro_setContainer:(PROPlanContainerViewController *)container;

@end

@implementation PROPlanContainerViewController

- (void)loadView {
    [super loadView];
    
    
    [self addEventListener:[ProjectorP2P_SessionManager sharedManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PCOLiveStateChanged:) name:PCOLiveStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionStateChangedNotification:) name:P2PSessionStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionStateChangedNotification:) name:P2PServerCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionStateChangedNotification:) name:P2PClientCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionStateChangedNotification:) name:P2PSessionConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionStateChangedNotification:) name:P2PSessionDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionStateChangedNotification:) name:PCOLiveStateChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:LayoutPickerDidPickNewLayoutNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadIndicator) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (NSArray *)newRightNavigationButtons {
    UIBarButtonItem * recordButtonItem = [[PRORecordingController sharedController] recordBarButtonItem];
    [(UIButton *)[recordButtonItem customView] addTarget:self action:@selector(recordButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    NSMutableArray *buttonsArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    [buttonsArray addObjectsFromArray:@[
                                        [[UIBarButtonItem alloc] initWithImage:[UIImage templateImageNamed:@"layouts_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(layoutButtonAction:)],
                                        [[UIBarButtonItem alloc] initWithImage:[UIImage templateImageNamed:@"dash_edit"] style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction:)],
                                        ]];
    
    [buttonsArray addObject:recordButtonItem];

    return buttonsArray;
}

- (UIBarButtonItem *)newHamburgerButton {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage templateImageNamed:@"dash_plan_list_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenuSidebarAction:)];
}
- (UIBarButtonItem *)newDownloadButtonWithCount:(NSUInteger)count {
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectZero];
    [view addTarget:self action:@selector(presentFilesListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"download_icon"]];
    image.tag = 301;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = [NSString stringWithFormat:@"%tu",count];
    label.font = [UIFont defaultFontOfSize:9];
    label.textColor = [UIColor projectorBlackColor];
    label.backgroundColor = [UIColor projectorOrangeColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.clipsToBounds = YES;
    label.tag = 299;
    
    [view addSubview:label];
    [view addSubview:image];
    
    view.frame = (CGRect)({
        CGRect frame = CGRectZero;
        
        frame.size.height = CGRectGetHeight(image.bounds) + 6.0;
        frame.size.width = CGRectGetWidth(image.bounds) + 10.0;
        
        CGRectIntegral(frame);
    });
    
    label.frame = (CGRect)({
        CGRect frame = CGRectZero;
        
        CGFloat width = 12.0;
        
        frame.origin.x = CGRectGetWidth(view.bounds) - width;
        frame.size.height = width;
        frame.size.width = width;
        
        CGRectIntegral(frame);
    });
    
    image.frame = CGRectMake(0.0, CGRectGetHeight(view.bounds) - CGRectGetHeight(image.bounds), CGRectGetWidth(image.bounds), CGRectGetHeight(image.bounds));
    
    label.layer.cornerRadius = CGRectGetHeight(label.bounds) / 2.0;
    
    [self _addAnimationForRotationToImageView:image];
    
    return [[UIBarButtonItem alloc] initWithCustomView:view];
}

- (void)_addAnimationForRotationToImageView:(UIImageView *)imageView {
    CABasicAnimation *fullRotationAnimation;
    fullRotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotationAnimation.fromValue = @0.0;
    fullRotationAnimation.toValue = @(M_PI * 2.0);
    fullRotationAnimation.duration = 4.0;
    fullRotationAnimation.repeatCount = 50000;
    [imageView.layer addAnimation:fullRotationAnimation forKey:@"360"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[PRORecordingController sharedController] loadAllRecordings];
    
    self.navigationItem.leftBarButtonItem = [self newHamburgerButton];
    
    self.navigationItem.rightBarButtonItems = [self newRightNavigationButtons];

    if (self.showLayoutPickerOnPresent) {
        self.showLayoutPickerOnPresent = NO;
        [self presentLayoutPickerAnimated:YES];
    }
    
    [[PRODownloader sharedDownloader] addObserver:self];
    
    [self updateDownloadIndicator];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[PRODownloader sharedDownloader] removeObserver:self];
}

#pragma mark -
#pragma mark - Downloads
- (void)updateDownloadIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showDownloadIndicator:[[PRODownloader sharedDownloader] numberOfActiveDownloads]];
    });
}
- (void)downloader:(PRODownloader *)downloader beganDownload:(PRODownload *)download {
    [self updateDownloadIndicator];
}
- (void)downloader:(PRODownloader *)downloader finishedDownload:(PRODownload *)download {
    [self updateDownloadIndicator];
}
- (void)showDownloadIndicator:(NSUInteger)count {
    if (count == 0) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItem = [self newHamburgerButton];
    } else {
        [self _addDownloadProgressView:count];
    }
}
- (void)_addDownloadProgressView:(NSUInteger)count {
    if (self.navigationItem.leftBarButtonItems.count != 2) {
        self.navigationItem.leftBarButtonItems = @[
                                                   [self newHamburgerButton],
                                                   [self newDownloadButtonWithCount:count],
                                                   ];
    } else {
        UIBarButtonItem *item = [self.navigationItem.leftBarButtonItems lastObject];
        UILabel *label = (UILabel *)[item.customView viewWithTag:299];
        if ([label respondsToSelector:@selector(setText:)]) {
            [label setText:[NSString stringWithFormat:@"%tu",count]];
        }
        UIImageView *image = (UIImageView *)[item.customView viewWithTag:301];
        if (![image.layer animationForKey:@"360"]) {
            [self _addAnimationForRotationToImageView:image];
        }
    }
}

- (void)presentFilesListButtonAction:(id)sender {
    [[[PROAppDelegate delegate] rootViewController] showLeftMenuViewAnimated:YES completion:^{
        PCOSlidingSideViewController *controller = [[PROAppDelegate delegate] rootViewController];
        if ([controller.leftViewController isKindOfClass:[PROLeftSidebarTableViewController class]]) {
            PROLeftSidebarTableViewController *left = (PROLeftSidebarTableViewController *)controller.leftViewController;
            [left.tabController presentFilesViewAnimated:YES];
        }
    }];
}

#pragma mark -
#pragma mark - PRORecordingsListViewControllerDelegate

- (void)updateNavButtons {
    self.navigationItem.rightBarButtonItems = [self newRightNavigationButtons];
}

#pragma mark -
#pragma mark - Nav Buttons

- (void)recordButtonAction:(id)sender {
    if ([[PRORecordingController sharedController] isRecording]) {
        self.outputController.displayViewControlViewContainerView.layer.borderColor = [[UIColor currentItemGreenColor] CGColor];
        [[PRORecordingController sharedController] stopRecording];
        [self updateNavButtons];
        self.outputController.displayViewControlViewContainerView.cameraButton.hidden = YES;
        self.outputController.displayViewControlViewContainerView.recLabel.hidden = YES;
        [self.outputController.displayViewControlViewContainerView.recLabel.layer removeAllAnimations];
    }
    else if ([[PRORecordingController sharedController] readyToRecord]) {
        self.outputController.displayViewControlViewContainerView.layer.borderColor = [[UIColor redColor] CGColor];
        [[PRORecordingController sharedController] startRecording];
        self.outputController.displayViewControlViewContainerView.cameraButton.hidden = YES;
        self.outputController.displayViewControlViewContainerView.recLabel.hidden = NO;
        [self updateNavButtons];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.outputController.displayViewControlViewContainerView.recLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.outputController.displayViewControlViewContainerView.recLabel.alpha = 1.0;
        }];
    }
    else {
        [self.helper setCurrentToBlack];
        PRORecordingsListViewController *recordingList = [[PRORecordingsListViewController alloc] initWithNibName:nil bundle:nil];
        recordingList.delegate = self;
        recordingList.view.layer.borderWidth = 1;
        recordingList.view.layer.borderColor = [HEX(0x585863) CGColor];
        recordingList.view.layer.cornerRadius = 7;
        recordingList.modalPresentationStyle = UIModalPresentationFormSheet;
        recordingList.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:recordingList animated:YES completion:nil];
    }
}

- (void)cameraButtonAction:(id)sender {
    NSLog(@"Take a picture");
    [[PRORecordingController sharedController] startCameraControllerFromViewController:self];
}


- (void)editButtonAction:(id)sender {
    if (!self.plan) {
        [[[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"No Plan", nil) message:NSLocalizedString(@"You need to select a plan before you can edit it.", nil) cancelButtonTitle:NSLocalizedString(@"Ok", nil)] show];
        return;
    }
    PlanEditorItemReorderViewController *viewController = [[PlanEditorItemReorderViewController alloc] initWithNibName:nil bundle:nil];
    viewController.plan = self.plan;
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:viewController];
    if ([[UIDevice currentDevice] pco_isPad]) {
        navigation.view.layer.borderWidth = 1;
        navigation.view.layer.borderColor = [HEX(0x585863) CGColor];
        navigation.view.layer.cornerRadius = 7;
    }
    navigation.modalPresentationStyle = UIModalPresentationFormSheet;
    navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navigation animated:YES completion:nil];
}
- (void)layoutButtonAction:(id)sender {
    [self presentLayoutPickerAnimated:YES];
}
- (void)presentAlertEntryView:(id)sender {
    if ([[PRODisplayController sharedController] isAnAlertActive]) {
        [PCOEventLogger logEvent:@"Nursery Alert - Dismiss Alert"];
        [[PRODisplayController sharedController] displayAlert:nil];
    } else {
        ProjectorAlertViewController *controller = [[ProjectorAlertViewController alloc] initWithNibName:nil bundle:nil];
        
        PRONavigationController *nav = [[PRONavigationController alloc] initWithRootViewController:controller];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)presentLayoutPickerAnimated:(BOOL)flag {
    if (!self.plan) {
        [[[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"No Plan", nil) message:NSLocalizedString(@"You need to select a plan before you can edit it.", nil) cancelButtonTitle:NSLocalizedString(@"Ok", nil)] show];
        return;
    }
    [self.plan loadServiceTypeIfNeeded];
    
    LayoutPickerTableViewController *controller = [[LayoutPickerTableViewController alloc] initWithNibName:nil bundle:nil];
    controller.serviceType = self.plan.serviceType;
    PRONavigationController *nav = [[PRONavigationController alloc] initWithRootViewController:controller];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    nav.preferredContentSize = CGSizeMake(380.0, 480.0);
    
    [self presentViewController:nav animated:flag completion:nil];
}

#pragma mark -
#pragma mark - Edit Item
- (void)editPlanInServices {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"pcoservices://projector-edit-service-order"];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:4];
    [items addObject:[[NSURLQueryItem alloc] initWithName:@"userID" value:[[[PCOUserData current] remoteId] stringValue]]];
    [items addObject:[[NSURLQueryItem alloc] initWithName:@"organizationID" value:[[[PCOOrganization current] remoteId] stringValue]]];
    [items addObject:[[NSURLQueryItem alloc] initWithName:@"planID" value:[self.plan.remoteId stringValue]]];
    [items addObject:[[NSURLQueryItem alloc] initWithName:@"pco-callback-url" value:@"pcoprojector2://refresh/current-plan"]];
    
    components.queryItems = items;
    
    NSURL *URL = [components URL];
    
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://appstore.com/planningcenterservices"]];
    }
}

#pragma mark -
#pragma mark - Data Updated
- (void)planUpdatedNotification:(NSNotification *)notif {
    NSNumber *planID = notif.userInfo[PCOManagedObjectPrimaryIDKey];
    if ([self.plan.remoteId pco_isEqualToNumber:planID]) {
        [self.helper planUpdated];
    }
}

- (void)PCOLiveStateChanged:(NSNotification *)notif {
    self.title = [self planTitle];
}

- (void)P2PSessionStateChangedNotification:(NSNotification *)notif {
    PRONavigationController *proNav = (PRONavigationController *)[self navigationController];
    UIColor *navBarColor = [[ProjectorP2P_SessionManager sharedManager] navBarColorForP2PSessionState];
    if (navBarColor) {
        proNav.navigationBar.barTintColor = navBarColor;
        proNav.navigationBar.tintColor = [[ProjectorP2P_SessionManager sharedManager] navBarTintColorForP2PSessionState];
    }
    else {
        [proNav updateCurrentBarStyle];
    }
}


#pragma mark -
#pragma mark - Nav actions
- (void)showMenuSidebarAction:(id)sender {
    [[[PROAppDelegate delegate] rootViewController] showLeftMenuViewAnimated:YES completion:nil];
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.view.backgroundColor = [UIColor blackColor];
    
#if DEBUG && 0
    self.logger = [[PROPlanSelectionChangeLogger alloc] init];
    [self addSelectionChangeListener:self.logger];
#endif
    
    [self setupInterface];
}

- (void)setupInterface {
    PCOView *gridCont = ({
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        
        [self.view addSubview:view];
        view;
    });
    PCOView *detailsView = ({
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        
        [self.view addSubview:view];
        view;
    });
    
    self.planGridContainerView = gridCont;
    self.planDetailsContainerView = detailsView;
    
    [self addPlanGridContainerViewConstraints];
    [self addPlanDetailsContainerConstraints];
    
    PlanViewGridViewController *controller = [[PlanViewGridViewController alloc] initWithNibName:nil bundle:nil];
    [controller pro_setContainer:self];
    [self addChildViewController:controller];
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.planGridContainerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    _gridController = controller;
    
    NSDictionary *views = @{
                            @"view": controller.view
                            };
    [self.planGridContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                                  @"V:|[view]|",
                                                                                                  @"H:|[view]|"
                                                                                                  ]
                                                                                        metrics:nil
                                                                                          views:views]];
    
    PlanOutputViewController *output = [[PlanOutputViewController alloc] initWithNibName:nil bundle:nil];
    [self addEventListener:output];
    [self addChildViewController:output];
    output.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.planDetailsContainerView addSubview:output.view];
    [output didMoveToParentViewController:self];
    [output sendControlButtonActionTo:self nextButtonSelector:@selector(playNextSlide) previousButtonSelector:@selector(playPreviousSlide)];
    _outputController = output;
    
    NSDictionary *outputViews = @{
                                  @"view": output.view
                                  };
    [self.planDetailsContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                                     @"V:|[view]|",
                                                                                                     @"H:|[view]|"
                                                                                                     ]
                                                                                           metrics:nil
                                                                                             views:outputViews]];
    
    [self.helper reloadGridInterface];
}

#pragma mark -
#pragma mark - Data
- (void)setPlan:(PCOPlan *)plan {
    [self setPlan:plan skipUpdate:NO];
}
- (void)setPlan:(PCOPlan *)plan skipUpdate:(BOOL)skipUpdate {
    NSNumber *remoteID = _plan.remoteId;
    _plan = plan;
    
    [[PROSlideManager sharedManager] setPlan:plan];
    
    self.helper.plan = plan;
    
    [[PROUIOptimization sharedOptimizer] planWasSet];
    
    self.title = [self planTitle];
    
    if (plan.remoteId && ![plan.remoteId isEqualToNumber:@0]) {
        [[PROStateSaver sharedState] setLastOpenPlanID:plan.remoteId];
    }
    
    if (plan && !skipUpdate) {
        [self updatePlanWithCompletion:nil];
    }
    
    if (![remoteID pco_isEqualToNumber:plan.remoteId]) {
        [self.helper hardResetInterface];
    }
    [self reloadData];
}
- (void)updatePlanWithCompletion:(void(^)(void))completion {
    [[PROUIOptimization sharedOptimizer] planStartedUpdating];

    welf();
    [self.gridController willBeginRefresh];
    [[[PCOCoreDataManager sharedManager] plansController] updatePlan:self.plan includeSlides:YES completion:^(BOOL success, PCOPlan *updatePlan) {
        [[PROUIOptimization sharedOptimizer] planFinishedUpdating];
        [welf setPlan:updatePlan skipUpdate:YES];
        [welf planUpdated];
        [welf.gridController didEndRefresh];
        if (completion) {
            completion();
        }
    }];
}
- (void)planUpdated {
    if ([self.plan.serviceTypeId isEqualToNumber:@(0)]) {
        return;
    }
    [[PROUIOptimization sharedOptimizer] layoutStartedUpdating];
    [[[PCOCoreDataManager sharedManager] layoutsController] getLayoutsForServiceTypeID:self.plan.serviceTypeId completion:^(NSError *error) {
        PCOError(error);
        [[PROUIOptimization sharedOptimizer] layoutFinishedUpdating];
        [[[PCOCoreDataManager sharedManager] layoutsController] defaultLayout];
        [self.helper reloadGridInterface];
    }];
    [self.helper planUpdated];
}

- (void)reloadData {
    [self.gridController startCollectionViewReload];
}

- (NSString *)planTitle {
    NSMutableString *string = [[NSMutableString alloc] init];
    if (self.helper.plan.serviceTypeName.length > 0) {
        [string appendFormat:@"%@: ",self.helper.plan.serviceTypeName];
    }
    if ([[ProjectorP2P_SessionManager sharedManager] isServer] && [[PCOLiveController sharedController].liveStatus isControlledByUserId:[PCOUserData current].userId]) {
            [string appendFormat:@"%@", [[PCOLiveController sharedController].liveStatus formattedServiceStartTime]];
    }
    else {
        if (self.helper.plan.dates.length > 0) {
            [string appendFormat:@"%@",self.helper.plan.dates];
        }
    }
    return [NSString stringWithString:string];
}

#pragma mark -
#pragma mark - Layout
- (void)addPlanGridContainerViewConstraints {
    if (self.planGridContainerConstraints) {
        [self.view removeConstraints:self.planGridContainerConstraints];
        self.planGridContainerConstraints = nil;
    }
    
    NSDictionary *views = @{
                            @"grid": self.planGridContainerView,
                            @"details": self.planDetailsContainerView
                            };
    
    NSMutableArray *constraints = [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[grid]|" options:0 metrics:nil views:views]];
    
    if ([[PROAppDelegate delegate] isPad]) {
        [constraints removeAllObjects];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[grid]-1-[details]" options:0 metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[grid]|" options:0 metrics:nil views:views]];
    } else {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[details][grid]|" options:0 metrics:nil views:views]];
    }
    
    self.planGridContainerConstraints = [constraints copy];
    [self.view addConstraints:self.planGridContainerConstraints];
}
- (void)addPlanDetailsContainerConstraints {
    if (self.planDetailsContainerConstraints) {
        [self.view removeConstraints:self.planDetailsContainerConstraints];
        self.planDetailsContainerConstraints = nil;
    }
    
    NSDictionary *views = @{
                            @"details": self.planDetailsContainerView
                            };
    
    NSMutableArray *constraints = [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[details]|" options:0 metrics:nil views:views]];
    
    if ([[PROAppDelegate delegate] isPad]) {
        [constraints removeAllObjects];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[details(==324)]|" options:0 metrics:nil views:views]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[details]|" options:0 metrics:nil views:views]];
    } else {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[details(==200)]" options:0 metrics:nil views:views]];
    }
    
    self.planDetailsContainerConstraints = [constraints copy];
    [self.view addConstraints:self.planDetailsContainerConstraints];
}

#pragma mark -
#pragma mark - Display
+ (instancetype)currentContainer {
    PROAppDelegate *delegate = [PROAppDelegate delegate];
    if (![delegate.window.rootViewController respondsToSelector:@selector(contentViewController)]) {
        return nil;
    }
    PROPlanNavigationController *viewController = (PROPlanNavigationController *)[((PCOSlidingSideViewController *)delegate.window.rootViewController) contentViewController];
    if (![viewController isKindOfClass:[PROPlanNavigationController class]]) {
        return nil;
    }
    if ([viewController.viewControllers firstObject] != viewController.topViewController) {
        [viewController popToRootViewControllerAnimated:NO];
    }
    PROPlanContainerViewController *container = (PROPlanContainerViewController *)viewController.topViewController;
    if (![container isKindOfClass:[PROPlanContainerViewController class]]) {
        return nil;
    }
    return container;
}
+ (BOOL)displayPlan:(PCOPlan *)plan {
    [PCOEventLogger logEvent:@"Opened Plan"];
    PROPlanContainerViewController *container = [self currentContainer];
    if (!container) {
        return NO;
    }
    if (![container respondsToSelector:@selector(setPlan:)]) {
        return NO;
    }
    container.plan = plan;
    return YES;
}

#pragma mark -
#pragma mark - Event Listeners
- (NSHashTable *)eventListenersHashTable {
    if (!_eventListenersHashTable) {
        _eventListenersHashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _eventListenersHashTable;
}
- (void)addEventListener:(id<PROContainerViewControllerEventListener>)eventListener {
    if ([eventListener respondsToSelector:@selector(registerForController:)]) {
        [eventListener registerForController:self];
    }
    [self.eventListenersHashTable addObject:eventListener];
}
- (void)removeEventListener:(id<PROContainerViewControllerEventListener>)eventListener {
    [self.eventListenersHashTable removeObject:eventListener];
}
- (NSArray *)eventListeners {
    return [self.eventListenersHashTable allObjects];
}

#pragma mark -
#pragma mark - Show Logo
- (void)showLogoAsNext:(PROLogo *)logo {
    [self.helper setNextToLogo:logo];
}
- (void)showLogoAsCurrent:(PROLogo *)logo {
    [self.helper setCurrentToLogo:logo];
}
- (void)replaceLogoAsCurrent:(PROLogo *)logo {
    [self.helper reloadCurrentWithLogo:logo];
}

#pragma mark -
#pragma mark - Output View Control Buttons Action Methods

- (void)playNextSlide {
    [self.helper playNextSlide];
}

- (void)playPreviousSlide {
    [self.helper playPreviousSlide];
}


// MARK: - Helper
- (PlanGridHelper *)helper {
    if (self.gridController.helper) {
        return self.gridController.helper;
    }
    return nil;
}


@end
