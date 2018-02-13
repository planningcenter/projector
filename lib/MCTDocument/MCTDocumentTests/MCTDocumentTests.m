//
//  MCTDocumentTests.m
//  MCTDocumentTests
//
//  Created by Skylar Schipper on 3/27/14.
//

#import <XCTest/XCTest.h>
#import "MCTDocument.h"

@interface MCTDocumentTests : XCTestCase

@end

@implementation MCTDocumentTests

- (void)testPPTXParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"EVEOnline" ofType:@"pptx"];
    XCTAssertNotNil(path);

    MCTDocument *document = [[MCTDocument alloc] initWithFilePath:path];
    XCTAssertNotNil(document);
    XCTAssertNotNil(document.filePath);

    XCTAssertEqualObjects([document MD5Checksum], @"c3f8efe1490eca138857f15d5fa6213b");
}

- (void)testPreferredMIMETypes {
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"png"], @"image/png");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"jpg"], @"image/jpeg");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"m4a"], @"audio/x-m4a");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"mp3"], @"audio/mpeg");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"junk"], @"application/octet-stream");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:nil], @"application/octet-stream");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"xlsx"], @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"xltx"], @"application/vnd.openxmlformats-officedocument.spreadsheetml.template");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"potx"], @"application/vnd.openxmlformats-officedocument.presentationml.template");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"ppsx"], @"application/vnd.openxmlformats-officedocument.presentationml.slideshow");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"pptx"], @"application/vnd.openxmlformats-officedocument.presentationml.presentation");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"docx"], @"application/vnd.openxmlformats-officedocument.wordprocessingml.document");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"dotx"], @"application/vnd.openxmlformats-officedocument.wordprocessingml.template");
    XCTAssertEqualObjects([MCTDocument mimeTypeForExtention:@"xlsb"], @"application/vnd.ms-excel.sheet.binary.macroenabled.12");
}

@end
