/*!
 * PROLogoDisplayItem.h
 *
 *
 * Created by Skylar Schipper on 7/8/14
 */

#ifndef PROLogoDisplayItem_h
#define PROLogoDisplayItem_h

#import "PRODisplayItem.h"
#import "PROLogo.h"

@interface PROLogoDisplayItem : PRODisplayItem

@property (nonatomic, strong, readonly) PROLogo *logo;

- (instancetype)initWithLogo:(PROLogo *)logo;

@end

PCO_EXTERN NSInteger const PROLogoDisplayItemSectionIndex;

#endif
