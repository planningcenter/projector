/*!
 * PROHEXColorStringNormalizer.h
 *
 *
 * Created by Skylar Schipper on 6/12/14
 */

#ifndef PROHEXColorStringNormalizer_h
#define PROHEXColorStringNormalizer_h

@import Foundation;

@interface PROHEXColorStringNormalizer : NSObject

+ (NSString *)normalizeString:(NSString *)string;

+ (BOOL)isValidHexString:(NSString *)string;

#pragma mark -
#pragma mark - Cleanup
+ (NSString *)replaceInvalidHexCharacters:(NSString *)string;

+ (NSString *)fixHexStringLength:(NSString *)string;

+ (BOOL)getRed:(double_t *)red green:(double_t *)green blue:(double_t *)blue forString:(NSString *)string;

@end

#if TARGET_OS_IPHONE
@import UIKit;

@interface PROHEXColorStringNormalizer (PROMobile)

/**
 *  Get a UIColor from a string.
 *
 *  It is safe to supply this method with user input.
 *
 *  @param string The string to get a hex color from.
 *
 *  @return A UIColor or black if parsing fails
 */
+ (UIColor *)colorFromString:(NSString *)string;

@end
#endif

#endif
