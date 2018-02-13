/*!
 * PROStateSaver.h
 *
 *
 * Created by Skylar Schipper on 3/19/14
 */

#ifndef PROStateSaver_h
#define PROStateSaver_h

#import "PCOCocoaKeyValueObject.h"

@interface PROStateSaver : PCOCocoaKeyValueObject

@property (nonatomic, strong) NSNumber *lastOpenPlanID;
- (PCOPlan *)lastOpenPlan;

@property (nonatomic, strong) NSNumber *lastSidebarTabOpen;

@property (nonatomic, strong) NSNumber *addLogoSection;
@property (nonatomic, strong) NSString *currentLogoUUID;

@property (nonatomic, strong) NSNumber *sessionClientMode;
@property (nonatomic, strong) NSString *sessionType;
@property (nonatomic, strong) NSString *sessionConnectedToServerNamed;

+ (instancetype)sharedState;

- (void)flushState;

@end

#endif
