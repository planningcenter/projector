/*!
 * PROSlideItem.m
 *
 *
 * Created by Skylar Schipper on 7/22/14
 */

#import "PROSlideItem.h"

#import "MCTDocument.h"

#import "MCTDataStore.h"

#import "PROSlideManager.h"

#import "PROSlideData.h"
#import "PROSlideItemInfo.h"

// Core Data
#import "PCOItem.h"
#import "PCOAttachment.h"
#import "PCOSlideLayout.h"
#import "PCOSlide.h"
#import "PCOStanza.h"
#import "PCOSequenceItem.h"
#import "PROSlideLayout.h"
#import "PCOAttachment+ProjectorAdditions.h"
#import "PROSlideStanzaProvider.h"
#import "PROSlideshow.h"

@interface PROSlideItem ()

@property (nonatomic) BOOL header;

@property (nonatomic, strong) MCTDocument *document;

@property (nonatomic, strong) NSArray *slidesRawCache;
@property (nonatomic, strong) NSCache *slideCache;
@property (nonatomic) NSUInteger linesPerSlide;

@property (nonatomic, strong, readwrite) NSManagedObjectID *itemID;
@property (nonatomic, strong, readwrite) NSManagedObjectID *slideBackgroundAttachmentID;

@property (nonatomic, strong) NSNumber *slideCount;

@property (nonatomic, strong) PROSlideLayout *textLayout;
@property (nonatomic, strong) PROSlideLayout *titleLayout;
@property (nonatomic, strong) PROSlideLayout *infoLayout;

@property (nonatomic, strong) NSURL *slideBackgroundFileURL;
@property (nonatomic, strong) NSURL *slideBackgroundFileThumbnailURL;

@property (nonatomic, strong) PROSlideshow *slideshow;

@property (nonatomic, strong, readwrite) NSString *copyrightInfo;

@property (nonatomic) BOOL showInfoOnFirst;
@property (nonatomic) BOOL showInfoOnLast;
@property (nonatomic) BOOL showInfoOnAll;

@end

@implementation PROSlideItem

- (instancetype)initWithItem:(PCOItem *)item manager:(PROSlideManager *)manager {
    self = [super init];
    if (self) {
        [self configureForItem:item manager:manager];
    }
    return self;
}

- (void)configureForItem:(PCOItem *)item manager:(PROSlideManager *)manager {
    if ([item obtainPermanentID]) {
        self.itemID = [item objectID];
    }
    
    self.header = [item isTypeHeader];
    if ([self isHeader]) {
        self.slideCount = @0;
    } else {
        self.slideCount = nil;
    }
    
    [self.class pro_checkCurrentLayoutForItem:item inContext:item.managedObjectContext];
    
    if (item.selectedSlideLayout) {
        self.textLayout = [[PROSlideLayout alloc] initWithLayout:item.selectedSlideLayout.lyricTextLayout];
        self.titleLayout = [[PROSlideLayout alloc] initWithLayout:item.selectedSlideLayout.titleTextLayout];
        self.infoLayout = [[PROSlideLayout alloc] initWithLayout:item.selectedSlideLayout.songInfoLayout];
    }
    
    if (item.song) {
        self.copyrightInfo = ({
            NSString *title = ([item.song localizedDescription]) ?: @"";
            NSString *author = (item.song.author) ?: @"";
            NSString *notice = (item.song.copyright) ?: @"";
            NSString *CCLI = [NSString stringWithFormat:@"CCLI # %@",[[PCOOrganization current] ccliNumber]];
            [NSString stringWithFormat:@"%@\n%@\n© %@\n%@",title,author,notice,CCLI];
        });
    }
    
    self.showInfoOnAll = [item.selectedSlideLayout.songInfoLayout.showOnAllSlides boolValue];
    self.showInfoOnFirst = [item.selectedSlideLayout.songInfoLayout.showOnlyOnFirstSlide boolValue];
    self.showInfoOnLast = [item.selectedSlideLayout.songInfoLayout.showOnlyOnLastSlide boolValue];
    
    if ([item currentSelectedSlideBackgroundAttachment]) {
        PCOAttachment *attachment = [item currentSelectedSlideBackgroundAttachment];
        if ([attachment obtainPermanentID]) {
            self.slideBackgroundAttachmentID = [attachment objectID];
        }
        
        NSString *key = [attachment fileCacheKey];
        NSString *name = [attachment filename];
        NSString *thumb = [attachment thumbnailCacheKey];
        
        self.slideBackgroundFileURL = [manager URLForAttachmentFile:name cacheKey:key];
        self.slideBackgroundFileThumbnailURL = [manager URLForAttachmentFileThumbnail:thumb];
    }
    
    if ([item.managedObjectContext hasChanges]) {
        NSError *saveError = nil;
        if (![item.managedObjectContext save:&saveError]) {
            PCOError(saveError);
        }
    }
}

#pragma mark -
#pragma mark - Count
- (NSNumber *)slideCount {
    if (!_slideCount) {
        _slideCount = [self loadCount];
    }
    return _slideCount;
}
- (NSInteger)count {
    return [self.slideCount integerValue];
}
- (NSNumber *)loadCount {
    NSUInteger count = [self loadLyricsSlideCount];
    
    if (self.slideBackgroundAttachmentID) {
        PCOAttachment *background = [PCOAttachment objectWithID:self.slideBackgroundAttachmentID];
        if (background) {
            if ([background isSlideshow]) {
                return @([self slideCountForAttachmentID:background.attachmentId]);
            } else {
                count = MAX(MAX(background.numberOfSlides.unsignedIntegerValue, count), (NSUInteger)1);
            }
        }
    }
    
    return @(count);
}

- (NSUInteger)slideCountForAttachmentID:(NSString *)attachmentID {
    [self loadPowerPointWithAttachmentID:attachmentID];
    return [self.slideshow slideCount];
}
- (BOOL)loadPowerPointWithAttachmentID:(NSString *)attachmentID {
    if (!attachmentID) {
        return NO;
    }
    if ([self.slideshow.attachmentID isEqualToString:attachmentID]) {
        return YES;
    }
    
    self.slideshow = [PROSlideshow slideshowWithAttachmentID:attachmentID];
    
    return (self.slideshow != nil);
}

- (NSUInteger)loadLyricsSlideCount {
    return self.slidesRawCache.count;
}

#pragma mark -
#pragma mark - Custom Slide Info
- (PROSlideItemInfo)newSlideItemInfo {
    NSManagedObjectContext *context  = [[PCOCoreDataManager sharedManager] contextForCurrentThread];
    
    NSError *error = nil;
    PCOItem *item = [self loadItemInContext:context error:&error];
    PCOError(error);
    
    [self.class pro_checkCurrentLayoutForItem:item inContext:context];
    NSUInteger layoutLineCount = [item.selectedSlideLayout.lyricTextLayout.defaultLinesPerSlide integerValue];
    CGFloat fontSize = [item.selectedSlideLayout.lyricTextLayout.fontSize floatValue];
    UIEdgeInsets insets = [item.selectedSlideLayout.lyricTextLayout layoutInsets];
    
    if (layoutLineCount == 0) {
        layoutLineCount = 4;
    }
    
    PROSlideItemInfo info = {};
    info.performSmartFormatting = YES;
    info.insets = insets;
    info.fontSize = fontSize;
    info.lineCount = layoutLineCount;
    
    NSError *saveError = nil;
    [context pco_saveIfChild:&saveError];
    PCOError(saveError);
    
    return info;
}
- (NSArray *)_createSlidesForInfo:(PROSlideItemInfo)info {
    NSManagedObjectContext *context = [[PCOCoreDataManager sharedManager] contextForCurrentThread];
    
    NSError *loadError = nil;
    PCOItem *item = [self loadItemInContext:context error:&loadError];
    PCOError(loadError);
    
    NSArray *slides = [PROSlideData slidesWithItem:item stanzaProvider:[PROSlideStanzaProvider providerWithItem:item] info:info];
    
    NSError *saveError = nil;
    if (![context pco_saveIfChild:&saveError]) {
        PCOLogDebug(@"Failed to save child context");
    }
    PCOError(saveError);
    
    return slides;
}

+ (void)pro_checkCurrentLayoutForItem:(PCOItem *)item inContext:(NSManagedObjectContext *)context {
    if (!item.selectedSlideLayout) {
        if ([item.selectedSlideLayoutId integerValue] >= 0) {
            PCOSlideLayout *layout = [PCOSlideLayout findFirstByAttribute:@"layoutId" withValue:item.selectedSlideLayoutId];
            if (!layout) {
                PCOSlideLayout *layout = [[[PCOCoreDataManager sharedManager] layoutsController] defaultLayoutInContext:context];
                item.selectedSlideLayoutId = layout.remoteId;
            }
            item.selectedSlideLayout = layout;
        } else {
            PCOSlideLayout *layout = [[[PCOCoreDataManager sharedManager] layoutsController] defaultLayoutInContext:context];
            item.selectedSlideLayout = layout;
            item.selectedSlideLayoutId = layout.remoteId;
        }
    }
    else {
        if (![item.selectedSlideLayoutId isEqualToNumber:item.selectedSlideLayout.remoteId]) {
            PCOSlideLayout *layout = [PCOSlideLayout findFirstByAttribute:@"layoutId" withValue:item.selectedSlideLayoutId];
            item.selectedSlideLayout = layout;
        }
    }
}

#pragma mark -
#pragma mark - Getters
- (BOOL)isHeader {
    return self.header;
}
- (PCOItem *)loadItemWithError:(NSError **)error {
    return [self loadItemInContext:[[PCOCoreDataManager sharedManager] contextForCurrentThread] error:error];
}
- (PCOItem *)loadItemInContext:(NSManagedObjectContext *)ctx error:(NSError **)error {
    if (!self.itemID) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:PCOCoreDataManagerErrorDomain code:PCOCoreDataManagerErrorUnknown userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Can't load item without ID", nil)}];
        }
        return nil;
    }
    return (PCOItem *)[ctx existingObjectWithID:self.itemID error:error];
}

#pragma mark -
#pragma mark - Lazy Loaders
- (NSCache *)slideCache {
    if (!_slideCache) {
        _slideCache = [[NSCache alloc] init];
    }
    return _slideCache;
}

- (NSArray *)slidesRawCache {
    if (!_slidesRawCache) {
        PROSlideItemInfo info = [self newSlideItemInfo];
        NSArray *cache = [self _createSlidesForInfo:info];
        _slidesRawCache = cache;
        self.linesPerSlide = info.lineCount;
    }
    return _slidesRawCache;
}

#pragma mark -
#pragma mark - Loaders
- (PROSlide *)newSlideForRow:(NSInteger)row {
    NSError *itemLoadError = nil;
    PCOItem *item = [self loadItemWithError:&itemLoadError];
    PROSlideData *rawSlide = nil;
    if ([self.slidesRawCache hasObjectForIndex:row]) {
        rawSlide = self.slidesRawCache[row];
    }
    
    PROSlide *slide = [[PROSlide alloc] initWithItem:item slide:rawSlide textLayout:self.textLayout titleLayout:self.titleLayout infoLayout:self.infoLayout slideIndex:row];
    slide.contentMode = UIViewContentModeProjectorPreferred;
    slide.error = itemLoadError;
    if (!slide.backgroundColor) {
        slide.backgroundColor = [UIColor blackColor];
    }
    
    if (!self.slideshow && self.slideBackgroundAttachmentID) {
        PCOAttachment *background = [PCOAttachment objectWithID:self.slideBackgroundAttachmentID];
        if ([background isSlideshow]) {
            [self loadPowerPointWithAttachmentID:background.attachmentId];
        } else if ([background isVideo]) {
            if (!slide.label) {
                slide.label = NSLocalizedString(@"Video", nil);
            }
        } else if ([background isImage]) {
            if (!slide.label) {
                slide.label = NSLocalizedString(@"Image", nil);
            }
        } else if ([background isExpandedAudio]) {
            if (!slide.label) {
                slide.label = NSLocalizedString(@"Audio", nil);
            }
        }
    }
    
    if (self.slideshow) {
        PROSlideshowSlide *rawSlide = [self.slideshow slideAtIndex:row];
        slide.backgroundFileURL = [NSURL fileURLWithPath:rawSlide.path];
        slide.backgroundThumbnailURL = [NSURL fileURLWithPath:rawSlide.thumbnailPath];
        if ([[ProjectorSettings userSettings] aspectRatio] == ProjectorAspectRatio_4_3) {
            slide.contentMode = UIViewContentModeScaleAspectFill;
        }
    } else if ([rawSlide isMultiBackground]) {
        slide.backgroundFileURL = rawSlide.slideBackgroundFileURL;
        slide.backgroundThumbnailURL = rawSlide.slideBackgroundFileThumbnailURL;
    }
    
    if (!slide.backgroundFileURL) {
        slide.backgroundFileURL = [self.slideBackgroundFileURL copy];
    }
    if (!slide.backgroundThumbnailURL) {
        slide.backgroundThumbnailURL = [self.slideBackgroundFileThumbnailURL copy];
    }
    
    if (!slide.label) {
        slide.label = [NSString stringWithFormat:NSLocalizedString(@"Slide %li", nil),(long)row + 1];
    }
    
    if (self.copyrightInfo) {
        if (self.showInfoOnFirst && row == 0) {
            slide.copyright = self.copyrightInfo;
        }
        if (self.showInfoOnLast && row == [self count] - 1) {
            slide.copyright = self.copyrightInfo;
        }
        if (self.showInfoOnAll) {
            slide.copyright = self.copyrightInfo;
        }
    }
    
    return slide;
}
- (PROSlide *)slideForRow:(NSInteger)row {
    return [self.slideCache objectForKey:[NSString stringWithFormat:@"%li",(long)row] compute:^id(id key) {
        return [self newSlideForRow:row];
    }];
}

+ (NSUInteger)numberOfLinesPerSlideForItem:(PCOItem *)item {
    [self pro_checkCurrentLayoutForItem:item inContext:item.managedObjectContext];
    PCOSlideLayout *layout = item.selectedSlideLayout;
    if (!layout) {
        layout = [[[PCOCoreDataManager sharedManager] layoutsController] defaultLayoutInContext:item.managedObjectContext];
    }
    
    NSUInteger count = [layout.lyricTextLayout.defaultLinesPerSlide integerValue];
    if (count > 0) {
        return count;
    }
    return 4;
}

@end
