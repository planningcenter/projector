/*!
 * PRODisplayItem.h
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#ifndef PROCurrentItem_h
#define PROCurrentItem_h

@import Foundation;

#import "PRODisplayItemBackground.h"
#import "PROSlideLayout.h"

@class PROSlide;

@interface PRODisplayItem : NSObject

@property (nonatomic, strong) NSNumber *serviceTypeID;

@property (nonatomic, strong) NSString *titleString;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) PROSlideLayout *textLayout;

@property (nonatomic, strong) PROSlideLayout *infoLayout;

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSString *infoText;

@property (nonatomic, strong) NSString *confidenceText;

@property (nonatomic, strong) PRODisplayItemBackground *background;

@property (nonatomic, getter=shouldPerformCustomWrap) BOOL performCustomWrap;

@property (nonatomic) UIViewContentMode contentMode;

- (void)configureForSlide:(PROSlide *)slide;

@end

#endif
