//
//  PRORecording.m
//  Projector
//
//  Created by Peter Fokos on 4/14/15.
//

#import "PRORecording.h"
#import "PRORecordingEvent.h"

static NSString * const RecordingStartedKey             = @"recordingDate";
static NSString * const RecordingStoppedKey             = @"stoppedDate";
static NSString * const RecordingPlanIdKey              = @"plan_id";
static NSString * const RecordingTitleKey               = @"title";
static NSString * const RecordingMoreInfoKey            = @"moreInfo";
static NSString * const RecordingLocalPathKey           = @"localPath";
static NSString * const RecordingVideoFileLocalPathKey  = @"videoLocalPath";
static NSString * const RecordingEventsKey              = @"events";
static NSString * const RecordingSizeWidthKey           = @"sizeWidth";
static NSString * const RecordingSizeHeightKey           = @"sizeHeight";

@implementation PRORecording

+ (PRORecording *)recordingFromDictionary:(NSDictionary *)dictionary {
    PRORecording *recording = [[PRORecording alloc] init];
    recording.started = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:RecordingStartedKey] doubleValue]];
    recording.stopped = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:RecordingStoppedKey] doubleValue]];
    recording.planId = [dictionary objectForKey:RecordingPlanIdKey];
    recording.title = [dictionary objectForKey:RecordingTitleKey];
    recording.moreInfo = [dictionary objectForKey:RecordingMoreInfoKey];
    recording.localPath = [dictionary objectForKey:RecordingLocalPathKey];
    recording.videoFileLocalPath = [dictionary objectForKey:RecordingVideoFileLocalPathKey];
    CGSize videoSize = CGSizeZero;
    videoSize.width = [[dictionary objectForKey:RecordingSizeWidthKey] floatValue];
    videoSize.height = [[dictionary objectForKey:RecordingSizeHeightKey] floatValue];
    recording.recordingSize = videoSize;
    
    NSArray *events = [dictionary objectForKey:RecordingEventsKey];

    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[events count]];
    
    for (NSDictionary *dict in events) {
        PRORecordingEvent *event = [PRORecordingEvent recordingEventFromDictionary:dict];
        [array addObject:event];
    }
    recording.events = [NSArray arrayWithArray:array];
    return recording;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *)events {
    if (!_events) {
        NSArray *array = [[NSArray alloc] init];
        _events = array;
    }
    return _events;
}

- (void)addProRecordingEvent:(PRORecordingEvent *)recordingEvent {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.events];
    [array addObject:recordingEvent];
    self.events = [NSArray arrayWithArray:array];
}

- (CGFloat)recordingLengthInSeconds {
    NSTimeInterval length = [self.stopped timeIntervalSinceDate:self.started];
    return (CGFloat)length;
}

- (NSInteger)indexOfEventAtRecordingTime:(CGFloat)recordingTime {
    for (PRORecordingEvent *event in self.events) {
        CGFloat startTime = (CGFloat)[event.startTime timeIntervalSinceDate:self.started];
        CGFloat endTime = (CGFloat)[event.stopTime timeIntervalSinceDate:self.started];
        if (recordingTime >= startTime && recordingTime <= endTime) {
            return [self.events indexOfObject:event];
        }
    }
    return NSNotFound;
}

- (NSDictionary *)asHash {
    NSMutableDictionary *recording  = [NSMutableDictionary dictionary];
    recording[RecordingStartedKey]              = PCOSafe(@([self.started timeIntervalSince1970]));
    recording[RecordingStoppedKey]              = PCOSafe(@([self.stopped timeIntervalSince1970]));
    recording[RecordingPlanIdKey]               = PCOSafe(self.planId);
    recording[RecordingTitleKey]                = PCOSafe(self.title);
    recording[RecordingMoreInfoKey]             = PCOSafe(self.moreInfo);
    recording[RecordingLocalPathKey]            = PCOSafe(self.localPath);
    recording[RecordingVideoFileLocalPathKey]   = PCOSafe(self.videoFileLocalPath);
    recording[RecordingSizeWidthKey]            = PCOSafe(@(self.recordingSize.width));
    recording[RecordingSizeHeightKey]           = PCOSafe(@(self.recordingSize.height));
    
    recording[RecordingEventsKey] = [self.events collectSafe:^id(PRORecordingEvent *object) {
        return [object asHash];
    }];
    
    return [recording copy];
}

- (NSArray *)segments {
    if (!_segments) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        NSInteger startIndex = 0;
        NSInteger endIndex = 0;
        for (PRORecordingEvent *event in self.events) {
            if ([event isVideo]) {
                if (startIndex < endIndex) {
                    PRORecordingSegment *imageSegment = [PRORecordingSegment segmentWithStartIndex:startIndex endIndex:endIndex - 1];
                    [array addObject:imageSegment];
                    
                    PRORecordingSegment *videoSegment = [PRORecordingSegment segmentWithStartIndex:endIndex endIndex:endIndex];
                    [array addObject:videoSegment];
                }
                else {
                    PRORecordingSegment *imageSegment = [PRORecordingSegment segmentWithStartIndex:startIndex endIndex:endIndex];
                    [array addObject:imageSegment];
                }
                startIndex = endIndex + 1;
            }
            else if (endIndex == (NSInteger)[self.events count] - 1) {
                PRORecordingSegment *imageSegment = [PRORecordingSegment segmentWithStartIndex:startIndex endIndex:endIndex];
                [array addObject:imageSegment];
            }
            endIndex ++;
        }
        _segments = [NSArray arrayWithArray:array];
    }
    return _segments;
}
@end

@implementation PRORecordingSegment

+ (id)segmentWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex {
    PRORecordingSegment *segment = [[PRORecordingSegment alloc] init];
    segment.startIndex = startIndex;
    segment.endIndex = endIndex;
    return segment;
}

@end

