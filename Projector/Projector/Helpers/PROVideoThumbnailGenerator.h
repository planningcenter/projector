/*!
 * PROVideoThumbnailGenerator.h
 *
 *
 * Created by Skylar Schipper on 7/16/14
 */

#ifndef PROVideoThumbnailGenerator_h
#define PROVideoThumbnailGenerator_h

@import Foundation;
@import UIKit;
@import AVFoundation;

DEPRECATED_ATTRIBUTE
@interface PROVideoThumbnailGenerator : NSObject

+ (void)generateThumbnailForVideoAtURL:(NSURL *)URL completion:(void(^)(UIImage *image, NSError *error))completion DEPRECATED_ATTRIBUTE;

@end

PCO_EXTERN_STRING PROVideoThumbnailGeneratorErrorDomain;

#endif
