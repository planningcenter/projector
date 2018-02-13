/*!
 * PROVideoThumbnailGenerator.m
 *
 *
 * Created by Skylar Schipper on 7/16/14
 */

#import "PROVideoThumbnailGenerator.h"

@interface PROVideoThumbnailGenerator ()

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@end

@implementation PROVideoThumbnailGenerator

+ (instancetype)generator DEPRECATED_ATTRIBUTE {
    static PROVideoThumbnailGenerator *generator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        generator = [[PROVideoThumbnailGenerator alloc] init];
    });
    return generator;
}

+ (void)generateThumbnailForVideoAtURL:(NSURL *)URL completion:(void(^)(UIImage *image, NSError *error))completion {
    [self.generator generateThumbnailForVideoAtURL:URL completion:completion];
}

- (dispatch_queue_t)dispatchQueue {
    if (!_dispatchQueue) {
        _dispatchQueue = dispatch_queue_create("com.projector.ThumbnailGenerator", DISPATCH_QUEUE_CONCURRENT);
    }
    return _dispatchQueue;
}

#pragma mark -
#pragma mark -
- (void)generateThumbnailForVideoAtURL:(NSURL *)URL completion:(void(^)(UIImage *image, NSError *error))completion {
    dispatch_async(self.dispatchQueue, ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:URL options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        
        CMTime thumbTime = CMTimeMakeWithSeconds(1.0, 30);
        
        NSError *genError = nil;
        CGImageRef image = [generator copyCGImageAtTime:thumbTime actualTime:NULL error:&genError];
        
        if (genError) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, genError);
                });
            }
            if (image != NULL) {
                CGImageRelease(image);
            }
            return;
        }
        
        UIImage *newImage = nil;
        if (image != NULL) {
            newImage = [UIImage imageWithCGImage:image];
            CGImageRelease(image);
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(newImage, nil);
            });
        }
    });
}

@end

_PCO_EXTERN_STRING PROVideoThumbnailGeneratorErrorDomain = @"PROVideoThumbnailGeneratorErrorDomain";
