/*!
 * PROThumbnailGenerator.h
 *
 *
 * Created by Skylar Schipper on 8/20/14
 */

#ifndef PROThumbnailGenerator_h
#define PROThumbnailGenerator_h

@import Foundation;
@import AVFoundation;
@import ImageIO;
@import MobileCoreServices;
@import MCTImageKit;

@interface PROThumbnailGenerator : NSObject

+ (BOOL)isGeneratingThumbnail:(NSURL *)fileURL;

+ (void)generateVideoThumbnailForFileAtURL:(NSURL *)URL completion:(void(^)(NSURL *, NSError *))completion;
+ (void)generateImageThumbnailForFileAtURL:(NSURL *)URL completion:(void(^)(NSURL *, NSError *))completion;

+ (BOOL)generateImageThumbnailForFileAtURL:(NSURL *)URL writeToURL:(NSURL *)destinationURL error:(NSError **)error;

@end

FOUNDATION_EXTERN
NSString *const PROThumbnailGeneratorErrorDomain;

#endif
