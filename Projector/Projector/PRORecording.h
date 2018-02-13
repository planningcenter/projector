//
//  PRORecording.h
//  Projector
//
//  Created by Peter Fokos on 4/14/15.
//

#import <Foundation/Foundation.h>

@class PRORecordingEvent;

@interface PRORecording : NSObject

@property (strong, nonatomic) NSDate *started;
@property (strong, nonatomic) NSDate *stopped;

@property (strong, nonatomic) NSNumber *planId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *moreInfo;
@property (strong, nonatomic) NSString *localPath;
@property (strong, nonatomic) NSString *videoFileLocalPath;

@property (strong, nonatomic) NSArray *events;

@property (strong, nonatomic) NSArray *segments;

@property (nonatomic) CGSize recordingSize;

- (void)addProRecordingEvent:(PRORecordingEvent *)recordingEvent;
- (CGFloat)recordingLengthInSeconds;
- (NSInteger)indexOfEventAtRecordingTime:(CGFloat)recordingTime;

- (NSDictionary *)asHash;

+ (PRORecording *)recordingFromDictionary:(NSDictionary *)dictionary;

@end

@interface PRORecordingSegment : NSObject

@property (nonatomic) NSInteger startIndex;
@property (nonatomic) NSInteger endIndex;

+ (id)segmentWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

@end

