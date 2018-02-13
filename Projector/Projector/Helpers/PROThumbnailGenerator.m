/*!
 * PROThumbnailGenerator.m
 *
 *
 * Created by Skylar Schipper on 8/20/14
 */

#import "PROThumbnailGenerator.h"
#import "PCODispatchGroup.h"

#define PROThumbnailGeneratorBestThumbSize CGSizeMake(320.0, 180.0)

@interface PROThumbnailGenerator ()

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong) dispatch_queue_t accessQueue;
@property (nonatomic, strong) NSMutableSet *currentJobs;

@end

@implementation PROThumbnailGenerator

+ (instancetype)_gen {
    static PROThumbnailGenerator *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [PROThumbnailGenerator new];
    });
    return shared;
}

#pragma mark -
#pragma mark - Lazy Loaders
- (dispatch_queue_t)dispatchQueue {
    @synchronized (self) {
        if (!_dispatchQueue) {
            _dispatchQueue = dispatch_queue_create("com.ministrycentered.projector.thumbnail", DISPATCH_QUEUE_CONCURRENT);
        }
        return _dispatchQueue;
    }
}
- (dispatch_queue_t)accessQueue {
    @synchronized (self) {
        if (!_accessQueue) {
            _accessQueue = dispatch_queue_create("com.ministrycentered.projector.thumbnail_access", DISPATCH_QUEUE_SERIAL);
        }
        return _accessQueue;
    }
}
- (NSMutableSet *)currentJobs {
    if (!_currentJobs) {
        _currentJobs = [NSMutableSet setWithCapacity:20];
    }
    return _currentJobs;
}

#pragma mark -
#pragma mark - Methods
+ (BOOL)isGeneratingThumbnail:(NSURL *)fileURL {
    return [self._gen p_isGeneratingThumbnail:fileURL];
}

+ (void)generateVideoThumbnailForFileAtURL:(NSURL *)URL completion:(void(^)(NSURL *, NSError *))completion {
    [self._gen p_generateVideoThumbnailForFileAtURL:URL completion:completion];
}
+ (void)generateImageThumbnailForFileAtURL:(NSURL *)URL completion:(void(^)(NSURL *, NSError *))completion {
    [self._gen p_generateImageThumbnailForFileAtURL:URL completion:completion];
}

#pragma mark -
#pragma mark - Threaded Helpers
- (BOOL)p_isGeneratingThumbnail:(NSURL *)fileURL {
    BOOL __block a = NO;
    dispatch_sync(self.accessQueue, ^{
        a = [self.currentJobs containsObject:fileURL];
    });
    return a;
}
- (void)p_generateVideoThumbnailForFileAtURL:(NSURL *)URL completion:(void(^)(NSURL *, NSError *))completion {
    dispatch_async(self.dispatchQueue, ^{
        @autoreleasepool {
            dispatch_sync(self.accessQueue, ^{
                [self.currentJobs addObject:URL];
            });
            
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:URL options:nil];
            [asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
                dispatch_async(self.dispatchQueue, ^{
                    @autoreleasepool {
                        [self p_generateVideoThumbnailForAsset:asset URL:URL completion:completion];
                    }
                });
            }];
        }
    });
}
- (void)p_generateVideoThumbnailForAsset:(AVURLAsset *)asset URL:(NSURL *)URL completion:(void(^)(NSURL *, NSError *))completion {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    
    Float64 thumbnailTime = 5.0;
    if ([asset statusOfValueForKey:@"duration" error:nil] == AVKeyValueStatusLoaded) {
        if (CMTimeGetSeconds([asset duration]) < thumbnailTime) {
            thumbnailTime = CMTimeGetSeconds([asset duration]) / 2.0;
        }
    }
    
    CMTime thumbTime = CMTimeMakeWithSeconds(thumbnailTime, 30);
    
    NSError *genError = nil;
    CGImageRef image = [generator copyCGImageAtTime:thumbTime actualTime:NULL error:&genError];
    
    if (genError) {
        if (completion) {
            completion(nil, genError);
        }
        if (image != NULL) {
            CGImageRelease(image);
        }
        dispatch_sync(self.accessQueue, ^{
            [self.currentJobs removeObject:URL];
        });
        return;
    }
    
    NSError *error = nil;
    
    if (image) {
        [self p_scaleImage:&image toBestSize:PROThumbnailGeneratorBestThumbSize error:&error];
    }
    
    NSError *writeError = nil;
    CFURLRef tmpURL = [self newTempLocationWriteImage:image error:&writeError];
    
    if (completion) {
        completion((__bridge id)tmpURL, writeError);
    }
    
    if (tmpURL != NULL) {
        NSURL *_URL = (__bridge id)tmpURL;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_URL.path]) {
            [[NSFileManager defaultManager] removeItemAtPath:_URL.path error:nil];
        }
        
        CFRelease(tmpURL);
    }
    if (image != NULL) {
        CGImageRelease(image);
    }
    
    dispatch_sync(self.accessQueue, ^{
        [self.currentJobs removeObject:URL];
    });
}

- (void)p_generateImageThumbnailForFileAtURL:(NSURL *)URL completion:(void(^)(NSURL *, NSError *))completion {
    dispatch_async(self.dispatchQueue, ^{
        @autoreleasepool {
            dispatch_sync(self.accessQueue, ^{
                [self.currentJobs addObject:URL];
            });
            
            NSError *error = nil;
            
            CGImageRef image = [self newImageRefFromURL:(__bridge CFURLRef)URL error:&error];
            if (!image) {
                if (completion) {
                    completion(nil, error);
                }
                dispatch_sync(self.accessQueue, ^{
                    [self.currentJobs removeObject:URL];
                });
                return;
            }
            
            if (![self p_scaleImage:&image toBestSize:PROThumbnailGeneratorBestThumbSize error:&error]) {
                PCOLogInfo(@"Failed to scale image: %@",image);
                if (!image) {
                    if (completion) {
                        completion(nil, error);
                    }
                    dispatch_sync(self.accessQueue, ^{
                        [self.currentJobs removeObject:URL];
                    });
                    return;
                }
            }
            
            NSError *writeError = nil;
            CFURLRef tmpURL = [self newTempLocationWriteImage:image error:&writeError];
            if (completion) {
                completion((__bridge id)tmpURL, writeError);
            }
            
            if (tmpURL != NULL) {
                NSURL *_URL = (__bridge id)tmpURL;
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:_URL.path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:_URL.path error:nil];
                }
                
                CFRelease(tmpURL);
            }
            
            dispatch_sync(self.accessQueue, ^{
                [self.currentJobs removeObject:URL];
            });
        }
    });
}

+ (BOOL)generateImageThumbnailForFileAtURL:(NSURL *)URL writeToURL:(NSURL *)destinationURL error:(NSError **)error {
    return [self._gen generateImageThumbnailForFileAtURL:URL writeToURL:destinationURL error:error];
}
- (BOOL)generateImageThumbnailForFileAtURL:(NSURL *)URL writeToURL:(NSURL *)destinationURL error:(NSError **)error {
    NSAssert(![NSThread isMainThread], @"Can't be on main thread");
    CFURLRef cURL = (__bridge CFURLRef)URL;
    CFURLRef cDestURL = (__bridge CFURLRef)destinationURL;
    
    CGImageRef image = [self newImageRefFromURL:cURL error:error];
    if (!image) {
        return NO;
    }
    
    if (![self p_scaleImage:&image toBestSize:PROThumbnailGeneratorBestThumbSize error:error]) {
        PCOLogInfo(@"Failed to scale image: %@",image);
        if (image) {
            CFRelease(image);
        }
        return NO;
    }
    
    BOOL success = [self writeImage:image toURL:cDestURL error:error];
    
    CGImageRelease(image);
    
    return success;
}
- (CGImageRef)newImageRefFromURL:(CFURLRef)URL error:(NSError **)error {
    CGImageSourceRef source = CGImageSourceCreateWithURL(URL, NULL);
    if (!source || CGImageSourceGetCount(source) == 0) {
        if (source) {
            CFRelease(source);
        }
        if (error != NULL) {
            *error = [NSError errorWithDomain:PROThumbnailGeneratorErrorDomain code:245 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to create data provider for image.", nil)}];
        }
        return NULL;
    }
    
    CGImageRef image = CGImageSourceCreateImageAtIndex(source, 0, NULL);
    
    CFRelease(source);
    
    if (!image) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:PROThumbnailGeneratorErrorDomain code:245 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to read image from source.", nil)}];
        }
        return nil;
    }
    
    return image;
}

- (CFURLRef)newTempLocationWriteImage:(CGImageRef)image error:(NSError **)error {
    CFURLRef URL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (__bridge CFStringRef)[[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"png"], kCFURLPOSIXPathStyle, FALSE);
    
    if (![self writeImage:image toURL:URL error:error]) {
        CFRelease(URL);
        return NULL;
    }
    
    return URL;
}
- (BOOL)writeImage:(CGImageRef)image toURL:(CFURLRef)URL error:(NSError **)error {
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(URL, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, NULL);
    if (!CGImageDestinationFinalize(destination)) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:PROThumbnailGeneratorErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to save image", nil)}];
        }
        CFRelease(destination);
        return NO;
    }
    CFRelease(destination);
    return YES;
}

- (BOOL)p_scaleImage:(CGImageRef *)ioImage toBestSize:(CGSize)size error:(NSError **)error {
    CGImageRef inputImage = CGImageCreateCopy(*ioImage);
    if (!inputImage) {
        return NO;
    }
    
    NSError *scaleError = nil;
    CGImageRef output = [MCTCoreImageScaler newScaledImageFromImage:inputImage toFit:size error:&scaleError];
    
    CGImageRelease(inputImage);
    
    if (output) {
        CGImageRelease(*ioImage);
        *ioImage = CGImageCreateCopy(output);
        CGImageRelease(output);
        return YES;
    }
    if (error != NULL) {
        NSDictionary *info = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to scale image to thumb size.", nil),
                               NSUnderlyingErrorKey: PCOSafe(scaleError)
                               };
        *error = [NSError errorWithDomain:PROThumbnailGeneratorErrorDomain code:245 userInfo:info];
    }
    
    return NO;
}

@end

NSString *const PROThumbnailGeneratorErrorDomain = @"PROThumbnailGeneratorErrorDomain";
