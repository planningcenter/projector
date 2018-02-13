/*!
 * PROBlackItem.m
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#import "PROBlackItem.h"

@interface PROBlackItem ()

@end

@implementation PROBlackItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.background.forceBackgroundRefresh = YES;
    }
    return self;
}
- (NSIndexPath *)indexPath {
    return nil;
}
- (NSString *)titleString {
    return NSLocalizedString(@"Black", nil);
}

@end
