/*!
 * MediaItemImageProvider.h
 *
 *
 * Created by Skylar Schipper on 3/26/14
 */

#ifndef MediaItemImageProvider_h
#define MediaItemImageProvider_h

#import <Foundation/Foundation.h>

@interface MediaItemImageProvider : NSObject

@property (nonatomic, weak) PCOMedia *media;

- (void)getImage:(void(^)(NSNumber *remoteID, UIImage *image))handler;

@end

#endif
