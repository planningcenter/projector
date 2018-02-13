/*!
 * PROSlideManager.h
 *
 *
 * Created by Skylar Schipper on 7/22/14
 */

#ifndef PROSlideManager_h
#define PROSlideManager_h

@import Foundation;

#import "PROSlideItem.h"

@interface PROSlideManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) PCOPlan *plan;

- (void)addMediaAttachment:(PCOAttachment *)attachment toItem:(PCOItem *)item;
- (UIImage *)thumbnailForMediaAttachment:(PCOAttachment *)attachment;
- (void)reloadEssentialBackgroundFiles;

- (NSArray *)sectionsUsingAttachmentId:(NSString *)attachmentId;
- (NSArray *)pptSectionsUsingAttachmentId:(NSString *)attachmentId;

#pragma mark -
#pragma mark - Slide Cache
- (PROSlideItem *)slideItemForSection:(NSInteger)section;
- (PROSlide *)slideForIndexPath:(NSIndexPath *)indexPath;

#pragma mark -
#pragma mark - Caching
- (void)emptyCache;
- (void)emptyCacheSection:(NSInteger)section;
- (void)emptyCacheOfItem:(PCOItem *)item;

- (NSURL *)URLForAttachmentFile:(NSString *)fileName cacheKey:(NSString *)cacheKey;
- (NSURL *)URLForAttachmentFileThumbnail:(NSString *)cacheKey;

@end

PCO_EXTERN_STRING PROSlideManagerDidFinishPlanGenerationNotification;
PCO_EXTERN_STRING PROSlideManagerDidFlushCacheNotification;
PCO_EXTERN_STRING PROSlideManagerDidFlushCacheSectionNotification;

#endif
