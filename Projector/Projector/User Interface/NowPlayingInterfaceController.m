//
//  NowPlayingInterfaceController.m
//  Projector
//
//  Created by Peter Fokos on 12/9/14.
//

#import "NowPlayingInterfaceController.h"
#import "PRODisplayController.h"

@interface NowPlayingInterfaceController ()

@property (nonatomic, weak) PROKeyboardInputHandler *keyboardInputHandler;

@property (nonatomic) BOOL hasConfigured;

@end

@implementation NowPlayingInterfaceController

#pragma mark -
#pragma mark - Init / Configure

- (instancetype)init {
    self = [super init];
    if (self) {
        [[ProjectorP2P_SessionManager sharedManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureNowPlayingInterface {
    if (!self.hasConfigured) {
        [self addAllGestures];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackTimeDidChange:) name:PRODisplayViewVideoPlaybackTimeDidChangeNotification object:nil];
        self.hasConfigured = YES;
    }
    [self setupKeyboardInputHandler];
}

#pragma mark -
#pragma mark - Lazy Loaders

- (NowPlayingControlView *)nowPlayingControlView {
    if (!_nowPlayingControlView) {
        UIView *containerView = [self.delegate nowPlayingControlViewContainerView];

        NowPlayingPlanOutputControlView *view = [NowPlayingPlanOutputControlView newAutoLayoutView];
        [view.fullScreenToggleButton addTarget:self action:@selector(fullScreenToggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view.playButton addTarget:self action:@selector(playPauseToggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [view.slider addTarget:self action:@selector(scrubSliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
        view.backgroundColor = [[self.delegate mainView]backgroundColor];
        _nowPlayingControlView = view;
        [containerView addSubview:view];
        [containerView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0 edges:UIRectEdgeAll]];
    }
    return _nowPlayingControlView;
}

- (NowPlayingDisplayViewControlView *)displayViewControlView {
    if (!_displayViewControlView) {
        PRODisplayView *containerView = [self.delegate displayViewControlViewContainerView];
        [[containerView cameraButton] addTarget:self action:@selector(cameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        NowPlayingDisplayViewControlView *view = [NowPlayingDisplayViewControlView newAutoLayoutView];
        [view.lyricsButton addTarget:self action:@selector(lyricsToggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _displayViewControlView = view;
        [containerView setControlsView:view];
        [containerView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0 edges:UIRectEdgeAll]];
        
    }
    return _displayViewControlView;
}

#pragma mark -
#pragma mark - Action Methods

- (void)fullScreenToggleButtonAction:(id)sender {
    [self.delegate showFullScreen];
}

- (void)playPauseToggleButtonAction:(id)sender {
    [PCOEventLogger logEvent:@"Now Playing - Play / Pause"];
    [self executePlayPause];
}

- (void)scrubSliderValueDidChange:(id)sender {
    CGFloat value = self.nowPlayingControlView.slider.value;
    CGFloat totalLength = [[PRODisplayController sharedController] displayVideoDurationInSeconds];
    CGFloat targetTime = totalLength * value;
    [[PRODisplayController sharedController] displayVideoScrubToPositionInSeconds:targetTime];
}

- (void)lyricsToggleButtonAction:(id)sender {
    if ([[PRODisplayController sharedController] displayLyricsOn]) {
        [PCOEventLogger logEvent:@"Now Playing - Clear Lyrics"];
        [self executeClearLyrics];
    }
    else {
        [PCOEventLogger logEvent:@"Now Playing - Show Lyrics"];
        [self executeShowLyrics];
    }
}

- (void)toggleNowPlayingControlsAction:(UIPinchGestureRecognizer *)sender {
    [self.displayViewControlView toggleAlpha];
    [self.nowPlayingControlView toggleAlpha];
}

- (void)showFullScreenGestureAction:(UIPinchGestureRecognizer *)sender {
    if (sender.scale > 1.0) {
        [self.delegate showFullScreen];
    }
}

- (void)swipePreviousGestureAction:(UISwipeGestureRecognizer *)sender {
    [PCOEventLogger logEvent:@"Swipe to Previous Slide"];
    [self.delegate playPreviousSlide];
}

- (void)swipeNextGestureAction:(UISwipeGestureRecognizer *)sender {
    [PCOEventLogger logEvent:@"Swipe to Next Slide"];
    [self.delegate playNextSlide];
}

- (void)swipeHideLyricsGestureAction:(UISwipeGestureRecognizer *)sender {
    [PCOEventLogger logEvent:@"Swipe Hide Lyrics"];
    [self executeClearLyrics];
}

- (void)swipeShowLyricsGestureAction:(UISwipeGestureRecognizer *)sender {
    [PCOEventLogger logEvent:@"Swipe Show Lyrics"];
    [self executeShowLyrics];
}

#pragma mark -
#pragma mark - Gesture Recognizer Delegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]] || [touch.view isKindOfClass:[UIButton class]]){
        return FALSE;
    }
    return TRUE;
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


#pragma mark -
#pragma mark - Helper Methods

- (void)addAllGestures {
    [self.displayViewControlView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(showFullScreenGestureAction:)]];
    [self.displayViewControlView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNowPlayingControlsAction:)]];
    
    UISwipeGestureRecognizer *nextSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNextGestureAction:)];
    [nextSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    nextSwipeRecognizer.delegate = self;
    [self.displayViewControlView addGestureRecognizer:nextSwipeRecognizer];
    
    UISwipeGestureRecognizer *previousSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePreviousGestureAction:)];
    [previousSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    previousSwipeRecognizer.delegate = self;
    [self.displayViewControlView addGestureRecognizer:previousSwipeRecognizer];
    
    UIView *containerView = [self.delegate nextContainerView];

    UISwipeGestureRecognizer *nextUpSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeNextGestureAction:)];
    [nextUpSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    nextUpSwipeRecognizer.delegate = self;
    [containerView addGestureRecognizer:nextUpSwipeRecognizer];
    
    UISwipeGestureRecognizer *previousUpSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePreviousGestureAction:)];
    [previousUpSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    previousUpSwipeRecognizer.delegate = self;
    [containerView addGestureRecognizer:previousUpSwipeRecognizer];
    
    UISwipeGestureRecognizer *showLyricsSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeShowLyricsGestureAction:)];
    [showLyricsSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    showLyricsSwipeRecognizer.delegate = self;
    [self.displayViewControlView addGestureRecognizer:showLyricsSwipeRecognizer];
    
    UISwipeGestureRecognizer *hideLyricsSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHideLyricsGestureAction:)];
    [hideLyricsSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    hideLyricsSwipeRecognizer.delegate = self;
    [self.displayViewControlView addGestureRecognizer:hideLyricsSwipeRecognizer];
    
    UISwipeGestureRecognizer *showNextLyricsSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeShowLyricsGestureAction:)];
    [showNextLyricsSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    showNextLyricsSwipeRecognizer.delegate = self;
    [containerView addGestureRecognizer:showNextLyricsSwipeRecognizer];
    
    UISwipeGestureRecognizer *hideNextLyricsSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHideLyricsGestureAction:)];
    [hideNextLyricsSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    hideNextLyricsSwipeRecognizer.delegate = self;
    [containerView addGestureRecognizer:hideNextLyricsSwipeRecognizer];
}

- (void)configureNowPlayingDisplay {
    [self configurePlayPauseButton];
    [self configureNowPlayingTimeLabel];
    [self configureLyricsButton];
    self.nowPlayingControlView.slider.value = [[PRODisplayController sharedController] displayVideoPositionZeroToOne];
}

- (void)configureNowPlayingTimeLabel {
    self.displayViewControlView.timeLabel.text = [[PRODisplayController sharedController] displayVideoTimeRemainingFormattedString];
}

- (void)configurePlayPauseButton {
    VideoPlayState playState = [[PRODisplayController sharedController] currentSlideVideoPlayState];
    [self.nowPlayingControlView configurePlayPauseButtonForVideoPlayState:playState];
}

- (void)configureLyricsButton {
    PRODisplayView *containerView = [self.delegate displayViewControlViewContainerView];

    if (containerView.hideLyrics) {
        [self.displayViewControlView setLyricsButtonToShowHide:YES];
    }
    else {
        [self.displayViewControlView setLyricsButtonToShowHide:NO];
    }
}

#pragma mark -
#pragma mark - Notifications

- (void)playbackTimeDidChange:(NSNotification *)notif {
    [self configureNowPlayingDisplay];
}

#pragma mark -
#pragma mark - PROFullScreenCurrentViewControllerDelegate

// Data Source

- (VideoPlayState)fullScreenVideoPlayState {
    return [[PRODisplayController sharedController] currentSlideVideoPlayState];
}

- (NSString *)fullScreenTimeLeftLabelText {
    return @"";
}

- (NSString *)fullScreenSlideTitleText:(FSSlideTitleType)slideTitleType {
    switch (slideTitleType) {
        case FSSlideTitleTypeCurrent:
            return [self.delegate currentItemTitleText];
            break;
            
        case FSSlideTitleTypePrevious:
            return [self.delegate previousItemTitleText];
            break;
        case FSSlideTitleTypeNext:
            return [self.delegate nextItemTitleText];
            break;
        default:
            break;
    }
    return nil;
}

// Delegate
- (void)fullScreenExecuteControlType:(FSControlType)controlType {
    switch (controlType) {
        case FSControlTypeTogglePlayPause:
            [PCOEventLogger logEvent:@"Full Screen - Play / Pause"];
            [self executePlayPause];
            break;
            
        case FSControlTypeNextSlide:
            [PCOEventLogger logEvent:@"Full Screen - Next Slide"];
            [self.delegate playNextSlide];
            break;
            
        case FSControlTypePreviousSilde:
            [PCOEventLogger logEvent:@"Full Screen - Previous Slide"];
            [self.delegate playPreviousSlide];
            break;
            
        case FSControlTypeLyricsOn:
            [PCOEventLogger logEvent:@"Full Screen - Show Lyrics"];
            [self executeShowLyrics];
            break;
            
        case FSControlTypeLyricsOff:
            [PCOEventLogger logEvent:@"Full Screen - Clear Lyrics"];
            [self executeClearLyrics];
            break;
            
        case FSControlTypeAlertDialog:
            [PCOEventLogger logEvent:@"Full Screen - Alert Dialog"];
            break;
            
        case FSControlTypeBlackScreen:
            [PCOEventLogger logEvent:@"Full Screen - Black Screen"];
            [self.delegate playBlackScreen];
            break;
            
        case FSControlTypeLogoScreen:
            [PCOEventLogger logEvent:@"Full Screen - Logo Screen"];
            [self.delegate playLogo];
            break;
            
        default:
            break;
    }
}

- (BOOL)shouldPresentLogoPicker {
    return [self.delegate shouldPresentLogoPicker];
}

- (void)executePlayPause {
    switch ([[PRODisplayController sharedController] currentSlideVideoPlayState]) {
        case VideoPlayStateNoVideo:
            
            break;
            
        case VideoPlayStatePlay:
            [[PRODisplayController sharedController] displayVideoPause];
            [[ProjectorP2P_SessionManager sharedManager] serverSendPauseVideo];
            
            break;
            
        case VideoPlayStatePause:
            [[PRODisplayController sharedController] displayVideoPlay];
            [[ProjectorP2P_SessionManager sharedManager] serverSendPlayVideo];
            
            break;
            
        default:
            break;
    }
    [self configurePlayPauseButton];
}

- (void)executeShowLyrics {
    [[PRODisplayController sharedController] displayShowLyrics];
    [[ProjectorP2P_SessionManager sharedManager] serverSendShowLyrics];
    [self.displayViewControlView setLyricsButtonToShowHide:NO];
    [self.displayViewControlView setNeedsDisplay];
}

- (void)executeClearLyrics {
    [[PRODisplayController sharedController] displayHideLyrics];
    [[ProjectorP2P_SessionManager sharedManager] serverSendHideLyrics];
    [self.displayViewControlView setLyricsButtonToShowHide:YES];
    [self.displayViewControlView setNeedsDisplay];
}

#pragma mark -
#pragma mark - Text Input

- (PROKeyboardInputHandler *)keyboardInputHandler {
    if (!_keyboardInputHandler) {
        PROKeyboardInputHandler *inputHandler = [[PROKeyboardInputHandler alloc] initWithDelegate:self];
        _keyboardInputHandler = inputHandler;
        [[self.delegate mainView] addSubview:inputHandler];
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
        [PCOEventLogger logEvent:@"Foot Pedal to Previous Slide"];
        [self.delegate playPreviousSlide];
    }
    // Next Slide
    else if ([keyString isEqualToString:@"Right Arrow"] || [keyString isEqualToString:@"Port 3"] || ([keyString isEqualToString:@" "] && [[ProjectorSettings userSettings] spaceTriggersNext]) || [keyString isEqualToString:[[ProjectorSettings userSettings] forwardKeyString]] ) {
        [PCOEventLogger logEvent:@"Foot Pedal to Next Slide"];
        [self.delegate playNextSlide];
    }
    // B key for Black screen
    else if ([[keyString lowercaseString] isEqualToString:@"b"] && [[ProjectorSettings userSettings] bKeyTriggersBlack]) {
        [PCOEventLogger logEvent:@"Foot Pedal Black Screen"];
        [self.delegate playBlackScreen];
    }
    // L key for Logo Screen
    else if ([[keyString lowercaseString] isEqualToString:@"l"] && [[ProjectorSettings userSettings] lKeyTriggersLogo]) {
        [PCOEventLogger logEvent:@"Foot Pedal Logo Screen"];
        [self.delegate playLogo];
    }
    // C key for clear lyrics
    else if ([[keyString lowercaseString] isEqualToString:@"c"] && [[ProjectorSettings userSettings] cKeyClearsLyrics]) {
        [PCOEventLogger logEvent:@"Foot Pedal Clear Lyrics"];
        [self executeClearLyrics];
    }
}

#pragma mark -
#pragma mark - ProjectorP2P_SessionManagerDelegate Methods

- (void)playSlideAtIndex:(NSInteger)slideIndex withPlanItemIndex:(NSInteger)planItemIndex andScrubPosition:(float)scrubPosition shouldPause:(BOOL)shouldPause {
    [self.delegate playSlideAtIndex:slideIndex withPlanItemIndex:planItemIndex andScrubPosition:scrubPosition shouldPause:shouldPause];
}

- (void)playBlackScreen {
    [self.delegate playBlackScreen];
}

- (void)playLogo {
    [self.delegate playLogo];
}

- (void)showAlertText:(NSString *)alertText {
    PROAlertView *alert = [[PROAlertView alloc] initWithText:alertText];
    [[PRODisplayController sharedController] displayAlert:alert];
    [PCOEventLogger logEvent:@"Nursery Alert - Alert Displayed"];
}

- (void)hideAlertText {
    [[PRODisplayController sharedController] displayAlert:nil];
}

- (void)showLyrics {
    [self executeShowLyrics];
}

- (void)hideLyrics {
    [self executeClearLyrics];
}

- (void)playVideo {
    [[PRODisplayController sharedController] displayVideoPlay];
    [self configurePlayPauseButton];
}

- (void)pauseVideo {
    [[PRODisplayController sharedController] displayVideoPause];
    [self configurePlayPauseButton];
}

- (void)scrubVideo:(float)scrubPosition {
    [[PRODisplayController sharedController] displayVideoScrubToPositionInSeconds:scrubPosition];
}

- (NSArray *)playStatus {
    BOOL playState = NO;
    CGFloat position = 0.0;
    if ([[PRODisplayController sharedController] currentSlideVideoPlayState] == VideoPlayStatePlay) {
        playState = YES;
        position = [[PRODisplayController sharedController] displayVideoPositionZeroToOne];
    }
    else if ([[PRODisplayController sharedController] currentSlideVideoPlayState] == VideoPlayStatePause) {
        position = [[PRODisplayController sharedController] displayVideoPositionZeroToOne];
    }
    return @[
             @([[self.delegate currentIndexPath] row]),
             @([[self.delegate currentIndexPath] section]),
             @(playState),
             @(position)
             ];
}


@end
