/*!
 * PROSlideManager.m
 *
 *
 * Created by Skylar Schipper on 7/22/14
 */

#import <MCTFileDownloader/MCTFileDownloader.h>

#import "PROSlideManager.h"
#import "PCOAttachment.h"
#import "PCOPlanItemMedia.h"
#import "PCOMedia.h"
#import "PCODispatchGroup.h"
#import "NSCache+PCOCocoaAdditions.h"
#import "PCOAttachment+ProjectorAdditions.h"
#import "NSString+FileTypeAdditions.h"
#import "PCOCustomSlide.h"

#import "PROSlideshow.h"

#import "MCTDataStore.h"
#import "PROThumbnailGenerator.h"

@interface PROSlideManager ()

@property (nonatomic, strong) NSCache *slideItemCache;

@end

@implementation PROSlideManager

- (void)setPlan:(PCOPlan *)plan {
    _plan = plan;
    [self emptyCache];
    [self reloadEssentialBackgroundFiles];
}

#pragma mark -
#pragma mark - Singleton
+ (instancetype)sharedManager {
    static PROSlideManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        welf();
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [welf emptyCache];
        }];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Lazy Loaders
- (NSCache *)slideItemCache {
    if (!_slideItemCache) {
        _slideItemCache = [[NSCache alloc] init];
    }
    return _slideItemCache;
}

#pragma mark -
#pragma mark - Slide Cache
- (PROSlide *)slideForIndexPath:(NSIndexPath *)indexPath {
    return [[self slideItemForSection:indexPath.section] slideForRow:indexPath.row];
}
- (PROSlideItem *)newSlideItemForSection:(NSInteger)section {
    NSArray *items = [self.plan orderedItems];
    if (![items hasObjectForIndex:section]) {
        return nil;
    }
    PCOItem *item = items[section];
    
    PROSlideItem *slideItem = [[PROSlideItem alloc] initWithItem:item manager:self];
    
    return slideItem;
}
- (PROSlideItem *)slideItemForSection:(NSInteger)section {
    return [self.slideItemCache objectForKey:[NSString stringWithFormat:@"%li",(long)section] compute:^id(id key) {
        return [self newSlideItemForSection:section];
    }];
}

#pragma mark -
#pragma mark - Caching

- (void)emptyCacheOfAttachmentID:(NSManagedObjectID *)attachmentID {
    if (attachmentID) {
        PCOAttachment *attachment = [[PCOCoreDataManager sharedManager] objectWithID:attachmentID];
        NSArray *sectionIndexes = [[PROSlideManager sharedManager] sectionsUsingAttachmentId:attachment.attachmentId];
        for (NSNumber *section in sectionIndexes) {
            [self emptyCacheSection:[section integerValue]];
        }
    }
}

- (void)emptyCacheOfItem:(PCOItem *)item {
    NSInteger section = [[self.plan orderedItems] indexOfObject:item];
    if (section != NSNotFound) {
        [self emptyCacheSection:section];
    }
}

- (void)emptyCacheSection:(NSInteger)section {
    [self.slideItemCache removeObjectForKey:[NSString stringWithFormat:@"%li",(long)section]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PROSlideManagerDidFlushCacheSectionNotification object:self userInfo:@{@"section": @(section)}];
    });
}

- (void)emptyCache {
    [self.slideItemCache removeAllObjects];
    [PROSlide flushImageMemCache];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PROSlideManagerDidFlushCacheNotification object:self];
    });
}

#pragma mark -
#pragma mark - File Download
- (void)_downloadAttachmentFile:(PCOAttachment *)attachment {
    if (![attachment isProjectorAttachment] || !attachment.url) {
        return;
    }
    
    NSManagedObjectID *objectID = [attachment objectID];
    NSString *key = [attachment fileCacheKey];
    NSString *name = [attachment filename];
    if ([[MCTDataStore sharedStore] hasFile:name key:key]) {
        [self checkAndBuildThumbnailForAttachmentID:objectID];
        return;
    }
    
    if ([attachment isSlideshow]) {
        PROSlideshow *slideshow = [PROSlideshow slideshowWithAttachmentID:attachment.attachmentId];
        [slideshow updateServerStatusWithCompletion:^(NSError *err) {
            PCOError(err);
            PCOLogDebug(@"Completed PowerPoint fetch");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self emptyCacheOfAttachmentID:objectID];
            });
        }];
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:attachment.url];
    
    PRODownloadOperation *opp = [[PRODownloadOperation alloc] initWithURL:URL];
    [opp setCompletion:^(PRODownloadOperation *operation, NSURL *location, NSError *error) {
        if (error) {
            PCOError(error);
        }
        if (location && [[NSFileManager defaultManager] fileExistsAtPath:location.path isDirectory:NULL]) {
            [[MCTDataStore sharedStore] copyFileAtURL:location name:name key:key completion:^(NSError *copyError) {
                PCOError(copyError);
                
                if (!copyError) {
                    PCOLogDebug(@"Downloaded file: %@",name);
                    NSError *backupErr = nil;
                    if (![[MCTDataStore sharedStore] setBackupEnabled:NO forFile:name key:key error:&backupErr]) {
                        NSLog(@"Failed to disabled backup: %@ -> %@",name,backupErr);
                    }
                }
                if ([[NSFileManager defaultManager] fileExistsAtPath:location.path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:location.path error:nil];
                }
                [self checkAndBuildThumbnailForAttachmentID:objectID];
            }];
        }
    }];
    
    PRODownload *download = [[PRODownload alloc] initWithOperations:@[opp]];
    download.localizedDescription = (name) ?: NSLocalizedString(@"File Attachment", nil);
    
    [[PRODownloader sharedDownloader] beginDownload:download];
}

- (void)checkAndBuildThumbnailForAttachmentID:(NSManagedObjectID *)attachmentID {
    /**
     *  I think this is the giant mess of a method that is causing the app to lock up.
     *
     ** Doing this nonsensical crap for threading fixes the issue so here it is...
     */
    NSString __block *thumbCacheKey = nil;
    NSString __block *filename = nil;
    NSString __block *cacheKey = nil;
    
    PCODispatchGroup *group = [PCODispatchGroup create];
    
    [group enter];
    dispatch_async(dispatch_get_main_queue(), ^{
        PCOAttachment *attachment = [[PCOCoreDataManager sharedManager] objectWithID:attachmentID];
        if (!attachment) {
            return;
        }
        thumbCacheKey = [attachment thumbnailCacheKey];
        filename = [attachment filename];
        cacheKey = [attachment fileCacheKey];
        [group leave];
    });
    
    [group wait:^{
        if (!thumbCacheKey || !filename || !cacheKey) {
            return;
        }
        
        if (![[MCTDataCacheController sharedCache] fileExistsForKey:thumbCacheKey]) {
            NSDictionary *file = [[MCTDataStore sharedStore] metadataForFile:filename key:cacheKey];
            if (!file) {
                return;
            }
            NSMutableDictionary *addOn = [NSMutableDictionary dictionaryWithDictionary:file];
            [addOn setObject:attachmentID forKey:@"attachmentID"];
            file = [NSDictionary dictionaryWithDictionary:addOn];
            
            if ([filename isVideo]) {
                [self makeVideoThumbnailForFile:file destinationKey:thumbCacheKey];
            }
            if ([filename isImage]) {
                [self makeImageThumbnailForFile:file destinationKey:thumbCacheKey];
            }
            if ([filename isAudio]) {
                [self notifyDidDownloadFile:attachmentID];
            }
        }
    }];
}
- (void)makeVideoThumbnailForFile:(NSDictionary *)file destinationKey:(NSString *)key {
    NSURL *URL = file[kMCTDataStoreFileURL];
    if (!URL || [PROThumbnailGenerator isGeneratingThumbnail:URL]) {
        PCOLogDebug(@"Already generating thumbnail %@",file[kMCTDataStoreName]);
        return;
    }
    NSManagedObjectID *attachmentID = [file objectForKey:@"attachmentID"];
    [PROThumbnailGenerator generateVideoThumbnailForFileAtURL:URL completion:^(NSURL *tmpLocation, NSError *error) {
        if (!error) {
            [[MCTDataCacheController sharedCache] copyFileAtURLToCache:tmpLocation fileName:key completion:^(NSURL *fileURL, NSDictionary *info, NSError *error) {
                if (!error) {
                    NSDictionary *userInfo = @{
                                               @"thumb": PCOSafe([fileURL absoluteString]),
                                               @"thumb_key": PCOSafe(key)
                                               };
                    [[MCTDataStore sharedStore] setUserInfo:userInfo forFile:file[kMCTDataStoreName] key:file[kMCTDataStoreKey]];
                    [self didGenerateThumbnailToURL:fileURL attachmentID:attachmentID];
                }
                PCOError(error);
            }];
        }
        PCOError(error);
    }];
}
- (void)makeImageThumbnailForFile:(NSDictionary *)file destinationKey:(NSString *)key {
    NSURL *URL = file[kMCTDataStoreFileURL];
    if (!URL || [PROThumbnailGenerator isGeneratingThumbnail:URL]) {
        PCOLogDebug(@"Already generating thumbnail %@",file[kMCTDataStoreName]);
        return;
    }
    __block NSManagedObjectID *attachmentID = [file objectForKey:@"attachmentID"];
    [PROThumbnailGenerator generateImageThumbnailForFileAtURL:URL completion:^(NSURL *tmpLocation, NSError *error) {
        if (!error) {
            [[MCTDataCacheController sharedCache] copyFileAtURLToCache:tmpLocation fileName:key completion:^(NSURL *fileURL, NSDictionary *info, NSError *error) {
                if (!error) {
                    NSDictionary *userInfo = @{
                                               @"thumb": PCOSafe([fileURL absoluteString]),
                                               @"thumb_key": PCOSafe(key)
                                               };
                    [[MCTDataStore sharedStore] setUserInfo:userInfo forFile:file[kMCTDataStoreName] key:file[kMCTDataStoreKey]];
                    [self didGenerateThumbnailToURL:fileURL attachmentID:attachmentID];
                }
            }];
        }
        PCOError(error);
    }];
}

- (void)didGenerateThumbnailToURL:(NSURL *)URL attachmentID:(NSManagedObjectID *)attachmentID{
    [self notifyDidDownloadFile:attachmentID];
}

- (void)notifyDidDownloadFile:(NSManagedObjectID *)attachmentID {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self emptyCacheOfAttachmentID:attachmentID];
        [[NSNotificationCenter defaultCenter] postNotificationName:PROSlideManagerDidFinishPlanGenerationNotification object:attachmentID];
    });
}

#pragma mark -
#pragma mark - Item Pickers
- (BOOL)_selectBestBackgroundAttachment:(PCOItem *)item {
    if ([item currentSelectedSlideBackgroundAttachment]) {
        return YES;
    }
    
    if ([[item customSlides] count] > 0) {
        for (PCOCustomSlide *slide in [item customSlides]) {
            if ([slide selectedBackgroundAttachment]) {
                return YES;
            }
        }
    }
    
    for (PCOPlanItemMedia *itemMedia in item.planItemMedias) {
        PCOMedia *media = itemMedia.media;
        for (PCOAttachment *attachment in [media orderedAttachments]) {
            if ([attachment isProjectorAttachment]) {
                item.slideBackgroundAttachment = attachment;
                item.slideBackgroundAttachmentId = [attachment.attachmentId copy];
                return YES;
            }
        }
    }
    
    PCOAttachment *attachment = [[item slideshowAttachments] firstObject];
    if (attachment) {
        item.slideBackgroundAttachment = attachment;
        item.slideBackgroundAttachmentId = [attachment.attachmentId copy];
        return YES;
    }
    
    attachment = [[item imageAttachments] firstObject];
    if (attachment) {
        item.slideBackgroundAttachment = attachment;
        item.slideBackgroundAttachmentId = [attachment.attachmentId copy];
        return YES;
    }
    
    attachment = [[item videoAttachments] firstObject];
    if (attachment) {
        item.slideBackgroundAttachment = attachment;
        item.slideBackgroundAttachmentId = [attachment.attachmentId copy];
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark - Helpers
- (NSURL *)URLForAttachmentFile:(NSString *)fileName cacheKey:(NSString *)cacheKey {
    return [[MCTDataStore sharedStore] URLForFileWithName:fileName key:cacheKey];
}
- (NSURL *)URLForAttachmentFileThumbnail:(NSString *)cacheKey {
    return [[MCTDataCacheController sharedCache] fileURLForKey:cacheKey error:nil];
}

- (void)addMediaAttachment:(PCOAttachment *)attachment toItem:(PCOItem *)item {
    if (item.customSlides.count > 0) {
        for (PCOCustomSlide *slide in item.customSlides) {
            slide.selectedBackgroundAttachment = nil;
        }
    }
    [self _downloadAttachmentFile:attachment];
}

- (UIImage *)thumbnailForMediaAttachment:(PCOAttachment *)attachment {
    NSString *cacheKey = [attachment thumbnailCacheKey];
    NSURL *fileURL = [[MCTDataCacheController sharedCache] fileURLForKey:cacheKey error:nil];
    if (fileURL) {
        return [UIImage imageWithContentsOfFile:fileURL.path];
    }
    return nil;
}

- (void)reloadEssentialBackgroundFiles {
    NSMutableSet *set = [NSMutableSet setWithCapacity:20];
    for (PCOItem *item in [self.plan orderedItems]) {
        [self _selectBestBackgroundAttachment:item];
        if (item.customSlides.count > 0) {
            for (PCOCustomSlide *slide in [item.customSlides allObjects]) {
                PCOAttachment *attachment = [slide selectedBackgroundAttachment];
                if (attachment) {
                    [set addObject:attachment];
                }
            }
        } else if (item.slideBackgroundAttachment) {
            [set addObject:item.slideBackgroundAttachment];
        }
    }
    for (PCOAttachment *attachment in set) {
        [self _downloadAttachmentFile:attachment];
    }
    if (![[PCOCoreDataManager sharedManager] save:NULL]) {
        PCOLogError(@"Failed to save CoreData");
    }
}

- (NSArray *)sectionsUsingAttachmentId:(NSString *)attachmentId {
    NSMutableSet *set = [NSMutableSet setWithCapacity:20];
    for (PCOItem *item in [self.plan orderedItems]) {
        if ([item.slideBackgroundAttachmentId isEqualToString:attachmentId]) {
            [set addObject:@([[self.plan orderedItems] indexOfObject:item])];
        }
        else {
            [self _selectBestBackgroundAttachment:item];
            if (item.customSlides.count > 0) {
                for (PCOCustomSlide *slide in [item.customSlides allObjects]) {
                    PCOAttachment *attachment = [slide selectedBackgroundAttachment];
                    if ([attachment.attachmentId isEqualToString:attachmentId]) {
                        [set addObject:@([[self.plan orderedItems] indexOfObject:item])];
                    }
                }
            }
        }
    }
    return [NSArray arrayWithArray:[set allObjects]];
}

- (NSArray *)pptSectionsUsingAttachmentId:(NSString *)attachmentId {
    NSMutableSet *set = [NSMutableSet setWithCapacity:20];
    for (PCOItem *item in [self.plan orderedItems]) {
        [self _selectBestBackgroundAttachment:item];
        if (item.customSlides.count > 0) {
            for (PCOCustomSlide *slide in [item.customSlides allObjects]) {
                PCOAttachment *attachment = [slide selectedBackgroundAttachment];
                if ([attachment.attachmentId isEqualToString:attachmentId]) {
                    [set addObject:@([[self.plan orderedItems] indexOfObject:item])];
                }
            }
        }
    }
    return [NSArray arrayWithArray:[set allObjects]];
}

@end

_PCO_EXTERN_STRING PROSlideManagerDidFinishPlanGenerationNotification = @"PROSlideManagerDidFinishPlanGenerationNotification";
_PCO_EXTERN_STRING PROSlideManagerDidFlushCacheNotification = @"PROSlideManagerDidFlushCacheNotification";
_PCO_EXTERN_STRING PROSlideManagerDidFlushCacheSectionNotification = @"PROSlideManagerDidFlushCacheSectionNotification";
