/*!
 * PROSlideHelper.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/19/14
 */

#ifndef Projector_PROSlideHelper_h
#define Projector_PROSlideHelper_h

@import Foundation;

@class PCOCustomSlide;

@interface PROSlideHelper : NSObject

// MARK: - Custom Slide Server Methods
+ (void)saveCustomSlide:(PCOCustomSlide *)slide itemID:(NSNumber *)itemID completion:(void(^)(NSError *error))completion;

+ (void)deleteCustomSlide:(NSNumber *)slideID itemID:(NSNumber *)itemID completion:(void(^)(NSError *error))completion;

+ (void)saveCustomSlideOrder:(PCOItem *)item completion:(void(^)(NSError *error))completion;

// MARK: - Chord Chart
+ (void)saveChordChart:(NSString *)chordChart item:(PCOItem *)item completion:(void(^)(NSError *error))completion;

@end

PCO_EXTERN_STRING PROSlideHelperErrorDomain;

typedef NS_ENUM(NSInteger, PROSlideHelperError) {
    PROSlideHelperErrorGeneral  = 1,
    PROSlideHelperErrorBadParam = 2,
    PROSlideHelperErrorCoreData = 3
};

#endif
