//
//  PRORecordingsListViewController.m
//  Projector
//
//  Created by Peter Fokos on 4/15/15.
//

#import "PRORecordingsListViewController.h"
#import "PRONavigationController.h"
#import "CommonNavButton.h"
#import "PRORecording.h"
#import "PRORecordingEvent.h"
#import "PCOTableViewDetailsCell.h"
#import "UIImage+PCOKitAdditions.h"
#import "PRORecordingListTableViewCell.h"
#import "PRORecordingPlaybackView.h"

typedef NS_ENUM(NSUInteger, ShareRecordingState) {
    ShareRecordingStateUnpublished   = 0,
    ShareRecordingStateMovieMade     = 1,
    ShareRecordingStateMakingMovie   = 2,
    ShareRecordingStateMixingVideo   = 3,
    ShareRecordingStateMixingAudio   = 4,
};

#define UPPER_CONTAINER_HEIGHT 60
#define CONTROLS_CONTAINER_HEIGHT 60
#define ADD_RECORDING_BUTTON_HEIGHT 60
#define SEPARATOR_COLOR RGB(59, 59, 68)

@interface PRORecordingsListViewController () <UITextFieldDelegate>{
    
}

@property (nonatomic, weak) UIImageView *previewImageView;
@property (nonatomic, weak) UISlider *previewSlider;

@property (nonatomic, weak) UIView *upperContainerView;
@property (nonatomic, weak) UIView *lowerContainerView;
@property (nonatomic, weak) UIView *previewContainerView;

@property (nonatomic, weak) UIView *recordingsTableContainerView;
@property (nonatomic, weak) PCOTableView *recordingsTableview;

@property (nonatomic, weak) UIView *controlsContainerView;
@property (nonatomic, weak) PCOLabel *currentTimeLabel;
@property (nonatomic, weak) PCOButton *doneButton;
@property (nonatomic, weak) PCOButton *playPauseButton;
@property (nonatomic, weak) PCOButton *shareButton;
@property (nonatomic, weak) PCOTextField *titleTextField;
@property (nonatomic, weak) PCOButton *addRecordingButton;

@property (nonatomic, weak) UIView *movieMakingModalView;
@property (nonatomic, weak) PCOLabel *movieMakingProgressLabel;
@property (nonatomic, weak) UIImageView *cameraImageView;
@property (nonatomic, weak) UIImageView *blueCircleImageView;
@property (nonatomic, weak) UIImageView *videoDoneImageView;

@property (nonatomic) NSInteger selectedRow;

@property (nonatomic, weak) AVPlayer *videoPlayer;
@property (nonatomic, weak) PRORecordingPlaybackView *videoPlaybackView;
@property (nonatomic, strong) id playerTimeObserver;

@end

@implementation PRORecordingsListViewController

- (void)loadView {
    self.title = NSLocalizedString(@"Recordings", nil);
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[PRORecordingController sharedController] setDelegate:self];
    [PCOEventLogger logEvent:@"Recorder - Recording List"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PRORecordingController sharedController] loadAllRecordings];
    self.view.backgroundColor = [self localBackgroundColor];
    self.recordingsTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.recordingsTableview reloadData];
    [self resetRecordingsTable];
    [self configureShareButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resetPlayback];
    [[PRORecordingController sharedController] setDelegate:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Helper Methods
#pragma mark -

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector{
    CGRect frame = [CommonNavButton frameWithText:text backArrow:NO];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}


- (void)resetRecordingsTable {
    self.previewSlider.value = 0.0;
    self.selectedRow = NSNotFound;
    if ([self hasRecordings]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.selectedRow = 0;
        [self.recordingsTableview reloadData];
        
        PRORecording *recording = [self recordingAtIndexPath:indexPath];
        [self updateUIForRecording:recording];
    }
    else {
        self.previewSlider.hidden = YES;
        self.currentTimeLabel.hidden = YES;
        self.previewImageView.image = nil;
        [self stageRecording:nil];
    }
}

- (void)updateCurrentTimeLabel:(CGFloat)currentTime {
    self.currentTimeLabel.text = [self formattedStringForTime:currentTime];
}

- (NSString *)formattedStringForTime:(CGFloat)time {
    NSInteger hours = time / (60 * 60);
    time = fmodf(time, (60 * 60));
    NSInteger minutes = time / 60;
    time = fmodf(time, 60);
    NSInteger seconds = time;
    NSInteger hundreths = time * 100;
    if (seconds > 0) {
        hundreths = fmod(time, (double)seconds) * 100;
    }
    NSString *formattedString = @"";
    if (hours == 0 && minutes == 0) {
        formattedString = [NSString stringWithFormat:@"%02td:%02td", seconds, hundreths];
    }
    else if (hours == 0) {
        formattedString = [NSString stringWithFormat:@"%02td:%02td:%02td", minutes, seconds, hundreths];
    }
    else {
        formattedString = [NSString stringWithFormat:@"%02td:%02td:%02td:%02td", hours, minutes, seconds, hundreths];
    }
    return formattedString;
}

- (NSString *)shortFormattedStringForTime:(CGFloat)time {
    NSInteger hours = time / (60 * 60);
    time = fmodf(time, (60 * 60));
    NSInteger minutes = time / 60;
    time = fmodf(time, 60);
    NSInteger seconds = time;
    NSString *formattedString = @"";
    if (hours == 0 && minutes == 0) {
        formattedString = [NSString stringWithFormat:@"00:%02td", seconds];
    }
    else if (hours == 0) {
        formattedString = [NSString stringWithFormat:@"00:%02td:%02td", minutes, seconds];
    }
    else {
        formattedString = [NSString stringWithFormat:@"%02td:%02td:%02td", hours, minutes, seconds];
    }
    return formattedString;
}

- (void)displayTitleForRecording:(PRORecording *)recording {
    self.titleTextField.text = recording.title;
}

- (void)updateShareRecordingStatus:(ShareRecordingState)state progress:(CGFloat)progress{
    
    NSString *progressString = [NSString stringWithFormat:@"%ld%%", (long)(progress * 100)];
    NSString *finalString = @"";
                                                                               
    switch (state) {
        case ShareRecordingStateMovieMade:
        {
            self.shareButton.enabled = YES;
            self.movieMakingProgressLabel.text = NSLocalizedString(@"Movie Finished", nil);

            break;
        }
        case ShareRecordingStateUnpublished:
        {
            self.shareButton.enabled = YES;
//            [self.shareButton setTitle:NSLocalizedString(@"Make Video", nil) forState:UIControlStateNormal];
            break;
        }
        case ShareRecordingStateMakingMovie:
        {
            self.shareButton.enabled = NO;
            finalString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Making Movie...", nil), progressString];
            self.movieMakingProgressLabel.text = finalString;
            break;
        }
        case ShareRecordingStateMixingAudio:
        {
            self.shareButton.enabled = NO;
            finalString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Mixing Audio...", nil), progressString];
            self.movieMakingProgressLabel.text = finalString;
            break;
        }
        case ShareRecordingStateMixingVideo:
        {
            self.shareButton.enabled = NO;
            finalString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Mixing Movie...", nil), progressString];
            self.movieMakingProgressLabel.text = finalString;
            break;
        }
        default:
            break;
    }
}

- (void)configurePlayPauseButton {
    if ([self isPlayingBack] || ![self hasRecordings]) {
        [self.playPauseButton setImage:nil forState:UIControlStateNormal];
    }
    else if ([self isPaused]) {
        [self.playPauseButton setImage:[UIImage imageNamed:@"recorder-play-btn"] forState:UIControlStateNormal];
    }
    else {
        [self.playPauseButton setImage:[UIImage imageNamed:@"recorder-play-btn"] forState:UIControlStateNormal];
    }
}

- (void)configureShareButton {
    if (self.selectedRow != NSNotFound) {
        self.shareButton.enabled = YES;
    }
    else {
        self.shareButton.enabled = NO;
    }
}

- (UIColor *)localBackgroundColor {
    return RGB(43, 43, 50);;
}

- (BOOL)hasRecordings {
    if ([[[PRORecordingController sharedController] allRecordings] count] > 0) {
        return YES;
    }
    return NO;
}

- (NSInteger)numberOfRecordings {
    return [[[PRORecordingController sharedController] allRecordings] count];
}

- (PRORecording *)recordingAtIndexPath:(NSIndexPath *)indexPath {
    if ([self hasRecordings]) {
        return [[[PRORecordingController sharedController] allRecordings] objectAtIndex:indexPath.row];
    }
    return nil;
}

- (PRORecording *)recordingAtIndex:(NSInteger)index {
    if ([self hasRecordings]) {
        return [[[PRORecordingController sharedController] allRecordings] objectAtIndex:index];
    }
    return nil;
}

- (void)updateUIForSliderPosition:(CGFloat)value {
    [self updateCurrentTimeLabel:0.0];
    if (self.videoPlaybackView.player.currentItem) {
         CGFloat currentTime = value * CMTimeGetSeconds(self.videoPlaybackView.player.currentItem.duration);
        [self updateCurrentTimeLabel:currentTime];
    }
}

- (void)updateUIForRecording:(PRORecording *)recording {
    [self displayTitleForRecording:recording];
    if ([[PRORecordingController sharedController] isRecordingMovieAvailable:recording]) {
        self.previewSlider.value = 0.0;
        [self updateUIForSliderPosition:0.0];
        self.previewSlider.hidden = NO;
        self.currentTimeLabel.hidden = NO;
        [self stageRecording:recording];
        [self resetPlayback];
        self.previewImageView.image = nil;
    }
    else {
        self.previewSlider.hidden = YES;
        self.currentTimeLabel.hidden = YES;
        [self stageRecording:nil];
        self.previewImageView.image = [[PRORecordingController sharedController] imageForRecording:recording atEventWithIndex:0];
    }
    [self configurePlayPauseButton];
    [self configureShareButton];
}

- (void)shareRecording:(PRORecording *)recording {
    NSURL *videoURL =[[PRORecordingController sharedController] urlOfLocalVideoForRecording:recording];
    
    if (!videoURL) {
        return;
    }
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[videoURL] applicationActivities:nil];
    
    activityView.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        [PCOEventLogger logEvent:[NSString stringWithFormat:@"Recorder - Shared recording: %@", activityType]];
    };
    
    if ([[UIDevice currentDevice] pco_isPad]) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityView];
        [popoverController presentPopoverFromRect:self.shareButton.frame inView:self.upperContainerView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:activityView animated:YES completion:^{
            
        }];
    }
}

- (void)startMakingMovieFromRecording:(PRORecording *)recording completion:(void(^)(BOOL success))completion {
    self.movieMakingProgressLabel.text = NSLocalizedString(@"Making Movie", nil);
    [self.playPauseButton setImage:nil forState:UIControlStateNormal];
    self.cameraImageView.hidden = NO;
    self.blueCircleImageView.hidden = NO;
    [self.cameraImageView startAnimating];
    [self.blueCircleImageView startAnimating];
    double delayInSeconds = 2.0;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(startTime, dispatch_get_main_queue(), ^{
        [[PRORecordingController sharedController] makeVideo:recording completion:^(BOOL success) {
            [self.cameraImageView stopAnimating];
            [self.blueCircleImageView stopAnimating];
            self.cameraImageView.hidden = YES;
            self.blueCircleImageView.hidden = YES;
            self.videoDoneImageView.hidden = NO;
            [self.videoDoneImageView startAnimating];
            double delayInSeconds = 2.5;
            dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(startTime, dispatch_get_main_queue(), ^{
                [self.videoDoneImageView stopAnimating];
                self.videoDoneImageView.hidden = YES;
                [self.movieMakingModalView removeFromSuperview];
                _movieMakingModalView = nil;
                completion(success);
            });
        }];
    });
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    count = [self numberOfRecordings];
    if (count == 0) {
        count = 1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PRORecordingListTableViewCell heightForCell];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PRORecordingListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPRORecordingListTableViewCellIdentifier];
    
    if ([self hasRecordings]) {
        PRORecording *recording = [self recordingAtIndexPath:indexPath];
        cell.textLabel.text = recording.title;
        cell.detailTextLabel.text = [self shortFormattedStringForTime:[recording recordingLengthInSeconds]];
        if (indexPath.row == self.selectedRow) {
            [cell showCheckMark:YES];
            cell.textLabel.textColor = [UIColor whiteColor];

        }
    }
    else {
        cell.textLabel.text = NSLocalizedString(@"No recordings", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"Touch NEW RECORDING to begin.", nil);
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self hasRecordings]) {
        return YES;
    }
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self hasRecordings]) {
        [self.titleTextField resignFirstResponder];
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self hasRecordings]) {
        [self resetPlayback];
        [self configurePlayPauseButton];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isPlayingBack]) {
        [self pauseVideoPlayer];
    }
    if ([self hasRecordings]) {
        self.selectedRow = indexPath.row;
        PRORecording *recording = [self recordingAtIndexPath:indexPath];
        [self updateUIForRecording:recording];
        [tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self hasRecordings];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[PRORecordingController sharedController] deleteRecording:[self recordingAtIndexPath:indexPath]];
        [self.recordingsTableview reloadData];
        [PCOEventLogger logEvent:@"Recorder - Delete Recording"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resetRecordingsTable];
            [self configureShareButton];
            [self configurePlayPauseButton];
        });
    }
}

#pragma mark -
#pragma mark - Lazy Loaders

- (PCOTableView *)recordingsTableview {
    if (!_recordingsTableview) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [self localBackgroundColor];
        table.separatorColor = SEPARATOR_COLOR;
        table.allowsMultipleSelectionDuringEditing = NO;
        [table registerClass:[PRORecordingListTableViewCell class] forCellReuseIdentifier:kPRORecordingListTableViewCellIdentifier];
        _recordingsTableview = table;
        
        [self.recordingsTableContainerView addSubview:table];
        [self.recordingsTableContainerView addConstraints:[NSLayoutConstraint pco_fitView:table inView:self.recordingsTableContainerView insets:UIEdgeInsetsZero]];
        
        self.upperContainerView.hidden = NO;
        self.previewContainerView.hidden = NO;
        self.previewImageView.hidden = NO;
        self.previewSlider.hidden = NO;
        self.lowerContainerView.hidden = NO;
        [self configurePlayPauseButton];
        [self.view bringSubviewToFront:self.previewSlider];
    }
    return _recordingsTableview;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        view.contentMode = UIViewContentModeScaleAspectFit;
        [self.previewContainerView addSubview:view];
        [self.previewContainerView addConstraints:[NSLayoutConstraint pco_fitView:view inView:self.previewContainerView insets:UIEdgeInsetsZero]];
        _previewImageView = view;
    }
    return _previewImageView;
}

- (UIView *)previewContainerView {
    if (!_previewContainerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:view];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.5625 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.upperContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        
        _previewContainerView = view;
    }
    return _previewContainerView;
}

- (UISlider *)previewSlider {
    if (!_previewSlider) {
        UISlider *slider = [UISlider newAutoLayoutView];
        slider.backgroundColor = [UIColor clearColor];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        [slider setThumbImage:[UIImage imageNamed:@"min-screen-scrubber"] forState:UIControlStateNormal];
        [slider setMinimumTrackTintColor:RGB(255, 160, 55)];
        [slider setMaximumTrackTintColor:RGB(255, 255, 255)];
        [slider addTarget:self action:@selector(scrubSliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:slider];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:slider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.previewContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        _previewSlider = slider;
    }
    return _previewSlider;
}

- (UIView *)upperContainerView {
    if (!_upperContainerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = RGB(41, 41, 48);
        [self.view addSubview:view];
        _upperContainerView = view;
        
        UIView *seperator = [UIView newAutoLayoutView];
        seperator.backgroundColor = SEPARATOR_COLOR;
        [view addSubview:seperator];
        
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                                      @"H:|[done(==60)]-8-[titleTextField]-8-[shareButton(==60)]-8-|",
                                                                                                      @"V:|[done]|",
                                                                                                      @"V:|[titleTextField]|",
                                                                                                      @"V:|[shareButton]|",
                                                                                                      @"H:|[seperator]|",
                                                                                                      @"V:[seperator(==1)]|",
                                                                                                      ]
                                                                                            metrics:nil
                                                                                              views:@{
                                                                                                      @"done": self.doneButton,
                                                                                                      @"titleTextField": self.titleTextField,
                                                                                                      @"shareButton": self.shareButton,
                                                                                                      @"seperator": seperator,
                                                                                                      }
                                                    ]];

        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:UPPER_CONTAINER_HEIGHT]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    }
    return _upperContainerView;
}

- (UIView *)lowerContainerView {
    if (!_lowerContainerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:view];
        _lowerContainerView = view;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.previewContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
    return _lowerContainerView;
}

- (UIView *)recordingsTableContainerView {
    if (!_recordingsTableContainerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        [self.lowerContainerView addSubview:view];
        
        UIView *seperator = [UIView newAutoLayoutView];
        seperator.backgroundColor = RGB(98, 190, 102);
        [self.lowerContainerView addSubview:seperator];

        [self.lowerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                                   @"H:|[recordings]|",
                                                                                                   @"H:|[controlsContainerView]|",
                                                                                                   @"H:|[seperator]|",
                                                                                                   @"H:|[add_recording_button]|",
                                                                                                   @"V:|[controlsContainerView(==controls_container_view_height)][recordings][seperator(==2)][add_recording_button(==add_button_height)]|",
                                                                                                   ]
                                                                                         metrics:@{
                                                                                                   @"controls_container_view_height": @(CONTROLS_CONTAINER_HEIGHT),
                                                                                                   @"add_button_height": @(ADD_RECORDING_BUTTON_HEIGHT)
                                                                                                   }
                                                                                           views:@{
                                                                                                   @"recordings": view,
                                                                                                   @"controlsContainerView": self.controlsContainerView,
                                                                                                   @"add_recording_button": self.addRecordingButton,
                                                                                                   @"seperator": seperator,
                                                                                                   }
                                                 ]];
        _recordingsTableContainerView = view;
        
        
    }
    return _recordingsTableContainerView;
}

- (UIView *)controlsContainerView {
    if (!_controlsContainerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        [self.lowerContainerView addSubview:view];
        _controlsContainerView = view;
    }
    return _controlsContainerView;
}

- (PCOLabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldDefaultFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
        [self.controlsContainerView addSubview:label];

        UIView *seperator = [UIView newAutoLayoutView];
        seperator.backgroundColor = SEPARATOR_COLOR;
        [self.controlsContainerView addSubview:seperator];

        [self.controlsContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                                                      @"H:|[label]|",
                                                                                                      @"H:|[seperator]|",
                                                                                                      @"V:|[label][seperator(==1)]|",
                                                                                                      ]
                                                                                            metrics:nil
                                                                                              views:@{
                                                                                                      @"label": label,
                                                                                                      @"seperator": seperator,
                                                                                                      }
                                                    ]];
        _currentTimeLabel = label;

    }
    return _currentTimeLabel;
}

- (PCOButton *)doneButton {
    if (!_doneButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [view addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.upperContainerView addSubview:view];
        _doneButton = view;
    }
    return _doneButton;
}

- (PCOButton *)playPauseButton {
    if (!_playPauseButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"full-screen-play-btn"] forState:UIControlStateNormal];
        [view addTarget:self action:@selector(playPauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.previewContainerView addSubview:view];
        _playPauseButton = view;
        [self.previewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.previewContainerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.previewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.previewContainerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.previewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.previewContainerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.previewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.previewContainerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        self.previewContainerView.userInteractionEnabled = YES;
    }
    return _playPauseButton;
}

- (PCOButton *)shareButton {
    if (!_shareButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"recorder-share-btn"] forState:UIControlStateNormal];

        [view addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.upperContainerView addSubview:view];
        _shareButton = view;
        [self updateShareRecordingStatus:ShareRecordingStateUnpublished progress:0.0];
    }
    return _shareButton;
}


- (PCOTextField *)titleTextField {
    if (!_titleTextField) {
        PCOTextField *field = [PCOTextField newAutoLayoutView];
        field.backgroundColor = [UIColor clearColor];
        field.textColor = [UIColor whiteColor];
        field.font = [UIFont defaultFontOfSize:18];
        field.text = @"";
        field.delegate = self;
        field.textAlignment = NSTextAlignmentCenter;
        _titleTextField = field;
        [self.upperContainerView addSubview:field];
    }
    return _titleTextField;
}

- (PCOButton *)addRecordingButton {
    if (!_addRecordingButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        UIColor *tintColor = RGB(98, 190, 102);
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [view setImage:[UIImage templateImageNamed:@"plus-small"] forState:UIControlStateNormal];
        view.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        [view setTitle:NSLocalizedString(@"NEW RECORDING", nil) forState:UIControlStateNormal];
        [view setTitleColor:tintColor forState:UIControlStateNormal];
        [view setTitleColor:[tintColor colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
        [view setTintColor:RGB(98, 190, 102)];
        view.titleLabel.font = [UIFont boldDefaultFontOfSize_16];
        [view addTarget:self action:@selector(addRecordingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.lowerContainerView addSubview:view];
        _addRecordingButton = view;
    }
    return _addRecordingButton;
}

- (UIView *)movieMakingModalView {
    if (!_movieMakingModalView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.8;
        view.userInteractionEnabled = YES;
        [self.view addSubview:view];
        _movieMakingModalView = view;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    }
    return _movieMakingModalView;
}

- (PCOLabel *)movieMakingProgressLabel {
    if (!_movieMakingProgressLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        if ([[UIDevice currentDevice] pco_isPad]) {
            label.font = [UIFont boldDefaultFontOfSize:16];
        }
        else {
            label.font = [UIFont boldDefaultFontOfSize:12];
        }
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        label.backgroundColor = [UIColor clearColor];
        _movieMakingProgressLabel = label;
        [self.movieMakingModalView addSubview:label];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    }
    return _movieMakingProgressLabel;
}

- (UIImageView *)cameraImageView {
    if (!_cameraImageView) {
        UIImageView *view = [UIImageView newAutoLayoutView];

        NSMutableArray *images = [[NSMutableArray alloc] init];
        NSInteger animationImageCount = 61;
        for (int i = 0; i < animationImageCount; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"camera_%04d", i]]];
        }
        UIImage *image = images[60];
        view.image = image;
        view.animationImages = images;
        view.animationDuration = 2.0;
        view.animationRepeatCount = 1;
        view.backgroundColor = [UIColor clearColor];
        view.contentMode = UIViewContentModeCenter;
        [self.movieMakingModalView addSubview:view];
        
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-80.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:image.size.width]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:image.size.height]];
        
        _cameraImageView = view;
    }
    return _cameraImageView;
}

- (UIImageView *)blueCircleImageView {
    if (!_blueCircleImageView) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        NSInteger animationImageCount = 61;
        for (int i = 0; i < animationImageCount; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"blue-circle_%04d", i]]];
        }
        UIImage *image = images[0];
        view.animationImages = images;
        view.animationDuration = 2.0;
        view.animationRepeatCount = 0;
        view.backgroundColor = [UIColor clearColor];
        view.contentMode = UIViewContentModeCenter;
        [self.movieMakingModalView addSubview:view];
        
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-80.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:image.size.width]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:image.size.height]];
        
        _blueCircleImageView = view;
    }
    return _blueCircleImageView;
}

- (UIImageView *)videoDoneImageView {
    if (!_videoDoneImageView) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        NSMutableArray *images = [[NSMutableArray alloc] init];
        NSInteger animationImageCount = 61;
        for (int i = 0; i < animationImageCount; i++) {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"load-out_%04d", i]]];
        }
        UIImage *image = images[60];
        view.image = image;
        view.animationImages = images;
        view.animationDuration = 2.0;
        view.animationRepeatCount = 1;
        view.backgroundColor = [UIColor clearColor];
        view.contentMode = UIViewContentModeCenter;
        [self.movieMakingModalView addSubview:view];
        
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.movieMakingModalView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-80.0]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:image.size.width]];
        [self.movieMakingModalView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:image.size.height]];
        
        _videoDoneImageView = view;
    }
    return _videoDoneImageView;
}

#pragma mark -
#pragma mark - PRORecordingControllerDelegate Methods

- (void)videoBuildProgress:(CGFloat)progress {
    [self updateShareRecordingStatus:ShareRecordingStateMakingMovie progress:progress];

}

- (void)videoMixProgress:(CGFloat)progress {
    [self updateShareRecordingStatus:ShareRecordingStateMixingVideo progress:progress];
}

- (void)audioMixProgress:(CGFloat)progress {
    [self updateShareRecordingStatus:ShareRecordingStateMixingAudio progress:progress];

}

- (void)videoFinished {
    [self updateShareRecordingStatus:ShareRecordingStateMovieMade progress:0.0];
}

#pragma mark -
#pragma mark - Action Methods

- (void)doneButtonAction:(id)sender {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
}

- (void)scrubSliderValueDidChange:(id)sender {
    CGFloat value = self.previewSlider.value;
    if ([self isPlayingBack]) {
        [self pauseVideoPlayer];
    }
    [self updateUIForSliderPosition:value];
    [self setVideoPlayerPosition:value];
    [self configurePlayPauseButton];
}

- (void)playPauseButtonAction:(id)sender {
    
    PRORecording *recording = [self recordingAtIndex:self.selectedRow];
    if ([[PRORecordingController sharedController] isRecordingMovieAvailable:recording]) {
        if ([self isPlayingBack]) {
            [self pauseVideoPlayer];
        }
        else if ([self isPaused]) {
            [self playVideoPlayer];
        }
        [self configurePlayPauseButton];
    }
    else {
        [self startMakingMovieFromRecording:recording completion:^(BOOL success) {
            [self updateUIForRecording:recording];
            if (success) {
                [self playPauseButtonAction:sender];
            }
        }];
    }
}

- (void)shareButtonAction:(id)sender {
    if (self.selectedRow == NSNotFound || [self numberOfRecordings] == 0) {
        return;
    }
    PRORecording *recording = [self recordingAtIndex:self.selectedRow];
    if ([[PRORecordingController sharedController] isRecordingMovieAvailable:recording]) {
        [self shareRecording:recording];
    }
    else {
        [self startMakingMovieFromRecording:recording completion:^(BOOL success) {
            [self updateUIForRecording:recording];
            if (success) {
                [self shareRecording:recording];
            }
        }];
    }
}

- (void)addRecordingButtonAction:(id)sender {
    [PCOEventLogger logEvent:@"Recorder - New Recording"];
    [[PRORecordingController sharedController] createNewRecording];
    [self.delegate updateNavButtons];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self changeTitleText:textField.text];
    [self.recordingsTableview reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *current = [textField.text mutableCopy];
    [current replaceCharactersInRange:range withString:string];
    [self changeTitleText:textField.text];
    return YES;
}

- (void)changeTitleText:(NSString *)newTitle {
    if (self.selectedRow == NSNotFound || [self numberOfRecordings] == 0) {
        return;
    }
    PRORecording *recording = [self recordingAtIndex:self.selectedRow];
    recording.title = newTitle;
    [[PRORecordingController sharedController] saveRecording:recording];
}

#pragma mark -
#pragma mark - Video Playback Methods

- (void)resetPlayback {
    [self.videoPlaybackView.player pause];
    [self.videoPlaybackView.player seekToTime:kCMTimeZero];
}

- (void)stageRecording:(PRORecording *)recording {
    if (recording == nil) {
        [self removeVideoPlayerTimeObserver];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.previewContainerView bringSubviewToFront:self.previewImageView];
        [self.previewContainerView bringSubviewToFront:self.playPauseButton];
        return;
    }
    NSURL *assetURL = [[PRORecordingController sharedController] urlOfLocalVideoForRecording:recording];
    if (assetURL) {
        AVAsset *videoAsset = [AVAsset assetWithURL:assetURL];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
        if (!_videoPlayer) {
            self.videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        }
        else {
            [self.videoPlayer replaceCurrentItemWithPlayerItem:playerItem];
        }
        
        if (!_videoPlaybackView) {
            PRORecordingPlaybackView *view = [[PRORecordingPlaybackView alloc] initWithPlayer:self.videoPlayer];
            [self.previewContainerView addSubview:view];
            [self.previewContainerView addConstraints:[NSLayoutConstraint pco_fitView:view inView:self.previewContainerView insets:UIEdgeInsetsZero]];
            _videoPlaybackView = view;
            [self.previewContainerView setNeedsUpdateConstraints];
        }
        else {
            [self.videoPlaybackView replacePlayer:self.videoPlayer];
        }
        [self.previewContainerView bringSubviewToFront:self.videoPlaybackView];
        [self.previewContainerView bringSubviewToFront:self.playPauseButton];
    }
}

- (BOOL)isPlayingBack {
    if (self.videoPlaybackView.player.rate > 0.0) {
        return YES;
    }
    return NO;
}

- (BOOL)isPaused {
    return ![self isPlayingBack];
}

- (void)playVideoPlayer {
    [self removeVideoPlayerTimeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    if (CMTimeCompare(self.videoPlayer.currentTime, self.videoPlayer.currentItem.duration) == 0) {
        [self.videoPlaybackView.player seekToTime:kCMTimeZero];
    }
    
    [self.videoPlayer play];

    
    CMTime interval = CMTimeMake(100, 1000); // 1/10 sec
    self.playerTimeObserver = [self.videoPlaybackView.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSTimeInterval currentTime = CMTimeGetSeconds(time);
        NSTimeInterval duration = CMTimeGetSeconds(self.videoPlaybackView.player.currentItem.duration);
        CGFloat position = currentTime / duration;
        self.previewSlider.value = position;
        [self updateUIForSliderPosition:self.previewSlider.value];

    }];
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notif {
    [self configurePlayPauseButton];
}

- (void)pauseVideoPlayer {
    [self removeVideoPlayerTimeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.videoPlayer pause];
}

- (void)setVideoPlayerPosition:(CGFloat)value {
    NSTimeInterval duration = CMTimeGetSeconds(self.videoPlaybackView.player.currentItem.duration);
    CGFloat newTime = duration * value;
    CMTime time = CMTimeMakeWithSeconds(newTime, NSEC_PER_SEC);
    [self.videoPlaybackView.player seekToTime:time];
}

- (void)removeVideoPlayerTimeObserver {
    if (self.videoPlaybackView.player && self.playerTimeObserver) {
        @try {
            // There is a weird issue here when enabling/disabling second screen that throws an exception.
            [self.videoPlaybackView.player removeTimeObserver:self.playerTimeObserver];
            _playerTimeObserver = nil;
        }
        @catch (NSException *exception) {
            
        }
        self.playerTimeObserver = nil;
    }
}


@end
