/*!
 * PROSlideDataCustomSlideBuilder.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/18/14
 */

#ifndef Projector_PROSlideDataCustomSlideBuilder_h
#define Projector_PROSlideDataCustomSlideBuilder_h

@import Foundation;

@class PCOCustomSlide;

#import "PROSlideItemInfo.h"

@interface PROSlideDataCustomSlideBuilder : NSObject

+ (NSArray *)createCustomSlides:(PCOCustomSlide *)slide slideClass:(Class)klass info:(PROSlideItemInfo)info;

+ (NSArray *)createSmartLines:(NSString *)lines info:(PROSlideItemInfo)info;

+ (NSUInteger)preferredCharactersPerLineForFontSize:(CGFloat)fontSize;

// MARK: - Helpers
+ (NSArray *)createCustomSlidesWithText:(NSString *)slideText label:(NSString *)label background:(PCOAttachment *)attachment slideClass:(Class)klass info:(PROSlideItemInfo)info orderPostion:(NSInteger)orderPosition;

@end

#endif
