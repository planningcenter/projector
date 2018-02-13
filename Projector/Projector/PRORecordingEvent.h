//
//  PRORecordingEvent.h
//  Projector
//
//  Created by Peter Fokos on 4/14/15.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PRORecordingEventType) {
    PRORecordingEventTypeImage      = 0,
    PRORecordingEventTypeVideo      = 1,
};

@interface PRORecordingEvent : NSObject

@property (nonatomic) PRORecordingEventType type;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *stopTime;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *videoURL;

- (NSDictionary *)asHash;
- (CGFloat)eventLength;
- (BOOL)isVideo;

+ (PRORecordingEvent *)recordingEventFromDictionary:(NSDictionary *)dictionary;

@end
