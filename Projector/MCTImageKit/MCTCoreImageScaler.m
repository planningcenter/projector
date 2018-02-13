/*!
 * MCTCoreImageScaler.m
 * Projector
 *
 * Created by Skylar Schipper on 10/9/14
 */

#import "MCTCoreImageScaler.h"
#import "MCTImageKitErrors.h"

@interface MCTCoreImageScaler ()

@end

@implementation MCTCoreImageScaler

+ (CGImageRef)newScaledImageFromImage:(CGImageRef)image toFit:(CGSize)size error:(NSError **)error {
    if (!image) {
        return NULL;
    }

    CGFloat imageWidth = CGImageGetWidth(image);
    CGFloat imageHeight = CGImageGetHeight(image);

    CGRect rect = [self rectInSize:size aspect:(imageWidth / imageHeight)];

    size_t width = (size_t)ceilf(CGRectGetWidth(rect));
    size_t height = (size_t)ceilf(CGRectGetHeight(rect));

    size_t bitsPerComponent = MIN(8, CGImageGetBitsPerComponent(image)); // iOS doesn't support > 8 bits per component.  The keynote service returns 16bit images.  So this is here
    size_t bytesPerRow = CGImageGetBytesPerRow(image);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    CGBitmapInfo info = CGImageGetBitmapInfo(image);
    if ((info & kCGBitmapAlphaInfoMask) == kCGImageAlphaLast) {
        info = (CGBitmapInfo)kCGImageAlphaPremultipliedLast;
    } else if ((info & kCGBitmapAlphaInfoMask) == kCGImageAlphaFirst) {
        info = (CGBitmapInfo)kCGImageAlphaPremultipliedFirst;
    }

    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, info);
    if (!ctx) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTImageKitErrorDomain code:MCTImageKitErrorContextCreate userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to create image context", nil)}];
        }
        return NULL;
    }

    CGRect drawRect = {CGPointZero, {(CGFloat)width, (CGFloat)height}};

    CGContextDrawImage(ctx, drawRect, image);

    CGImageRef output = CGBitmapContextCreateImage(ctx);

    CGContextRelease(ctx);

    if (!output) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTImageKitErrorDomain code:MCTImageKitErrorPerformScale userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to scale image", nil)}];
        }
    }

    return output;
}

+ (CGRect)rectInSize:(CGSize)size aspect:(CGFloat)aspect {
    CGRect rect = CGRectZero;

    CGFloat width = size.width;
    CGFloat height = width / aspect;

    CGFloat offsetY = (size.height - height) / 2.0;
    CGFloat offsetX = 0.0;

    if (height > size.height) {
        height = size.height;
        width = height * aspect;
        offsetY = 0.0;
        offsetX = (size.width - width) / 2.0;
    }

    rect.size = CGSizeMake(width, height);
    rect.origin = CGPointMake(offsetX, offsetY);

    return CGRectIntegral(rect);
}

@end

NSString *const MCTImageKitErrorDomain = @"MCTImageKitErrorDomain";
