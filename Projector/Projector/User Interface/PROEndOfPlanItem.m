//
//  PROEndOfPlanItem.m
//  Projector
//
//  Created by Peter Fokos on 8/4/14.
//

#import "PROEndOfPlanItem.h"

@implementation PROEndOfPlanItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.background.forceBackgroundRefresh = YES;
    }
    return self;
}

- (NSString *)titleString {
    return NSLocalizedString(@"End of Plan", nil);
}

@end
