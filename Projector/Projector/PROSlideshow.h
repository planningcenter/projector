/*!
 * PROSlideshow.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/15/14
 */

#ifndef Projector_PROSlideshow_h
#define Projector_PROSlideshow_h

@import Foundation;

typedef NS_ENUM(NSUInteger, PROSlideshowStatus) {
    PROSlideshowStatusUnknown     = 0,
    PROSlideshowStatusConverting  = 1,
    PROSlideshowStatusReady       = 2,
    PROSlideshowStatusDownloading = 3,
    PROSlideshowStatusError       = 4
};

@class PROSlideshowSlide;

@interface PROSlideshow : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *attachmentID;
@property (nonatomic, assign, readonly) PROSlideshowStatus status;
@property (nonatomic, strong, readonly) NSNumber *fileSize;
@property (nonatomic, strong, readonly) NSDate *createdAt;

@property (nonatomic, strong) NSString *localizedName;

- (NSUInteger)slideCount;

+ (instancetype)slideshowWithAttachmentID:(NSString *)attachmentID;

- (void)updateServerStatusWithCompletion:(void(^)(NSError *))completion;
- (void)fetchMissingSlidesWithCompletion:(void(^)(NSError *))completion;
- (void)generateMissingSlideThumbnails:(void(^)(NSError *))completion;

+ (BOOL)save;
+ (BOOL)load;

+ (NSArray *)allSlideshows;

- (PROSlideshowSlide *)slideAtIndex:(NSInteger)index;

- (BOOL)deleteSlideshow:(NSError **)error;

@end


@interface PROSlideshowSlide : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *thumbnailPath;

@end

FOUNDATION_EXTERN
NSString *const PROSlideshowChangeNotification;

FOUNDATION_EXTERN
NSString *const PROSlideshowStatusChangedNotification;

#endif
