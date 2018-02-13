//
//  PRORecordingEvent.m
//  Projector
//
//  Created by Peter Fokos on 4/14/15.
//

#import "PRORecordingEvent.h"

static NSString * const RecordingEventTypeKey           = @"type";
static NSString * const RecordingEventStartTimeKey      = @"startTime";
static NSString * const RecordingEventStopTimeKey       = @"stopTime";
static NSString * const RecordingEventImageURLKey       = @"imageURL";
static NSString * const RecordingEventVideoURLKey       = @"videoURL";


@implementation PRORecordingEvent

- (id)init {
    self = [super init];
    if (self) {
        _startTime = [NSDate date];
        _imageURL = @"";
        _videoURL = @"";
    }
    return self;
}

- (NSDictionary *)asHash {
    NSMutableDictionary *recording  = [NSMutableDictionary dictionary];
    recording[RecordingEventTypeKey]        = PCOSafe(@(self.type));
    recording[RecordingEventStartTimeKey]   = PCOSafe(@([self.startTime timeIntervalSince1970]));
    recording[RecordingEventStopTimeKey]    = PCOSafe(@([self.stopTime timeIntervalSince1970]));
    recording[RecordingEventImageURLKey]    = PCOSafe(self.imageURL);
    recording[RecordingEventVideoURLKey]    = PCOSafe(self.videoURL);
    
    return [recording copy];
}

- (CGFloat)eventLength {
    CGFloat length = (CGFloat)[self.stopTime timeIntervalSinceDate:self.startTime];
    return length;
}

- (BOOL)isVideo {
    if (self.type == PRORecordingEventTypeVideo) {
        return YES;
    }
    return NO;
}

+ (PRORecordingEvent *)recordingEventFromDictionary:(NSDictionary *)dictionary {
    PRORecordingEvent *recordingEvent = [[PRORecordingEvent alloc] init];
    recordingEvent.type = [[dictionary objectForKey:RecordingEventTypeKey] integerValue];
    recordingEvent.startTime = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:RecordingEventStartTimeKey] doubleValue]];
    recordingEvent.stopTime = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:RecordingEventStopTimeKey] doubleValue]];
    recordingEvent.imageURL = [dictionary objectForKey:RecordingEventImageURLKey];
    recordingEvent.videoURL = [dictionary objectForKey:RecordingEventVideoURLKey];
    return recordingEvent;
}

@end
