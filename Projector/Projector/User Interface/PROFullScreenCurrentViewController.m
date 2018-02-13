/*!
 * PROFullScreenCurrentViewController.m
 *
 *
 * Created by Skylar Schipper on 7/21/14
 */

#import "PROFullScreenCurrentViewController.h"
#import "PRODisplayController.h"
#import "ProjectorAlertViewController.h"
#import "PRONavigationController.h"

@interface _PROFullScreenCurrentViewControllerAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@interface PROFullScreenCurrentViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic) CGRect displayRect;
@property (nonatomic, strong) PRODisplayView *fullScreenDisplayView;
@property (nonatomic, weak) NowPlayingFullScreenControlView *nowPlayingControlView;
@property (nonatomic, weak) PROKeyboardInputHandler *keyboardInputHandler;

@end

@implementation PROFullScreenCurrentViewController

- (void)initializeDefaults {
    [super initializeDefaults];
    [PCOEventLogger logEvent:@"Full Screen - Started"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.nowPlayingControlView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchToCloseFullScreenView:)]];
    
    UISwipeGestureRecognizer *nextSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNextGestureAction:)];
    [nextSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    nextSwipeRecognizer.delegate = self;
    [self.nowPlayingControlView addGestureRecognizer:nextSwipeRecognizer];
    
    UISwipeGestureRecognizer *previousSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePreviousGestureAction:)];
    [previousSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    previousSwipeRecognizer.delegate = self;
    [self.nowPlayingControlView addGestureRecognizer:previousSwipeRecognizer];
    
    UISwipeGestureRecognizer *showLyricsSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeShowLyricsGestureAction:)];
    [showLyricsSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    showLyricsSwipeRecognizer.delegate = self;
    [self.nowPlayingControlView addGestureRecognizer:showLyricsSwipeRecognizer];
    
    UISwipeGestureRecognizer *hideLyricsSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHideLyricsGestureAction:)];
    [hideLyricsSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    hideLyricsSwipeRecognizer.delegate = self;
    [self.nowPlayingControlView addGestureRecognizer:hideLyricsSwipeRecognizer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControlVisability:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    [self.nowPlayingControlView addGestureRecognizer:tap];
    
    self.fullScreenDisplayView.controlsView.hidden = YES;
    [self toggleControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshScreenComponents];
    [self.view layoutIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackTimeDidChange:) name:PRODisplayViewVideoPlaybackTimeDidChangeNotification object:nil];
    if (![[PROAppDelegate delegate] isPad]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    if ([[PRODisplayController sharedController] liveView] != self.fullScreenDisplayView) {
        [self.fullScreenDisplayView displayBackground:[[[[PRODisplayController sharedController] liveView] item] background]];
    }
    [[PRODisplayController sharedController] displayCurrentItem:[[[PRODisplayController sharedController] liveView] item]];
    [self setupKeyboardInputHandler];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (![[PROAppDelegate delegate] isPad]) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
}

- (void)dealloc {
    [[PRODisplayController sharedController] removeView:self.fullScreenDisplayView];
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}
#pragma mark -
#pragma mark - Text Input

- (PROKeyboardInputHandler *)keyboardInputHandler {
    if (!_keyboardInputHandler) {
        PROKeyboardInputHandler *inputHandler = [[PROKeyboardInputHandler alloc] initWithDelegate:self];
        _keyboardInputHandler = inputHandler;
        [self.view addSubview:inputHandler];
    }
    return _keyboardInputHandler;
}

- (void)setupKeyboardInputHandler {
    if ([_keyboardInputHandler isFirstResponder]) {
        [_keyboardInputHandler resignFirstResponder];
        [_keyboardInputHandler removeFromSuperview];
        _keyboardInputHandler = nil;
    }
    [self.keyboardInputHandler becomeFirstResponder];
    [self.keyboardInputHandler.keyboardInputs removeAllObjects];
}

- (void)keyboardInputHandler:(PCOKeyboardInputHandler *)inputHandler didRecieveKeyboardCommand:(UIKeyCommand *)keyboardCommand {
    NSString *keyString = keyboardCommand.input;
    
    // Previous Slide
    if ([keyString isEqualToString:@"Left Arrow"] || [keyString isEqualToString:@"Port 1"] || [keyString isEqualToString:[[ProjectorSettings userSettings] backKeyString]]) {
        [PCOEventLogger logEvent:@"Full Screen - Foot Pedal to Previous Slide"];
        [self.delegate fullScreenExecuteControlType:FSControlTypePreviousSilde];
    }
    // Next Slide
    else if ([keyString isEqualToString:@"Right Arrow"] || [keyString isEqualToString:@"Port 3"] || ([keyString isEqualToString:@" "] && [[ProjectorSettings userSettings] spaceTriggersNext]) || [keyString isEqualToString:[[ProjectorSettings userSettings] forwardKeyString]] ) {
        [PCOEventLogger logEvent:@"Full Screen - Foot Pedal to Next Slide"];
        [self.delegate fullScreenExecuteControlType:FSControlTypeNextSlide];
    }
    // B key for Black screen
    else if ([[keyString lowercaseString] isEqualToString:@"b"] && [[ProjectorSettings userSettings] bKeyTriggersBlack]) {
        [PCOEventLogger logEvent:@"Full Screen - Foot Pedal Black Screen"];
        [self.delegate fullScreenExecuteControlType:FSControlTypeBlackScreen];
    }
    // L key for Logo Screen
    else if ([[keyString lowercaseString] isEqualToString:@"l"] && [[ProjectorSettings userSettings] lKeyTriggersLogo]) {
        [PCOEventLogger logEvent:@"Full Screen - Foot Pedal Logo Screen"];
        [self logoButtonAction:nil];
    }
    // C key for clear lyrics
    else if ([[keyString lowercaseString] isEqualToString:@"c"] && [[ProjectorSettings userSettings] cKeyClearsLyrics]) {
        [PCOEventLogger logEvent:@"Full Screen - Foot Pedal Clear Lyrics"];
        [self.delegate fullScreenExecuteControlType:FSControlTypeLyricsOff];
    }
}


#pragma mark - Gesture Recognizer Delegate Methods
#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]] || [touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[PRODisplayViewActionButton class]]){
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

#pragma mark - Gesture Recognizer Action Methods
#pragma mark -

- (void)swipePreviousGestureAction:(UISwipeGestureRecognizer *)sender {
    [self.delegate fullScreenExecuteControlType:FSControlTypePreviousSilde];
    [self refreshScreenComponents];
}

- (void)swipeNextGestureAction:(UISwipeGestureRecognizer *)sender {
    [self.delegate fullScreenExecuteControlType:FSControlTypeNextSlide];
    [self refreshScreenComponents];
}

- (void)swipeHideLyricsGestureAction:(UISwipeGestureRecognizer *)sender {
    [self.delegate fullScreenExecuteControlType:FSControlTypeLyricsOff];
    [self.fullScreenDisplayView setHideLyrics:YES];
    [self refreshScreenComponents];
}

- (void)swipeShowLyricsGestureAction:(UISwipeGestureRecognizer *)sender {
    [self.delegate fullScreenExecuteControlType:FSControlTypeLyricsOn];
    [self.fullScreenDisplayView setHideLyrics:NO];
    [self refreshScreenComponents];
}

- (void)pinchToCloseFullScreenView:(UIPinchGestureRecognizer *)sender {
    if (sender.scale < 1.0) {
        [self dismissFullScreenView];
    }
}

#pragma mark - Transition Animation
#pragma mark -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [_PROFullScreenCurrentViewControllerAnimator new];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [_PROFullScreenCurrentViewControllerAnimator new];
}

- (void)presentCurrentFromFrame:(CGRect)frame {
    frame = [[[UIApplication sharedApplication] keyWindow] convertRect:frame toView:self.view];
    
    self.fullScreenDisplayView.frame = frame;
    
    [[PRODisplayController sharedController] refreshAllViews];
    
    [UIView animateWithDuration:PCOKitDefaultAnimationDuration animations:^{
        self.fullScreenDisplayView.frame = PCOKitRectThatFitsSizeWithAspect(self.view.bounds.size, ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]));
    } completion:^(BOOL finished) {
        self.displayRect = frame;
        [[PRODisplayController sharedController] refreshAllViews];
    }];
}

#pragma mark - Lazy Loader Methods
#pragma mark -

- (NowPlayingControlView *)nowPlayingControlView {
    if (!_nowPlayingControlView) {
        NowPlayingFullScreenControlView *view = [NowPlayingFullScreenControlView newAutoLayoutView];
        _nowPlayingControlView = view;
        [view.fullScreenToggleButton addTarget:self action:@selector(fullScreenToggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view.nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view.previousButton addTarget:self action:@selector(previousButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view.playButton addTarget:self action:@selector(playPauseToggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view.slider addTarget:self action:@selector(scrubSliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:view];
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0 edges:UIRectEdgeAll]];
    }
    return _nowPlayingControlView;
}

- (PRODisplayView *)fullScreenDisplayView {
    if (!_fullScreenDisplayView) {
        PRODisplayView *view = [PRODisplayView newAutoLayoutView];
        view.priority = PRODisplayViewPriorityHighLiveScreen;
        view.showActionButtons = YES;
        _fullScreenDisplayView = view;
        UIView *superview = self.nowPlayingControlView.displayView;
        [superview addSubview:view];
        
        
        ProjectorAspectRatio aspect = [[ProjectorSettings userSettings] aspectRatio];
        
        [superview addConstraint:[NSLayoutConstraint centerViewHorizontalyInSuperview:view]];
        
        NSLayoutConstraint *centerVert = [NSLayoutConstraint centerViewVerticalyInSuperview:view];
        centerVert.priority = UILayoutPriorityDefaultHigh;
        [superview addConstraint:centerVert];
        [superview addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
        
        NSLayoutConstraint *leftEdge = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:superview attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        leftEdge.priority = 999;
        [superview addConstraint:leftEdge];
        NSLayoutConstraint *rightEdge = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:superview attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        rightEdge.priority = 999;
        [superview addConstraint:rightEdge];
        
        if (aspect == ProjectorAspectRatio_4_3) {
            leftEdge.priority = UILayoutPriorityDefaultLow;
            rightEdge.priority = UILayoutPriorityDefaultLow;
            [superview addConstraint:ProjectorCreateAspectConstraint(aspect, view)];
        }
        
        
        
        [[PRODisplayController sharedController] registerView:view];
        
        if (![[PROAppDelegate delegate] isPad]) {
            view.actionButtonsTopOffset = 48.0;
        }
    }
    return _fullScreenDisplayView;
}


#pragma mark -
#pragma mark - Helper Methods

- (void)refreshScreenComponents {
    self.nowPlayingControlView.titleLabel.text = [self.delegate fullScreenSlideTitleText:FSSlideTitleTypeCurrent];
    NSString *nextTitle = [self.delegate fullScreenSlideTitleText:FSSlideTitleTypeNext];
    self.nowPlayingControlView.nextButton.hidden = YES;
    self.nowPlayingControlView.nextLabel.hidden = YES;
    if (nextTitle) {
        self.nowPlayingControlView.nextLabel.text = nextTitle;
        self.nowPlayingControlView.nextButton.hidden = NO;
        self.nowPlayingControlView.nextLabel.hidden = NO;
    }
    NSString *previousTitle = [self.delegate fullScreenSlideTitleText:FSSlideTitleTypePrevious];
    self.nowPlayingControlView.previousButton.hidden = YES;
    self.nowPlayingControlView.previousLabel.hidden = YES;
    if (previousTitle) {
        self.nowPlayingControlView.previousLabel.text = previousTitle;
        self.nowPlayingControlView.previousButton.hidden = NO;
        self.nowPlayingControlView.previousLabel.hidden = NO;
    }
    [self configureNowPlayingDisplay];
}

- (void)playbackTimeDidChange:(NSNotification *)notif {
    [self configureNowPlayingDisplay];
}

- (void)deviceDidChangeOrientation:(NSNotification *)notif {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsPortrait(deviceOrientation))
    {
        [self performSelector:@selector(dismissFullScreenView) withObject:nil afterDelay:0.01];
    }
}

- (void)configureNowPlayingDisplay {
    [self configurePlayPauseButton];
    [self configureNowPlayingTimeLabel];
    self.nowPlayingControlView.slider.value = [[PRODisplayController sharedController] displayVideoPositionZeroToOne];
}

- (void)configurePlayPauseButton {
    VideoPlayState playState = [self.delegate fullScreenVideoPlayState];
    [self.nowPlayingControlView configurePlayPauseButtonForVideoPlayState:playState];
}

- (void)configureNowPlayingTimeLabel {
    self.nowPlayingControlView.timeLabel.text = [[PRODisplayController sharedController] displayVideoTimeRemainingFormattedString];
}

#pragma mark -
#pragma mark - Action Methods

- (void)toggleControlVisability:(UITapGestureRecognizer *)sender {
    [self toggleControls];
}

- (void)toggleControls {
    CGFloat newAlpha = 1.0;
    
    if (self.nowPlayingControlView.topView.alpha != 0.0) {
        newAlpha = 0.0;
    }
    
    [UIView animateWithDuration:ALPHA_ANIMATION_TIME animations:^{
        self.nowPlayingControlView.topView.alpha = newAlpha;
        self.nowPlayingControlView.bottomView.alpha = newAlpha;
        if (newAlpha == 0) {
            self.fullScreenDisplayView.showActionButtons = NO;
        }
        else {
            self.fullScreenDisplayView.showActionButtons = YES;
            [self.fullScreenDisplayView.actionAlertButton addTarget:self action:@selector(alertButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.fullScreenDisplayView.actionLogoButton addTarget:self action:@selector(logoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.fullScreenDisplayView.actionBlackButton addTarget:self action:@selector(blackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
    
}

- (void)alertButtonAction:(id)sender {
    if ([[PRODisplayController sharedController] isAnAlertActive]) {
        [PCOEventLogger logEvent:@"Full Screen - Nursery Alert - Dismiss Alert"];
        [[PRODisplayController sharedController] displayAlert:nil];
    } else {
        ProjectorAlertViewController *controller = [[ProjectorAlertViewController alloc] initWithNibName:nil bundle:nil];
        
        PRONavigationController *nav = [[PRONavigationController alloc] initWithRootViewController:controller];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)logoButtonAction:(id)sender {
    if ([self.delegate shouldPresentLogoPicker]) {
        [self presentLogoPicker:sender];
    }
}

- (void)presentLogoPicker:(id)sender {
    PRODisplayViewActionButton *button = (PRODisplayViewActionButton *)sender;
    PROLogoPickerViewController *controller = [[PROLogoPickerViewController alloc] initWithStyle:UITableViewStylePlain];
    controller.plan = self.plan;
    controller.delegate = self;
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:controller];
    navigation.modalPresentationStyle = UIModalPresentationPopover;
    navigation.popoverPresentationController.sourceView = self.view;
    CGRect rect = button.frame;
    rect.origin.y -= (button.bounds.size.height / 2);
    rect = [self.view convertRect:rect fromCoordinateSpace:self.fullScreenDisplayView];
    navigation.popoverPresentationController.sourceRect = rect;
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)logoDoneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)logoPicker:(PROLogoPickerViewController *)picker didSelectLogo:(PROLogo *)logo {
    [self.delegate fullScreenExecuteControlType:FSControlTypeLogoScreen];
}

- (void)blackButtonAction:(id)sender {
    [self.delegate fullScreenExecuteControlType:FSControlTypeBlackScreen];
}

- (void)playPauseToggleButtonAction:(id)sender {
    [self.delegate fullScreenExecuteControlType:FSControlTypeTogglePlayPause];
    [self refreshScreenComponents];
}

- (void)scrubSliderValueDidChange:(id)sender {
    CGFloat value = self.nowPlayingControlView.slider.value;
    CGFloat totalLength = [[PRODisplayController sharedController] displayVideoDurationInSeconds];
    CGFloat targetTime = totalLength * value;
    [[PRODisplayController sharedController] displayVideoScrubToPositionInSeconds:targetTime];
}

- (void)fullScreenToggleButtonAction:(id)sender {
    [self dismissFullScreenView];
}

- (void)nextButtonAction:(id)sender {
    [self.delegate fullScreenExecuteControlType:FSControlTypeNextSlide];
    [self refreshScreenComponents];
}

- (void)previousButtonAction:(id)sender {
    [self.delegate fullScreenExecuteControlType:FSControlTypePreviousSilde];
    [self refreshScreenComponents];
}

#pragma mark -
#pragma mark - Helper Methods


- (void)dismissFullScreenView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

#pragma mark -
#pragma mark - Transition Animation Methods

@implementation _PROFullScreenCurrentViewControllerAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return PCOKitDefaultAnimationDuration;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *ctx = [transitionContext containerView];
    
    if (!to.view.superview) {
        [ctx addSubview:to.view];
    }
    
    to.view.frame = ctx.bounds;
    
    CGFloat toA = 1.0;
    CGFloat fromA = 1.0;
    
    if ([to isKindOfClass:[PROFullScreenCurrentViewController class]]) {
        toA = 0.0;
    } else {
        fromA = 0.0;
    }
    
    [UIView animateWithDuration:PCOKitDefaultAnimationDuration animations:^{
        to.view.alpha = toA;
        from.view.alpha = fromA;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

@end

