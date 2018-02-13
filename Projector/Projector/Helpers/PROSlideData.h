/*!
 * PROSlideData.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/18/14
 */

#ifndef Projector_PROSlideData_h
#define Projector_PROSlideData_h

@import Foundation;
@class PROSlideStanzaProvider;

#import "PROSlideItemInfo.h"

@interface PROSlideData : NSObject <NSCopying>

@property (nonatomic, getter=continuesFromPrevious) BOOL continueFromPrevious;

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSInteger orderPosition;

@property (nonatomic, assign, readonly, getter=isMultiBackground) BOOL multiBackground;

+ (NSArray *)slidesWithItem:(PCOItem *)item stanzaProvider:(PROSlideStanzaProvider *)provider info:(PROSlideItemInfo)info;

@property (nonatomic, strong) NSURL *slideBackgroundFileURL;
@property (nonatomic, strong) NSURL *slideBackgroundFileThumbnailURL;

@end

#endif
