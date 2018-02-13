//
//  PCOAttachment+ProjectorAdditions.m
//  Projector
//
//  Created by Skylar Schipper on 8/14/14.
//

#import "PCOAttachment+ProjectorAdditions.h"

#import "PCOAttachment+AttachmentFile.h"

@implementation PCOAttachment (ProjectorAdditions)

- (BOOL)isProjectorAttachment {
    return ([self isVideo] || [self isSlideshow] || [self isImage] || [self isExpandedAudio]);
}
- (NSString *)thumbnailCacheKey {
    return [[@"thumb_" stringByAppendingString:[self fileCacheKey]] stringByAppendingPathExtension:@"png"];
}

@end
