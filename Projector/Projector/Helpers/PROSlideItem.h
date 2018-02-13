/*!
 * PROSlideItem.h
 *
 *
 * Created by Skylar Schipper on 7/22/14
 */

#ifndef PROSlideItem_h
#define PROSlideItem_h

@import Foundation;

@class PROSlideManager;

#import "PROSlide.h"

@interface PROSlideItem : NSObject

@property (nonatomic, strong, readonly) NSString *copyrightInfo;

- (instancetype)initWithItem:(PCOItem *)item manager:(PROSlideManager *)manager;

- (PROSlide *)slideForRow:(NSInteger)row;

- (NSInteger)count;

- (BOOL)isHeader;

+ (NSUInteger)numberOfLinesPerSlideForItem:(PCOItem *)item;

@end

#endif
