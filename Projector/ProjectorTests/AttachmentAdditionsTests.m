/*!
*  AttachmentAdditionsTests.m
*  Projector
*
*  Created by Skylar Schipper on 8/20/14.
*/

#import <XCTest/XCTest.h>
#import "PCOAttachment+ProjectorAdditions.h"

@interface AttachmentAdditionsTests : XCTestCase

@end

@implementation AttachmentAdditionsTests

- (void)testAttachmentThumbCacheKey {
    PCOAttachment *attachment = [PCOAttachment object];
    attachment.updatedAt = [NSDate dateWithTimeIntervalSince1970:10.0];
    attachment.attachmentId = @"test_attachment-1";
    attachment.filename = @"my-test.mov";
    
    XCTAssertEqualObjects([attachment fileCacheKey], @"test_attachment-1_10_my-test.mov");
    XCTAssertEqualObjects([attachment thumbnailCacheKey], @"thumb_test_attachment-1_10_my-test.mov.png");
}

@end
