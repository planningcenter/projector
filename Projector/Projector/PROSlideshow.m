/*!
 * PROSlideshow.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/15/14
 */

#import <MCTFileDownloader/MCTFileDownloader.h>

#import "PROSlideshow.h"
#import "OSDCrypto.h"
#import "NSCache+PCOCocoaAdditions.h"
#import "PCOAttachment.h"
#import "PROThumbnailGenerator.h"

static NSString *const kPROSlideshowInfoFileName = @"Info.plist";

@interface PROSlideshow ()

@property (nonatomic, strong) NSString *key;

@property (nonatomic, strong, readwrite) NSString *attachmentID;
@property (nonatomic, assign, readwrite) PROSlideshowStatus status;

@property (nonatomic, strong) NSDictionary *info;

@property (nonatomic, strong) NSNumber *countCache;

@property (nonatomic, strong) NSTimer *retryTimer;

@property (nonatomic, strong, readwrite) NSDate *createdAt;

@property (nonatomic, strong, readwrite) NSNumber *fileSize;

@property (nonatomic) NSUInteger retryCount;

@end

@implementation PROSlideshow

+ (NSMutableDictionary *)cache {
    static NSMutableDictionary *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary dictionary];
    });
    return cache;
}
+ (NSObject *)lockObj {
    static NSObject *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[NSObject alloc] init];
    });
    return obj;
}

+ (instancetype)slideshowWithAttachmentID:(NSString *)attachmentID {
    @synchronized([self lockObj]) {
        NSMutableDictionary *cache = [self cache];
        NSString *key = [OSDCrypto hashString:attachmentID type:OSDCryptoHashMD5];
        PROSlideshow *show = cache[key];
        if (!show) {
            show = [[[self class] alloc] initWithAttachmentID:attachmentID];
            if (show) {
                show.key = key;
                cache[key] = show;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:PROSlideshowChangeNotification object:show];
                });
            }
        }
        return show;
    }
}

- (instancetype)initWithAttachmentID:(NSString *)attachmentID {
    self = [super init];
    if (self) {
        self.attachmentID = attachmentID;
        self.createdAt = [NSDate date];
        [self loadAttachmentInfo];
    }
    return self;
}

- (void)updateServerStatusWithCompletion:(void(^)(NSError *))completion {
    NSURL *URL = [NSURL planningCenterBaseURLWithFormat:@"/projector/convert/ppt/%@.json",self.attachmentID];
    
    [self invalidateRetry];
    
    PCOLogDebug(@"[PPT]: %@",[URL absoluteString]);
    
    [[PCOServerRequest requestWithURL:URL] startWithCompletion:^(PCOServerResponse *response) {
        if (response.error) {
            self.status = PROSlideshowStatusError;
            if (completion) {
                completion(response.error);
            }
            return;
        }
        
        NSDictionary *info = [response JSONBody];
        if (!info) {
            self.status = PROSlideshowStatusConverting;
            [self scheduleForRetry];
            if (completion) {
                completion(nil);
            }
        } else {
            self.info = [info copy];
            [self fetchMissingSlidesWithCompletion:completion];
        }
    }];
}
- (void)fetchMissingSlidesWithCompletion:(void(^)(NSError *))completion {
    if (self.status == PROSlideshowStatusDownloading) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    self.status = PROSlideshowStatusDownloading;
    
    NSUInteger slideCount = [self slideCount];
    NSMutableSet *missingSlides = [NSMutableSet setWithCapacity:slideCount];
    
    for (NSUInteger slideIdx = 0; slideIdx < slideCount; slideIdx++) {
        NSString *path = [self _slidePathWithIndex:slideIdx];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [missingSlides addObject:@(slideIdx)];
        }
    }
    if (missingSlides.count == 0) {
        [self generateMissingSlideThumbnails:completion];
        [self _updateFileSize];
        return;
    }
    
    PCOServerRequest *slideURLS = [PCOServerRequest requestWithFormat:@"/projector/convert/ppt/%@/slides.json",self.attachmentID];
    [slideURLS startWithCompletion:^(PCOServerResponse *response) {
        if (response.error) {
            self.status = PROSlideshowStatusError;
            if (completion) {
                completion(response.error);
            }
            return;
        }
        
        NSArray *slideURLs = [response JSONBody][@"slides"];
        
        [self _fetchMissingSlides:missingSlides slideURLs:slideURLs completion:completion];
    }];
}
- (void)generateMissingSlideThumbnails:(void(^)(NSError *))completion {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("thumbnail_generator", DISPATCH_QUEUE_SERIAL);
    });
    
    dispatch_async(queue, ^{
        @autoreleasepool {
            [self _generateMissingSlideThumbnails:completion];
        }
    });
}
- (void)_generateMissingSlideThumbnails:(void(^)(NSError *))completion {
    for (NSUInteger index = 0; index < [self slideCount]; index++) {
        NSString *thumb = [self _slideThumbnailPathWithIndex:index];
        if (![[NSFileManager defaultManager] fileExistsAtPath:thumb]) {
            NSString *path = [self _slidePathWithIndex:index];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSError *thumbError = nil;
                if (![PROThumbnailGenerator generateImageThumbnailForFileAtURL:[NSURL fileURLWithPath:path] writeToURL:[NSURL fileURLWithPath:thumb] error:&thumbError]) {
                    PCOError(thumbError);
                }
            }
        }
    }
    self.status = PROSlideshowStatusReady;
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
    }
}
- (void)_fetchMissingSlides:(NSSet *)slideIndexs slideURLs:(NSArray *)slideURLs completion:(void(^)(NSError *))completion {
    NSMutableDictionary *missingURLs = [NSMutableDictionary dictionaryWithCapacity:slideIndexs.count];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:missingURLs.count];
    NSUInteger index = 0;
    for (NSString *URLString in slideURLs) {
        if ([slideIndexs containsObject:@(index)]) {
            NSURL *URL = [NSURL URLWithString:URLString];
            PRODownloadOperation *operation = [[PRODownloadOperation alloc] initWithURL:URL];
            operation.userInfo = @{
                                   @"index": @(index)
                                   };
            [operation setCompletion:^(PRODownloadOperation *opp, NSURL *location, NSError *error) {
                if (error) {
                    PCOError(error);
                    return;
                }
                NSUInteger idx = [opp.userInfo[@"index"] unsignedIntegerValue];
                if (!location) {
                    PCOLogError(@"Failed to fetch slide at index %tu",idx);
                }
                NSString *path = [self _slidePathWithIndex:idx];
                
                NSError *moveError = nil;
                if (![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:path error:&moveError]) {
                    PCOError(moveError);
                }
            }];
            [array addObject:operation];
        }
        index++;
    }
    
    if (array.count == 0) {
        [self _updateFileSize];
        [self generateMissingSlideThumbnails:completion];
        return;
    }
    
    PRODownload *download = [[PRODownload alloc] initWithOperations:array];
    download.localizedDescription = (self.localizedName) ?: NSLocalizedString(@"Slideshow", nil);
    download.typeIdentifier = NSLocalizedString(@"slides", nil);
    
    [download setCompletion:^(PRODownload *dl) {
        [self _updateFileSize];
        [self generateMissingSlideThumbnails:completion];
    }];
    
    [[PRODownloader sharedDownloader] beginDownload:download];
    
    return;
}

- (void)_updateFileSize {
    size_t size = 0;
    for (NSUInteger index = 0; index < [self slideCount]; index++) {
        NSString *path = [self _slidePathWithIndex:index];
        NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        if (info) {
            size += [info[NSFileSize] unsignedLongLongValue];
        }
    }
    self.fileSize = @(size);
}

- (BOOL)deleteSlideshow:(NSError **)error {
    NSString *path = [self _slidesPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:error]) {
            return NO;
        }
    }
    
    @synchronized([self.class lockObj]) {
        if (self.key) {
            [[self.class cache] removeObjectForKey:self.key];
        }
    }
    
    return [self.class save];
}

// MARK: - Slides
- (NSString *)_slidesPath {
    NSString *path = [[self.class _slideshowPath] stringByAppendingPathComponent:self.key];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
- (NSString *)_slidePathWithIndex:(NSUInteger)index {
    return [[self _slidesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%tu-fs.png",index]];
}
- (NSString *)_slideThumbnailPathWithIndex:(NSUInteger)index {
    return [[self _slidesPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%tu-tn.png",index]];
}
- (PROSlideshowSlide *)slideAtIndex:(NSInteger)index {
    PROSlideshowSlide *slide = [[PROSlideshowSlide alloc] init];
    slide.path = [self _slidePathWithIndex:index];
    slide.thumbnailPath = [self _slideThumbnailPathWithIndex:index];
    return slide;
}

// MARK: - Retrying
- (void)scheduleForRetry {
    self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(_retry:) userInfo:nil repeats:NO];
}
- (void)invalidateRetry {
    [self.retryTimer invalidate];
    _retryTimer = nil;
}
- (void)_retry:(id)sender {
    [self updateServerStatusWithCompletion:nil];
}

// MARK: - Core Data
- (void)loadAttachmentInfo {
    if (!self.attachmentID) {
        return;
    }
    void(^load)(void) = ^ {
        PCOAttachment *attachment = [PCOAttachment findFirstByAttribute:@"attachmentId" withValue:self.attachmentID];
        
        self.localizedName = [attachment filename];
    };
    
    if ([NSThread isMainThread]) {
        load();
    } else {
        dispatch_sync(dispatch_get_main_queue(), load);
    }
}

- (void)setStatus:(PROSlideshowStatus)status {
    _status = status;
    switch (status) {
        case PROSlideshowStatusError:
        case PROSlideshowStatusReady:
            [self.class save];
            break;
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PROSlideshowStatusChangedNotification object:self];
    });
}

// MARK: - Info
- (NSUInteger)slideCount {
    return [self.countCache unsignedIntegerValue];
}
- (NSNumber *)countCache {
    if (!_countCache) {
        id obj = self.info[@"conversion"][@"count"];
        if ([obj isKindOfClass:[NSNumber class]]) {
            _countCache = obj;
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
            _countCache = [fmt numberFromString:obj];
        }
    }
    return _countCache;
}

// MARK: - Coding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.attachmentID forKey:@"attachmentID"];
    [aCoder encodeObject:self.info forKey:@"info"];
    [aCoder encodeObject:@(self.status) forKey:@"status"];
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.localizedName forKey:@"localizedName"];
    [aCoder encodeObject:self.createdAt forKey:@"createdAt"];
    [aCoder encodeObject:self.fileSize forKey:@"fileSize"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.attachmentID = [aDecoder decodeObjectForKey:@"attachmentID"];
        self.info = [aDecoder decodeObjectForKey:@"info"];
        self.status = [[aDecoder decodeObjectForKey:@"status"] unsignedIntegerValue];
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.localizedName = [aDecoder decodeObjectForKey:@"localizedName"];
        self.createdAt = [aDecoder decodeObjectForKey:@"createdAt"];
        self.fileSize = [aDecoder decodeObjectForKey:@"fileSize"];
    }
    return self;
}

// MARK: - Class Helpers
+ (NSString *)_slideshowPath {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"slideshow-fh39"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
+ (BOOL)save {
    @synchronized([self lockObj]) {
        NSString *file = [[self _slideshowPath] stringByAppendingPathComponent:kPROSlideshowInfoFileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:file error:nil]) {
                return NO;
            }
        }
        
        return [NSKeyedArchiver archiveRootObject:[self cache] toFile:file];
    }
}
+ (BOOL)load {
    @synchronized([self lockObj]) {
        NSString *file = [[self _slideshowPath] stringByAppendingPathComponent:kPROSlideshowInfoFileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
            return YES;
        }
        
        NSDictionary *info = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
        
        [[self cache] addEntriesFromDictionary:info];
        
        return YES;
    }
}
+ (NSArray *)allSlideshows {
    @synchronized([self lockObj]) {
        return [[[self cache] allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 attachmentID] compare:[obj2 attachmentID]];
        }];
    }
}

// MARK: - Debug
- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p %@ %@>",NSStringFromClass(self.class),self,self.localizedName,self.info];
}
- (NSString *)description {
#if DEBUG
    return [self debugDescription];
#endif
    return [super description];
}

@end

@implementation PROSlideshowSlide

@end

NSString *const PROSlideshowChangeNotification = @"PROSlideshowChangeNotification";
NSString *const PROSlideshowStatusChangedNotification = @"PROSlideshowStatusChangedNotification";
