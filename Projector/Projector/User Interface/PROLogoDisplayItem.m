/*!
 * PROLogoDisplayItem.m
 *
 *
 * Created by Skylar Schipper on 7/8/14
 */

#import "PROLogoDisplayItem.h"

@interface PROLogoDisplayItem ()

@property (nonatomic, strong, readwrite) PROLogo *logo;

@end

@implementation PROLogoDisplayItem

- (instancetype)initWithLogo:(PROLogo *)logo {
    self = [super init];
    if (self) {
        self.logo = logo;
        self.background.forceBackgroundRefresh = YES;
    }
    return self;
}
- (NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:0 inSection:PROLogoDisplayItemSectionIndex];
}
- (NSString *)titleString {
    return NSLocalizedString(@"Logo", nil);
}

- (void)setLogo:(PROLogo *)logo {
    _logo = logo;
    self.background.primaryBackgroundURL = [logo fileURL];
    self.background.staticBackgroundURL = [logo fileThumbnailURL];
}

@end

NSInteger const PROLogoDisplayItemSectionIndex = NSIntegerMax;
