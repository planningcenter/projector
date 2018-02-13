//
//  PRORecordingController.m
//  Projector
//
//  Created by Peter Fokos on 4/13/15.
//

#import "PRORecordingController.h"
#import "PCOPlan.h"
#import "PCOItem.h"
#import "PRODisplayItem.h"
#import "PROBlackItem.h"
#import "PROLogoDisplayItem.h"
#import "PRODisplayController.h"
#import "PROEndOfPlanItem.h"
#import "PlanGridHelper.h"
#import "PRORecording.h"
#import "PRORecordingEvent.h"
#import "PRODisplayController.h"
#import "PCOConnection.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PROPlanContainerViewController.h"
#import "PROSlideManager.h"
#import "PCOCustomSlide.h"
#import "PCOAttachment+ProjectorAdditions.h"
#import "PCOPlanItemMedia.h"
#import "PCOMedia.h"
#import "PROBlackItem.h"
#import "PROSlideItem.h"

id static _sharedPRORecordingController = nil;

static NSString * const RecordingsFolder        = @"recordings";
static NSString * const AudioFilename           = @"audio.m4a";
static NSString * const PathPrefix              = @"PRORecording_";
static NSString * const VideoExtension          = @"mp4";
static NSString * const EventPrefix             = @"PRORecordingEvent_";
static NSString * const ImageExtension          = @"png";
static NSString * const RecordingDataFilename   = @"RecordingData.plist";
static NSString * const FilterPredecate         = @"path contains 'PRORecording'";

@interface PRORecordingController ()

@property (nonatomic, weak) PCOPlan *plan;
@property (nonatomic, weak) PCOItem *item;

@property (nonatomic, strong) PRORecording *currentRecording;
@property (nonatomic, strong) PRORecordingEvent *currentEvent;

@property (nonatomic, strong) NSString *recordingDirectory;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;

@property (nonatomic, strong) PRORecordingVideoBuilder *videoBuilder;

@end

@implementation PRORecordingController

#pragma mark -
#pragma mark - Singleton

+ (instancetype)sharedController {
    @synchronized (self) {
        if (!_sharedPRORecordingController) {
            _sharedPRORecordingController = [[[self class] alloc] init];
        }
        return _sharedPRORecordingController;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:nil];

    }
    return self;
}

#pragma mark -
#pragma mark - AVAudioSession Notifications

//- (void)audioSessionInterruption:(NSNotification *)notif {
//    PCOLogDebug(@"audioSessionInterruption: %@", notif.userInfo);
//}
//
//- (void)audioSessionRouteChanged:(NSNotification *)notif {
//    PCOLogDebug(@"audioSessionRouteChanged: %@", notif.userInfo);
//    PCOLogDebug(@"Category: %@", [[AVAudioSession sharedInstance] category]);
//    PCOLogDebug(@"Mode: %@", [[AVAudioSession sharedInstance] mode]);
//    PCOLogDebug(@"Recording: %d", self.audioRecorder.recording);
//}

#pragma mark -
#pragma mark - Lazy Loaders

- (NSArray *)allRecordings {
    if (!_allRecordings) {
        NSArray *array = [[NSArray alloc] init];
        _allRecordings = array;
    }
    return _allRecordings;
}

- (NSString *)recordingDirectory {
    if (!_recordingDirectory) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:RecordingsFolder];
        _recordingDirectory = path;
        [self makePathIfNeeded:_recordingDirectory];
    }
    return _recordingDirectory;
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        NSString *audioRecorderFilePath = @"";
        if (self.currentRecording && self.currentRecording.localPath) {
            audioRecorderFilePath = [[self localPathForRecording:self.currentRecording] stringByAppendingPathComponent:AudioFilename];
            NSURL *audioURL = [NSURL URLWithString:audioRecorderFilePath];

            NSDictionary *recordingSettings = @{
                                                AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                                                AVSampleRateKey: @22050.0f,
                                                AVNumberOfChannelsKey: @1,
                                                };
            
            NSError *error;
            AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:audioURL settings:recordingSettings error:&error];
            recorder.delegate = self;
            [recorder prepareToRecord];
            _audioRecorder = recorder;
        }
    }
    return _audioRecorder;
}

#pragma mark -
#pragma mark - Helper Methods

- (void)makePathIfNeeded:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

}


- (void)addRecording:(PRORecording *)recording {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.allRecordings];
    [array addObject:recording];
    self.allRecordings = [NSArray arrayWithArray:array];
}

- (BOOL)isRecordingMovieAvailable:(PRORecording *)recording {
    NSString *videoLocalPath = [[self localPathForRecording:recording] stringByAppendingPathComponent:recording.videoFileLocalPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocalPath]) {
        return YES;
    }
    return NO;
}

- (NSString *)localPathForRecording:(PRORecording *)recording {
    return [[self recordingDirectory] stringByAppendingPathComponent:recording.localPath];
}

- (NSURL *)urlOfLocalVideoForRecording:(PRORecording *)recording {
    NSString *videoLocalPath = [[self localPathForRecording:recording] stringByAppendingPathComponent:recording.videoFileLocalPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocalPath]) {
        return [NSURL fileURLWithPath:videoLocalPath];
    }
    return nil;
}

- (void)deleteRecording:(PRORecording *)recording {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[self localPathForRecording:recording] error:&error];
    if (!error) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self allRecordings]];
        [array removeObject:recording];
        self.allRecordings = [NSArray arrayWithArray:array];
    }
}

- (UIImage *)imageForRecording:(PRORecording *)recording atEventWithIndex:(NSInteger)index {
    PRORecordingEvent *event = [[recording events] objectAtIndex:index];
    NSString *imageLocalPath = [[self localPathForRecording:recording] stringByAppendingPathComponent:event.imageURL];
    return [UIImage imageWithContentsOfFile:imageLocalPath];
}

- (UIBarButtonItem *)recordBarButtonItem {
    UIImage *recordIcon = nil;
    UIButton *recordButton = nil;
    
    CGFloat buttonWidth = 64;
    NSString *startTitle = NSLocalizedString(@"Start", nil);
    NSString *stopTitle = NSLocalizedString(@"Stop", nil);
    
    if ([[UIDevice currentDevice] pco_isPad]) {
        buttonWidth = 144;
        startTitle = NSLocalizedString(@"Start Recording", nil);
        stopTitle = NSLocalizedString(@"Stop Recording", nil);
    }
    
    if ([self isRecording] || [self readyToRecord]) {
        NSString *title = startTitle;
        UIColor *tintColor = [UIColor currentItemGreenColor];
        
        if ([self isRecording]) {
            title = stopTitle;
            tintColor = RGB(116, 116, 123);
        }
        UIColor *highlightColor = [tintColor colorWithAlphaComponent:0.4];

        recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 30)];
        recordIcon = [UIImage templateImageNamed:@"recorder-icon"];
        [recordButton setTintColor:tintColor];
        [recordButton setTitle:title forState:UIControlStateNormal];
        [recordButton setTitleColor:tintColor forState:UIControlStateNormal];
        [recordButton setTitleColor:highlightColor forState:UIControlStateHighlighted];
        recordButton.titleLabel.font = [UIFont defaultFontOfSize_14];
        recordButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        recordButton.layer.borderColor = [tintColor CGColor];
        recordButton.layer.borderWidth = 1.0;
        recordButton.layer.cornerRadius = 3.0;
    }
    else {
        recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        recordIcon = [UIImage imageNamed:@"recorder-record-btn"];
    }
    [recordButton setImage:recordIcon forState:UIControlStateNormal];
    return [[UIBarButtonItem alloc] initWithCustomView:recordButton];
}

#pragma mark -
#pragma mark - Recording Methods

- (BOOL)readyToRecord {
    if (_currentRecording && !self.currentRecording.started) {
        return YES;
    }
    return NO;
}

- (BOOL)isRecording {
    if (_currentRecording && self.currentRecording.started) {
        return YES;
    }
    return NO;
}

- (void)createNewRecording {
    PRORecording *newRecording = [[PRORecording alloc] init];
    newRecording.started = nil;
    _currentRecording = newRecording;

}

- (void)cancelPendingRecording {
    _currentRecording = nil;
}

- (void)startRecording {
    if (![self isRecording]) {
        [PCOEventLogger logEvent:@"Recorder - Recording Started"];
        BOOL result;
        result = [[AVAudioSession sharedInstance] setActive:NO error:nil];
        result = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
        result = [[AVAudioSession sharedInstance] setActive:YES error:nil];

        
        PROPlanContainerViewController *planContainer = [PROPlanContainerViewController currentContainer];
        PCOPlan *plan = [planContainer plan];
        if (!plan) {
            PCOLogDebug(@"RECORDING - No plan loaded so we can't record");
            return;
        }

        self.currentRecording.started = [NSDate date];
        self.currentRecording.planId = plan.remoteId;
        CGSize outputSize = [[PRODisplayController sharedController] sizeOfCurrentItem];

        if ((int)outputSize.width % 16 != 0 ) {
            NSLog(@"Warning: video settings width must be divisible by 16.");
            CGSize newSize = CGSizeZero;
            newSize.width = ((NSInteger)(outputSize.width / 16) + 1) * 16;
            newSize.height = (newSize.width / outputSize.width) * outputSize.height;
            outputSize = newSize;
        }
   
        self.currentRecording.recordingSize = outputSize;

        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        
        [fmt setDateFormat:@"HH:mm:ss"];
        fmt.locale = [NSLocale currentLocale];

        NSString *titleString = [NSString stringWithFormat:@"%@ at %@", plan.planTitle, [fmt stringFromDate:self.currentRecording.started]];
        
        titleString = [titleString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        titleString = [titleString stringByReplacingOccurrencesOfString:@"?" withString:@"_"];
        titleString = [titleString stringByReplacingOccurrencesOfString:@"*" withString:@"_"];
        
        self.currentRecording.title = titleString;
        self.currentRecording.moreInfo = @"";
        
        NSString *pathName = [NSString stringWithFormat:@"%@%f", PathPrefix, [self.currentRecording.started timeIntervalSince1970]];
        NSString *recordingLocalPath = [[self recordingDirectory] stringByAppendingPathComponent:pathName];
        self.currentRecording.localPath = pathName;
        [self makePathIfNeeded:recordingLocalPath];
        
        NSString *videoFilename = [NSString stringWithFormat:@"%@.%@", self.currentRecording.title, VideoExtension];
        
        self.currentRecording.videoFileLocalPath = videoFilename;

        [self startAudioRecording];
        [[PRODisplayController sharedController] forceItemReload:[planContainer.helper currentItem]];
    }
    else {
        [self stopRecording];
    }
}

- (void)startAudioRecording {
    [self.audioRecorder record];
}

- (void)stopAudioRecording {
    [self.audioRecorder stop];
}

- (void)stopRecording {
    if ([self isRecording]) {
        [PCOEventLogger logEvent:@"Recorder - Recording Stopped"];
        [self stopAudioRecording];
        self.currentRecording.stopped = [NSDate date];
        self.currentEvent.stopTime = self.currentRecording.stopped;
        
        NSLog(@"Segments: %@", self.currentRecording.segments);
        
        [self addRecording:self.currentRecording];
        [self saveRecording:self.currentRecording];
//        PROPlanContainerViewController *planContainer = [PROPlanContainerViewController currentContainer];
        _currentRecording = nil;
        _currentEvent = nil;
        _audioRecorder = nil;
//        [[PRODisplayController sharedController] forceItemReload:[planContainer.helper currentItem]];
        
        
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];

    }
}

- (CGFloat)recordingDuration {
    if (_currentRecording) {
        return [self.currentRecording recordingLengthInSeconds];
    }
    return 0.0;
}

- (BOOL)displayItemHasVideoMediaType:(PRODisplayItem *)displayItem {
    // if currentItem is using a planItemMedia that is type of video then we need to
    // make a PROEvent with a video rather than an image
    
    
    PCOPlan *plan = [[PROSlideManager sharedManager] plan];
    PCOItem *planItem = [[plan orderedItems] objectAtIndex:displayItem.indexPath.section];
    
    if ([plan orderedItems].count > 0 && (NSInteger)[plan orderedItems].count > displayItem.indexPath.section) {
        NSArray *customSlides = [planItem orderedCustomSlides];
        PROSlide *slide = [[PROSlideManager sharedManager] slideForIndexPath:displayItem.indexPath];
        NSInteger orderPosition = slide.orderPosition;
        if ([customSlides count] > 0) {
            PCOCustomSlide *customSlide = [[customSlides filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"order == %@",@(orderPosition)]] lastObject];
            if (customSlide.body.length == 0 && customSlide.backgroundAttachmentId) {
                NSNumber *linkedObjectId = customSlide.selectedBackgroundAttachment.linkedObjectId;
                if (linkedObjectId) {
                    PCOPlanItemMedia *media = [[[planItem orderedPlanItemMedias] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"media.remoteId == %@", linkedObjectId]] lastObject];
                    if (media && ([media.media.type isEqualToString:@"Video"] || [media.media.type isEqualToString:@"Countdown"])) {
                        return YES;
                    }
                    return NO;
                }
            }
            else {
                return NO;
            }
        }
        else {
            if (displayItem.text.length == 0) {
                PCOAttachment *attachment = [[[planItem orderedAttachments] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"remoteId == %@", planItem.slideBackgroundAttachmentId]] lastObject];
                if (attachment) {
                    PCOPlanItemMedia *media = [[[planItem orderedPlanItemMedias] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"media.remoteId == %@", attachment.linkedObjectId]] lastObject];
                    if (media && ([media.media.type isEqualToString:@"Video"] || [media.media.type isEqualToString:@"Countdown"])) {
                        return YES;
                    }
                    return NO;
                }
            }
        }
    }
    return NO;
}

- (void)makeProEventWithImageFromDisplayItem:(PRODisplayItem *)currentItem {
    UIImage *image = [[PRODisplayController sharedController] imageOfCurrentItem];
    [self addNewPROEventType:PRORecordingEventTypeImage image:image videoPath:nil];
}

- (void)makeProEventWithVideoFromDisplayItem:(PRODisplayItem *)currentItem {
    UIImage *image = [[PRODisplayController sharedController] imageOfCurrentItem];
    NSString *videoPath = [currentItem.background.primaryBackgroundURL absoluteString];
    [self addNewPROEventType:PRORecordingEventTypeVideo image:image videoPath:videoPath];
}

- (void)currentItemDidChange:(PRODisplayItem *)currentItem {
    if (self.dontRecordNextEvent) {
        self.dontRecordNextEvent = NO;
        return;
    }
    
    if ([self isRecording]) {
        if ([currentItem isKindOfClass:[PROBlackItem class]]) {
            [self makeProEventWithImageFromDisplayItem:currentItem];
        }
        else if ([currentItem isKindOfClass:[PROLogoDisplayItem class]]) {
            [self makeProEventWithImageFromDisplayItem:currentItem];
        }
        else if ([currentItem isKindOfClass:[PRODisplayItem class]]) {
            if ([self displayItemHasVideoMediaType:currentItem]) {
                [self makeProEventWithVideoFromDisplayItem:currentItem];
            }
            else {
                [self makeProEventWithImageFromDisplayItem:currentItem];
            }
        }
    }
}

- (void)addNewPROEventType:(PRORecordingEventType)type image:(UIImage *)image videoPath:(NSString *)videoPath {
    if ([self isRecording] && image) {
        PRORecordingEvent *newEvent = [[PRORecordingEvent alloc] init];
        newEvent.startTime = [NSDate date];
        newEvent.type = type;
        
        if (self.currentEvent) {
            self.currentEvent.stopTime = newEvent.startTime;
        }
        else {
            newEvent.startTime = self.currentRecording.started;
        }

        if (!CGSizeEqualToSize(image.size, self.currentRecording.recordingSize) ) {
            image = [self imageWithImage:image scaledToSize:self.currentRecording.recordingSize];
        }
        
        NSString *imageName = [NSString stringWithFormat:@"%@%f.%@", EventPrefix, [newEvent.startTime timeIntervalSince1970], ImageExtension];
        NSData *data=UIImagePNGRepresentation(image);
        newEvent.imageURL = imageName;
        NSString *imagePath = [[self localPathForRecording:self.currentRecording] stringByAppendingPathComponent:imageName];
        [data writeToFile:imagePath atomically:NO];
        
        if (videoPath) {
            newEvent.videoURL = videoPath;
        }

        [self.currentRecording addProRecordingEvent:newEvent];
        self.currentEvent = newEvent;
    }
}

- (void)makeVideo:(PRORecording *)recording completion:(void(^)(BOOL success))completion {
    if ([self.delegate respondsToSelector:@selector(videoBuildProgress:)]) {
        [self.delegate videoBuildProgress:0.0];
    }
    [self makeVideoFromRecording:recording completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
            if ([self.delegate respondsToSelector:@selector(videoFinished)]) {
                [self.delegate videoFinished];
            }
        });

    }];
}

- (void)saveRecording:(PRORecording *)recording {
    NSString *recordingPath = [[self localPathForRecording:recording] stringByAppendingPathComponent:RecordingDataFilename];
    NSDictionary *recordingDictionary = [recording asHash];

    if ([[NSFileManager defaultManager] fileExistsAtPath:recordingPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:recordingPath error:nil];
    }
    if (![recordingDictionary writeToFile:recordingPath atomically:NO]) {
        MCTAlertView * errorAlertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving recording.", nil) message:NSLocalizedString(@"The recording was not saved.", nil) cancelButtonTitle:NSLocalizedString(@"OK", nil)];
        [errorAlertView show];
    }
}

- (void)loadAllRecordings {
    NSURL *recordingsURL = [NSURL fileURLWithPath:[self recordingDirectory]];
    NSArray *recordingsFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:recordingsURL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:FilterPredecate];
    for (NSURL *directoryURL in [recordingsFolders filteredArrayUsingPredicate:predicate]) {
        NSURL *fileURL = [directoryURL URLByAppendingPathComponent:RecordingDataFilename];
        NSDictionary *recordingDictionary = [NSDictionary dictionaryWithContentsOfURL:fileURL];
        if (recordingDictionary) {
            BOOL found = NO;
            NSString *recordingFolder = [[directoryURL relativePath] lastPathComponent];
            for (PRORecording *loadedRecording in self.allRecordings) {
                if ([loadedRecording.localPath isEqualToString:recordingFolder]) {
                    found = YES;
                    break;
                }
            }
            if (!found) {
                PRORecording *newRecording = [PRORecording recordingFromDictionary:recordingDictionary];
                if (newRecording) {
                    [self addRecording:newRecording];
                }
            }
        }
    }
}

#pragma mark -
#pragma mark - Camera Image Capture Methods

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (controller == nil)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = @[(NSString *) kUTTypeImage];
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        [self addNewPROEventType:PRORecordingEventTypeImage image:imageToSave videoPath:nil];
    }
    [picker dismissViewControllerAnimated:YES completion:^{        
    }];
}

#pragma mark -
#pragma mark - PRORecordingVideoBuilderDelegate Methods

- (void)videoBuildProgress:(CGFloat)progress {
    if ([self.delegate respondsToSelector:@selector(videoBuildProgress:)]) {
        [self.delegate videoBuildProgress:progress];
    }
}

- (void)audioMixProgress:(CGFloat)progress {
    if ([self.delegate respondsToSelector:@selector(audioMixProgress:)]) {
        [self.delegate audioMixProgress:progress];
    }
}

- (void)videoMixProgress:(CGFloat)progress {
    if ([self.delegate respondsToSelector:@selector(videoMixProgress:)]) {
        [self.delegate videoMixProgress:progress];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -
#pragma mark - AVAudioRecorderDelegate Methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    PCOLogDebug(@"audioRecorderDidFinishRecording");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    PCOLogDebug(@"audioRecorderEncodeErrorDidOccur");
}

#pragma mark -
#pragma mark - Video Creation Methods

- (void)makeVideoFromRecording:(PRORecording *)recording completion:(void(^)(BOOL success))completion{
    _videoBuilder = nil;
    self.videoBuilder = [[PRORecordingVideoBuilder alloc] initWithRecording:recording];
    
    if (self.videoBuilder) {
        self.videoBuilder.delegate = self;
        if ([recording recordingLengthInSeconds] < 60 * 5) {
            [PCOEventLogger logEvent:@"Recorder - Making Video, < 5 min."];
        }
        else if ([recording recordingLengthInSeconds] < 60 * 15){
            [PCOEventLogger logEvent:@"Recorder - Making Video, 5 to 15 min."];
        }
        else if ([recording recordingLengthInSeconds] < 60 * 30){
            [PCOEventLogger logEvent:@"Recorder - Making Video, 15 to 30 min."];
        }
        else if ([recording recordingLengthInSeconds] < 60 * 60){
            [PCOEventLogger logEvent:@"Recorder - Making Video, 30 to 60 min."];
        }
        else{
            [PCOEventLogger logEvent:@"Recorder - Making Video > 60 min."];
        }
        [self.videoBuilder buildVideoWithCompletion:^(NSURL *fileURL) {
            // if no fileURL then it failed
            if (fileURL) {
                // We have a video so lets mix in the audio
                NSString *audioRecorderFilePath = [[self localPathForRecording:recording] stringByAppendingPathComponent:AudioFilename];
                NSURL *audioURL = [NSURL fileURLWithPath:audioRecorderFilePath];
                NSString *videoFilePath = [[self localPathForRecording:recording] stringByAppendingPathComponent:recording.videoFileLocalPath];
                NSURL *videoURL = [NSURL fileURLWithPath:videoFilePath];
                [self.videoBuilder mixAudioAtURL:audioURL toTempVideoAtURL:fileURL writeToVideoURL:videoURL completion:^(BOOL success) {
                    completion(success);
                }];
            }
            else {
                completion(NO);
            }
        }];
    }
    else {
        PCOLogDebug(@"Could not create a video builder.");
    }
}



@end
