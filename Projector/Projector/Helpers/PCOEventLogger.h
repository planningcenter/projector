//
//  PCOEventLogger.h
//  Projector
//
//  Created by Peter Fokos on 11/24/14.
//

#import <Foundation/Foundation.h>

@interface PCOEventLogger : NSObject

+ (void)setup;

+ (void)logEvent:(NSString *)eventName;
+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;

+ (void)logEvent:(NSString *)eventName timed:(BOOL)timed;
+ (void)logEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters timed:(BOOL)timed;
+ (void)endTimedEvent:(NSString *)eventName withParameters:(NSDictionary *)parameters;

@end
