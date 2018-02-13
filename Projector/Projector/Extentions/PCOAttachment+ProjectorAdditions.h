//
//  PCOAttachment+ProjectorAdditions.h
//  Projector
//
//  Created by Skylar Schipper on 8/14/14.
//

#import "PCOAttachmentCore.h"

@interface PCOAttachment (ProjectorAdditions)

- (BOOL)isProjectorAttachment;

- (NSString *)thumbnailCacheKey;

@end
