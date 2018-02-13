/*!
 * PRODisplayItemBackground.h
 *
 *
 * Created by Skylar Schipper on 7/15/14
 */

#ifndef PRODisplayItemBackground_h
#define PRODisplayItemBackground_h

@import Foundation;
@import UIKit;

@interface PRODisplayItemBackground : NSObject

/**
 *  The color to make the background of the display view
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *  The primary view background file URL.  This  is usualy a video
 */
@property (nonatomic, strong) NSURL *primaryBackgroundURL;

/**
 *  The secondary background URL for a static file.
 */
@property (nonatomic, strong) NSURL *staticBackgroundURL;

/**
 *  The image to use for the static background.  If this is nil, it will try and load from the staticBackgroundURL
 */
@property (nonatomic, strong) UIImage *staticBackgroundImage;

/**
 *  Force a background refresh
 */
@property (nonatomic, getter = shouldForceBackgroundRefresh) BOOL forceBackgroundRefresh;

/**
 *  Primary URL hash
 *
 *  @return The primary URL hash.  If it's nil this will fallback to the static background.
 */
- (NSString *)primaryURLHash;

@end

#endif
