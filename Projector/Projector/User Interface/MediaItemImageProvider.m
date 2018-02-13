/*!
 * MediaItemImageProvider.m
 *
 *
 * Created by Skylar Schipper on 3/26/14
 */

#import "MediaItemImageProvider.h"
#import "PCOMedia.h"
#import "PCOCryptographer.h"
#import "PCOAttachment.h"

#import <MCTDataCache/MCTDataCache.h>

@interface MediaItemImageProvider ()

@end

@implementation MediaItemImageProvider

- (void)getImage:(void(^)(NSNumber *remoteID, UIImage *image))handler {
    if (!self.media.imageUrl || self.media.imageUrl.length == 0) {
        [self getImageForFileName:handler];
    } else {
        [self getThumbnailImage:handler];
    }
}

- (void)getImageForFileName:(void(^)(NSNumber *remoteID, UIImage *image))handler {
    NSString __block *nameHash = [[PCOCryptographer sharedCryptographer] SHA1String:[self.media localizedDescription]];
    [[MCTDataCacheController sharedCache] cachedDataForKey:nameHash dataLoader:^NSData *(NSString *key, NSError *__autoreleasing *error) {
        UIImage *image = [self _buildImageWithName:nameHash];
        if (image) {
            return UIImagePNGRepresentation(image);
        }
        return nil;
    } completion:^(NSURL *fileURL, NSDictionary *info, NSError *error) {
        if (fileURL) {
            UIImage *image = [UIImage imageWithContentsOfFile:[fileURL path]];
            if (image) {
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(self.media.remoteId, image);
                    });
                }
                return;
            }
        }
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(self.media.remoteId, nil);
            });
        }
    }];
    
    if (handler) {
        handler(self.media.remoteId, nil);
    }
}
- (void)getThumbnailImage:(void(^)(NSNumber *remoteID, UIImage *image))handler {
    [[MCTDataCacheController sharedCache] cachedImageAtURL:[NSURL URLWithString:self.media.imageUrl] completion:^(UIImage *image, NSError *error) {
        if (handler) {
            handler(self.media.remoteId, image);
        }
    }];
}

- (UIImage *)_buildImageWithName:(NSString *)nameHash {
    NSUInteger count = nameHash.length;
    NSMutableArray *vals = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        NSNumber *number = @([nameHash characterAtIndex:i]);
        [vals addObject:number];
    }
    
    PCOAttachment *attachment = [[self.media orderedAttachments] firstObject];
    NSString *fileExt = [attachment.filename pathExtension];
    
    CGFloat red = [[vals firstObject] floatValue] / 255.0;
    CGFloat green = [vals[(NSUInteger)floorf(vals.count / 2)] floatValue] / 255.0;
    CGFloat blue = [[vals lastObject] floatValue] / 255.0;
    
    CGSize size = CGSizeMake(320, 180);
    
    UIColor *backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    UIGraphicsBeginImageContextWithOptions(size, YES, [[UIScreen mainScreen] scale]);
    
    [backgroundColor setFill];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
    
    static UIFont *font;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        font = [UIFont defaultFontOfSize:60.0];
    });
    
    CGSize textSize = [fileExt pcoSizeWithFont:font constrainedToSize:size];
    
    CGPoint point = CGPointZero;
    point.x = PCOKitHalf(size.width) - PCOKitHalf(textSize.width);
    point.y = PCOKitHalf(size.height) - PCOKitHalf(textSize.height);
    
    [fileExt drawAtPoint:point withAttributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: [backgroundColor contrastColor]}];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
