/*!
 * MCTCoreImageScaler.h
 * Projector
 *
 * Created by Skylar Schipper on 10/9/14
 */

#ifndef Projector_MCTCoreImageScaler_h
#define Projector_MCTCoreImageScaler_h

@import Foundation;
@import CoreGraphics;
@import ImageIO;

@interface MCTCoreImageScaler : NSObject

+ (CGImageRef)newScaledImageFromImage:(CGImageRef)image toFit:(CGSize)size error:(NSError **)error;

+ (CGRect)rectInSize:(CGSize)size aspect:(CGFloat)aspect;

@end

#endif
