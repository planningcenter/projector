//
//  PRORecordingController.h
//  Projector
//
//  Created by Peter Fokos on 4/13/15.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PRORecordingVideoBuilder.h"

@class PCOItem, PCOPlan, PRORecording;

@protocol PRORecordingControllerDelegate <NSObject>

@optional

- (void)videoBuildProgress:(CGFloat)progress;
- (void)audioMixProgress:(CGFloat)progress;
- (void)videoMixProgress:(CGFloat)progress;
- (void)videoFinished;

@end

@interface PRORecordingController : NSObject <AVAudioPlayerDelegate, AVAudioRecorderDelegate, PRORecordingVideoBuilderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) id<PRORecordingControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *allRecordings;

@property (nonatomic) BOOL dontRecordNextEvent;

+ (instancetype)sharedController;

- (BOOL)readyToRecord;
- (BOOL)isRecording;
- (BOOL)isRecordingMovieAvailable:(PRORecording *)recording;

- (void)createNewRecording;
- (void)startRecording;
- (void)stopRecording;
- (void)cancelPendingRecording;

- (void)saveRecording:(PRORecording *)recording;

- (void)currentItemDidChange:(PRODisplayItem *)currentItem;
- (CGFloat)recordingDuration;

- (void)makeVideo:(PRORecording *)recording completion:(void(^)(BOOL success))completion;

- (void)loadAllRecordings;
- (NSURL *)urlOfLocalVideoForRecording:(PRORecording *)recording;
- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller;

- (void)deleteRecording:(PRORecording *)recording;
- (UIBarButtonItem *)recordBarButtonItem;

- (UIImage *)imageForRecording:(PRORecording *)recording atEventWithIndex:(NSInteger)index;

@end
