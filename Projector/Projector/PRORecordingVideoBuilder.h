//
//  PRORecordingVideoBuilder.h
//  Projector
//
//  Created by Peter Fokos on 5/11/15.
//

#import <Foundation/Foundation.h>


@class PRORecording;


@protocol PRORecordingVideoBuilderDelegate <NSObject>
@optional
- (void)videoBuildProgress:(CGFloat)progress;
- (void)videoMixProgress:(CGFloat)progress;
- (void)audioMixProgress:(CGFloat)progress;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage *)imageForRecording:(PRORecording *)recording atEventWithIndex:(NSInteger)index;
@end


@interface PRORecordingVideoBuilder : NSObject
@property (nonatomic, assign) id<PRORecordingVideoBuilderDelegate> delegate;
- (instancetype)initWithRecording:(PRORecording *)recording;
- (void)buildVideoWithCompletion:(void(^)(NSURL *fileURL))completion;
- (void)mixAudioAtURL:(NSURL *)audioURL toTempVideoAtURL:(NSURL *)tempURL writeToVideoURL:(NSURL *)videoURL completion:(void(^)(BOOL success))completion;
@end
