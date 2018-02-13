//
//  PRORecordingVideoBuilder.m
//  Projector
//
//  Created by Peter Fokos on 5/11/15.
//

#import "PRORecordingVideoBuilder.h"
#import "PRORecording.h"
#import "PRORecordingEvent.h"
@import AVFoundation;

#define FRAMES_PER_SECOND 30


static NSString * const VideoBuilderTempFolder      = @"PROVideoBuilder";
static NSString * const VideoBuilderTempFilename    = @"PROVideo.mp4";
static NSString * const VideoBuilderMixedTempFilename    = @"PROMixedVideo.mp4";


@interface PRORecordingVideoBuilder ()

@property (nonatomic, strong) PRORecording *recording;
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, strong) NSURL *mixedOutputURL;
@property (nonatomic, strong) NSString *outputFileType;

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *writerInput;
@property (nonatomic, strong) NSDictionary *outputSettings;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;

@property (nonatomic, strong) AVAssetExportSession* assetExportSession;
@property (nonatomic, strong) CADisplayLink *timer;

@end

@implementation PRORecordingVideoBuilder

- (instancetype)initWithRecording:(PRORecording *)recording {
    self = [super init];
    if (self) {
        _recording = recording;
        
        self.videoSize = [recording recordingSize];
        if ((int)self.videoSize.width % 16 != 0 ) {
            PCOLogDebug(@"The video width must be divisible by 16.");
        }
        
        self.outputFileType = AVFileTypeMPEG4;
        
        NSError *error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.outputURL path]]) {
            [[NSFileManager defaultManager] removeItemAtURL:self.outputURL error:&error];
            if (error) {
                PCOLogDebug(@"outputURL Error: %@", error.debugDescription);
                return nil;
            }
        }

    }
    return self;
}

- (BOOL)recordingHasVideoEvents {
    for (PRORecordingEvent *event in [self.recording events]) {
        if ([event isVideo]) {
            return YES;
        }
    }
    return NO;
}

- (void)buildVideoWithCompletion:(void(^)(NSURL *fileURL))completion {
    if ([self.assetWriter canAddInput:self.writerInput]) {
        [self.assetWriter addInput:self.writerInput];
        if (!self.pixelBufferAdaptor) {
            return;
        }
        [self.assetWriter startWriting];
        [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
        
        dispatch_queue_t buildQueue = dispatch_queue_create("com.ministrycentered.videobuilder", NULL);
        
        [self.writerInput requestMediaDataWhenReadyOnQueue:buildQueue usingBlock:^{
            NSUInteger eventIndex = 0;
            do {
                if ([self.writerInput isReadyForMoreMediaData]) {
                    PRORecordingEvent *thisEvent = [self.recording.events objectAtIndex:eventIndex];
                    UIImage *eventImage = [self.delegate imageForRecording:self.recording atEventWithIndex:eventIndex];
                    if (!CGSizeEqualToSize(self.videoSize, eventImage.size)) {
                        eventImage = [self.delegate imageWithImage:eventImage scaledToSize:self.videoSize];
                    }
                    CVPixelBufferRef pixelBuffer = [self makePixelBufferFromCGImage:[eventImage CGImage]];
                    if (pixelBuffer) {
                        BOOL result = NO;
                        if (eventIndex == 0) {
                            result = [self.pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:kCMTimeZero];
                        }
                        else {
                            PRORecordingEvent *firstEvent = [self.recording.events objectAtIndex:0];
                            NSTimeInterval secondsSinceStart = [thisEvent.startTime timeIntervalSinceDate:firstEvent.startTime];
                            CMTime eventTime = CMTimeMakeWithSeconds(secondsSinceStart, 30);
                            result = [self.pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:eventTime];
                        }
                        CFRelease(pixelBuffer);
                        eventIndex++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([self.delegate respondsToSelector:@selector(videoBuildProgress:)]) {
                                CGFloat progress = (CGFloat)eventIndex / (CGFloat)[self.recording.events count];
                                [self.delegate videoBuildProgress:progress];
                            }
                        });
                    }
                }
            } while (eventIndex < [self.recording.events count]);
            [self.writerInput markAsFinished];
            
            [self.assetWriter finishWritingWithCompletionHandler:^{
                if ([self.assetWriter status] == AVAssetWriterStatusCompleted) {
                    
                    // Here I need to either go mix the audio into the resulting file or
                    // if there were videos to composite I need to alternate showing the full
                    // video or the video sections at the correct time. So I need to keep a constant timeline
                    // and use it as the start point for each transition.
                    
                    if (![self recordingHasVideoEvents]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(self.outputURL);
                        });
                    }
                    else {
                        [self mixVideosOverBaseVideo:self.outputURL completion:^(NSURL *fileURL) {
                            completion(fileURL);
                        }];
                    }
                }
                else {
                    // there was an error so no need to go further
                    dispatch_async(dispatch_get_main_queue(), ^{
                        PCOLogDebug(@"finishWritingWithCompletionHandler error: %ld, %@", (long)self.assetWriter.status, [self.assetWriter.error localizedDescription]);
                        MCTAlertView * errorAlertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Error creating video file.", nil) message:[self.assetWriter.error localizedDescription] cancelButtonTitle:NSLocalizedString(@"OK", nil)];
                        [errorAlertView show];
                        completion(nil);
                    });
                }
            }];
            CVPixelBufferPoolRelease(self.pixelBufferAdaptor.pixelBufferPool);
        }];
    }
}

- (CVPixelBufferRef)makePixelBufferFromCGImage:(CGImageRef)image
{
    NSDictionary *pixelBufferAttributes = @{
                                            (id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                                            (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES
                                            };
    
    CVPixelBufferRef pixelbuffer = NULL;
    
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          self.videoSize.width,
                                          self.videoSize.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) pixelBufferAttributes,
                                          &pixelbuffer);
    
    if (result != kCVReturnSuccess || pixelbuffer == NULL) {
        PCOLogDebug(@"makePixelBufferFromCGImage error: %d", result);
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelbuffer, 0);
    void *pixelData = CVPixelBufferGetBaseAddress(pixelbuffer);

    if (pixelData == NULL) {
        PCOLogDebug(@"CVPixelBufferGetBaseAddress is NULL");
        return NULL;
    }
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 self.videoSize.width,
                                                 self.videoSize.height,
                                                 8,
                                                 4 * self.videoSize.width,
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    if (!context) {
        PCOLogDebug(@"CGBitmapContextCreate nil");
        return NULL;
    }
    
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pixelbuffer, 0);
    
    return pixelbuffer;
}

#pragma mark -
#pragma mark - Lazy Loaders

- (AVAssetWriter *)assetWriter {
    if (!_assetWriter) {
        NSError *error;
        AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:self.outputURL fileType:self.outputFileType error:&error];
        _assetWriter = writer;
        if (error) {
            PCOLogDebug(@"AVAssetWriter Error: %@", error.debugDescription);
        }
    }
    return _assetWriter;
}

- (AVAssetWriterInput *)writerInput {
    if (!_writerInput) {
        AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.outputSettings];
        _writerInput = input;
    }
    return _writerInput;
}

- (NSDictionary *)outputSettings {
    if (!_outputSettings) {
        _outputSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                            AVVideoWidthKey: @((int)self.videoSize.width),
                            AVVideoHeightKey: @((int)self.videoSize.height)
                            };
    }
    return _outputSettings;
}

- (NSURL *)outputURL {
    if (!_outputURL) {
        NSURL *url = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        url = [url URLByAppendingPathComponent:VideoBuilderTempFolder isDirectory:YES];
        if (![url checkResourceIsReachableAndReturnError:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
        }
        url = [url URLByAppendingPathComponent:VideoBuilderTempFilename isDirectory:NO];
        _outputURL = url;
    }
    return _outputURL;
}

- (NSURL *)mixedOutputURL {
    if (!_mixedOutputURL) {
        NSURL *url = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        url = [url URLByAppendingPathComponent:VideoBuilderTempFolder isDirectory:YES];
        if (![url checkResourceIsReachableAndReturnError:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
        }
        url = [url URLByAppendingPathComponent:VideoBuilderMixedTempFilename isDirectory:NO];
        _mixedOutputURL = url;
    }
    return _mixedOutputURL;
}

- (AVAssetWriterInputPixelBufferAdaptor *)pixelBufferAdaptor {
    if (!_pixelBufferAdaptor) {
        NSDictionary *attributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB)};
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.writerInput sourcePixelBufferAttributes:attributes];
        _pixelBufferAdaptor = adaptor;
    }
    return _pixelBufferAdaptor;
}

#pragma mark -
#pragma mark - Audio Mixing

- (void)mixAudioAtURL:(NSURL *)audioURL toTempVideoAtURL:(NSURL *)tempURL writeToVideoURL:(NSURL *)videoURL completion:(void(^)(BOOL success))completion {
  AVMutableComposition* mixComposition = [AVMutableComposition composition];
        
    if ([[NSFileManager defaultManager] fileExistsAtPath:[videoURL relativePath]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[videoURL relativePath] error:nil];
    }
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:tempURL options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0) {
        [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:tracks[0] atTime:nextClipStartTime error:nil];
        
        //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
        
        AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audioURL options:nil];
        CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
        AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        if ([[audioAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
            [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
        }
        
        _assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
        self.assetExportSession.outputFileType = self.outputFileType;
        self.assetExportSession.outputURL = videoURL;
        
        // set a timer and look at the [_assetExport progress] for the current progress
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopProgressTimer];
            self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkAudioMixProgress)];
            self.timer.frameInterval = 60/FRAMES_PER_SECOND;
            [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        });
        
        [_assetExportSession exportAsynchronouslyWithCompletionHandler:^(void ) {
            [self stopProgressTimer];
            if ([self.assetExportSession status] == AVAssetExportSessionStatusCompleted) {
                completion(YES);
            }
            else {
                PCOLogDebug(@"mixAudioAtURL error: %ld, %@", (long)self.assetExportSession.status, [self.assetExportSession.error localizedDescription]);
                MCTAlertView * errorAlertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Error creating final video file.", nil) message:[self.assetWriter.error localizedDescription] cancelButtonTitle:NSLocalizedString(@"OK", nil)];
                [errorAlertView show];
                completion(NO);
            }
        }];
    }
    else {
        PCOLogDebug(@"No video track found.");
    }
}

- (void)checkAudioMixProgress {
    if (self.assetExportSession.status == AVAssetExportSessionStatusExporting) {
        CGFloat progress = [self.assetExportSession progress];
        if ([self.delegate respondsToSelector:@selector(audioMixProgress:)]) {
            [self.delegate audioMixProgress:progress];
        }
    }
    else {
        [self stopProgressTimer];
    }
}

- (void)checkVideoMixProgress {
    CGFloat progress = [self.assetExportSession progress];
    if ([self.delegate respondsToSelector:@selector(videoMixProgress:)]) {
        [self.delegate videoMixProgress:progress];
    }
}

- (void)stopProgressTimer {
    if (_timer) {
        [self.timer invalidate];
        _timer = nil;
    }
}

#pragma mark -
#pragma mark - Video Mixing

- (void)mixVideosOverBaseVideo:(NSURL *)baseURL completion:(void(^)(NSURL *fileURL))completion {
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.mixedOutputURL relativePath]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self.mixedOutputURL relativePath] error:nil];
    }
    
    CMTime segmentStartTime = kCMTimeZero;
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* baseVideoAsset = [[AVURLAsset alloc]initWithURL:baseURL options:nil];
    
    CMTimeRange segment_timeRange;

    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSArray *baseVideoAssetTracks = [baseVideoAsset tracksWithMediaType:AVMediaTypeVideo];
    if ([baseVideoAssetTracks count] > 0) {

        for (PRORecordingEvent *event in [self.recording events]) {
            CMTime eventDuration = CMTimeMakeWithSeconds([event eventLength], 30);
            
            if ([event isVideo]) {
                // need to insert the base video track up to this point unless we are at kCMTimeZero
                
                if (CMTimeCompare(segmentStartTime, nextClipStartTime) != 0) {
                    CMTime segmentDuration = CMTimeSubtract(nextClipStartTime, segmentStartTime);
                    segment_timeRange = CMTimeRangeMake(segmentStartTime, segmentDuration);
                    [compositionVideoTrack insertTimeRange:segment_timeRange ofTrack:baseVideoAssetTracks[0] atTime:segmentStartTime error:nil];
                }

                // now add in the new video
                NSURL *segmentURL = [NSURL URLWithString:event.videoURL];
                AVURLAsset* segmentVideoAsset = [[AVURLAsset alloc]initWithURL:segmentURL options:nil];
                NSArray *segmentVideoAssetTracks = [segmentVideoAsset tracksWithMediaType:AVMediaTypeVideo];
                if ([segmentVideoAssetTracks count] > 0) {
                    AVAssetTrack *segmentVideoTrack = segmentVideoAssetTracks[0];
                    
                    // see if the video we have is long enough
                    segment_timeRange = CMTimeRangeMake(kCMTimeZero,eventDuration);
                    
                    // is the event time longer than the track?
                    if (CMTimeCompare(eventDuration, segmentVideoTrack.timeRange.duration) == 1) {
                        segment_timeRange = CMTimeRangeMake(kCMTimeZero, segmentVideoTrack.timeRange.duration);
                        eventDuration = segmentVideoTrack.timeRange.duration;
                    }
                    [compositionVideoTrack insertTimeRange:segment_timeRange ofTrack:segmentVideoTrack atTime:nextClipStartTime error:nil];
                }
                segmentStartTime = CMTimeAdd(nextClipStartTime, eventDuration);
            }
            nextClipStartTime = CMTimeAdd(nextClipStartTime, eventDuration);
        }
        
        // all done looking for videos
        // should we add in the rest of the base video?
        if (CMTimeCompare(segmentStartTime, nextClipStartTime) != 0) {
            CMTime segmentDuration = CMTimeSubtract(nextClipStartTime, segmentStartTime);
            segment_timeRange = CMTimeRangeMake(segmentStartTime, segmentDuration);
            [compositionVideoTrack insertTimeRange:segment_timeRange ofTrack:baseVideoAssetTracks[0] atTime:segmentStartTime error:nil];
        }
        
        // now output the video
        
        _assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
        self.assetExportSession.outputFileType = self.outputFileType;
        self.assetExportSession.outputURL = self.mixedOutputURL;
        
        // set a timer and look at the [_assetExport progress] for the current progress
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopProgressTimer];
            self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkVideoMixProgress)];
            self.timer.frameInterval = 60/FRAMES_PER_SECOND;
            [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        });
        
        [_assetExportSession exportAsynchronouslyWithCompletionHandler:^(void ) {
            [self stopProgressTimer];
            completion(self.mixedOutputURL);
        }];

        
        
    }
    else {
        // no track so fail
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });

    }
}


@end
