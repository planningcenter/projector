/*!
*  HEXNormalizerTests.m
*  Projector
*
*  Created by Skylar Schipper on 6/12/14.
*/

#import <XCTest/XCTest.h>

#define TEST

#import "PROHEXColorStringNormalizer.h"

@interface HEXNormalizerTests : XCTestCase

@end

@implementation HEXNormalizerTests

- (void)testValidateStrings {
    XCTAssertTrue([PROHEXColorStringNormalizer isValidHexString:@"#000"]);
    XCTAssertTrue([PROHEXColorStringNormalizer isValidHexString:@"#000000"]);
    XCTAssertTrue([PROHEXColorStringNormalizer isValidHexString:@"#aabbcc"]);
    XCTAssertTrue([PROHEXColorStringNormalizer isValidHexString:@"abcdef"]);
    XCTAssertTrue([PROHEXColorStringNormalizer isValidHexString:@"222"]);
    XCTAssertTrue([PROHEXColorStringNormalizer isValidHexString:@"fff"]);
    
    XCTAssertFalse([PROHEXColorStringNormalizer isValidHexString:@"#abcdeg"]);
    XCTAssertFalse([PROHEXColorStringNormalizer isValidHexString:@"ffff"]);
    XCTAssertFalse([PROHEXColorStringNormalizer isValidHexString:@"-#abc123"]);
}
- (void)testShortStrings {
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#A"], @"AAAAAA");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#AF"], @"AFAFAF");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#AF23"], @"AF2300");
}
- (void)testBadStrings {
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#Ar"], @"AAAAAA");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#ArF"], @"AFAFAF");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#AFrr23"], @"AF2300");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#AFr💩r23"], @"AF2300");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"🌆💩😡✇😵🐺"], @"000000");
}
- (void)testReplaceStrings {
    XCTAssertEqualObjects([PROHEXColorStringNormalizer replaceInvalidHexCharacters:@"#Ar"], @"#A");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer replaceInvalidHexCharacters:@"#ArF"], @"#AF");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer replaceInvalidHexCharacters:@"#AFrr23"], @"#AF23");
}
- (void)testLongStrings {
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#Aaaaaaaaaa"], @"AAAAAA");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#AFfkavnsalreopwvjnpeqw859302nklfvewvmkladsru89302jnkvlownv"], @"AFFAAE");
    XCTAssertEqualObjects([PROHEXColorStringNormalizer normalizeString:@"#000999000"], @"000999");
}
- (void)testNumberGetters {
    double_t red = 0.0;
    double_t green = 0.0;
    double_t blue = 0.0;
    
    XCTAssertTrue([PROHEXColorStringNormalizer getRed:&red green:&green blue:&blue forString:@"#FFF"]);
    XCTAssertEqualWithAccuracy(red, 255.0, 0.00001);
    XCTAssertEqualWithAccuracy(green, 255.0, 0.00001);
    XCTAssertEqualWithAccuracy(blue, 255.0, 0.00001);
    
    
    XCTAssertTrue([PROHEXColorStringNormalizer getRed:&red green:&green blue:&blue forString:@"000000"]);
    XCTAssertEqualWithAccuracy(red, 0.0, 0.00001);
    XCTAssertEqualWithAccuracy(green, 0.0, 0.00001);
    XCTAssertEqualWithAccuracy(blue, 0.0, 0.00001);
    
    XCTAssertTrue([PROHEXColorStringNormalizer getRed:&red green:&green blue:&blue forString:@"CDCDCD"]);
    XCTAssertEqualWithAccuracy(red, 205.0, 0.00001);
    XCTAssertEqualWithAccuracy(green, 205.0, 0.00001);
    XCTAssertEqualWithAccuracy(blue, 205.0, 0.00001);
}

@end
