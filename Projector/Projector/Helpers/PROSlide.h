/*!
 * PROSlide.h
 *
 *
 * Created by Skylar Schipper on 7/22/14
 */

#ifndef PROSlide_h
#define PROSlide_h

@import Foundation;

@class PROThumbnailView;
@class PROSlideLayout;
@class PROSlideData;

@interface PROSlide : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *label;

@property (nonatomic, readonly) NSInteger slideIndex;

// Need this orderPosition which comes from PROCustomSlide object
// since there can be more than one PROSlide per PROCustomSlide
// and we need to index into the custom slides array using
// the order position.
@property (nonatomic, readonly) NSInteger orderPosition;

@property (nonatomic, strong, readonly) NSManagedObjectID *itemID;

@property (nonatomic) UIViewContentMode contentMode;

@property (nonatomic, strong) NSError *error;

@property (nonatomic, getter = doesContinueFromPrevious) BOOL continueFromPrevious;
@property (nonatomic, getter = shouldPerformCustomWrap) BOOL performCustomWrap;

@property (nonatomic, strong, readonly) PROSlideLayout *textLayout;
@property (nonatomic, strong, readonly) PROSlideLayout *titleLayout;
@property (nonatomic, strong, readonly) PROSlideLayout *infoLayout;

@property (nonatomic, strong) NSString *copyright;

- (instancetype)initWithItem:(PCOItem *)item slide:(PROSlideData *)slide textLayout:(PROSlideLayout *)textLayout titleLayout:(PROSlideLayout *)titleLayout infoLayout:(PROSlideLayout *)infoLayout slideIndex:(NSInteger)slideIndex;

- (UIView *)thumbnailView;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) NSURL *backgroundFileURL;
@property (nonatomic, strong) NSURL *backgroundThumbnailURL;

@property (nonatomic, strong) NSNumber *serviceTypeID;

+ (void)flushImageMemCache;

@end

#endif
