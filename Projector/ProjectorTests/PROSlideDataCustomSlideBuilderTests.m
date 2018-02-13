/*!
 * PROSlideDataCustomSlideBuilderTests.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/20/14
 */

#import <XCTest/XCTest.h>

#import "PROSlideDataCustomSlideBuilder.h"
#import "PROSlideData.h"

@interface PROSlideDataCustomSlideBuilderTests : XCTestCase

@end

@implementation PROSlideDataCustomSlideBuilderTests

#pragma mark -
#pragma mark - Test Methods
- (void)testFontSizing {
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:100.0], 20);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:90.0], 21);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:80.0], 22);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:70.0], 25);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:60.0], 29);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:50.0], 35);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:40.0], 43);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:30.0], 54);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:20.0], 66);
    XCTAssertEqual([PROSlideDataCustomSlideBuilder preferredCharactersPerLineForFontSize:10.0], 82);
}

- (void)testSmartLineBreakGeneration {
    PROSlideItemInfo info = {0};
    info.insets = UIEdgeInsetsZero;
    info.fontSize = 42.0;
    info.lineCount = 6;
    info.performSmartFormatting = YES;
    
    NSString *body = @"Message outline with a lot of text that overflows the slide just like a scripture reference might do. But what if it overflows even more lines than will fit based in the number of lines in the custom layout. It should theoretically make new slides so that it all fits. Here's hoping!";

    NSArray *slides = [PROSlideDataCustomSlideBuilder createCustomSlidesWithText:body label:@"test" background:nil slideClass:[PROSlideData class] info:info orderPostion:0];
    
    XCTAssertNotNil(slides);
    XCTAssertEqual(slides.count, 2);
    
    PROSlideData *first = [slides firstObject];
    PROSlideData *last = [slides lastObject];
    
    NSString *firstSlide = @"Message outline with a lot of text that overflows\nthe slide just like a scripture reference\nmight do. But what if it overflows even more\nlines than will fit based in the number of\nlines in the custom layout. It should theoretically";
    NSString *lastSlide = @"make new slides so that it all fits.\nHere's hoping!";
    
    XCTAssertTrue([first.body isEqualToString:firstSlide], @"\n---\n%@\n---\ndoes not equal\n---\n%@\n---",first.body,firstSlide);
    XCTAssertTrue([last.body isEqualToString:lastSlide], @"\n---\n%@\n---\ndoes not equal\n---\n%@\n---",last.body,lastSlide);
    
    XCTAssertTrue(last.continueFromPrevious);
}

- (void)testSmartLineBreakWithLongerText {
    PROSlideItemInfo info = {0};
    info.insets = UIEdgeInsetsZero;
    info.fontSize = 48.0;
    info.lineCount = 4;
    info.performSmartFormatting = YES;
    
    NSString *body = @"Welcome to the OASIS, a hyper-realistic, 3D, videogame paradise. It's 2045, and pretty much everyone logs in to the OASIS daily to escape their terrible lives, lives affected by overpopulation, unemployment, and energy shortages. Eighteen-year-old Wade Watts is one of these people, and he has a mission: to find an Easter egg hidden inside the OASIS by its wackadoodle creator, James Halliday.";
    
    NSArray *slides = [PROSlideDataCustomSlideBuilder createCustomSlidesWithText:body label:@"test" background:nil slideClass:[PROSlideData class] info:info orderPostion:0];
    
    NSArray *slideText = @[
                           @"Welcome to the OASIS, a hyper-realistic,\n3D, videogame paradise. It's 2045,\nand pretty much everyone logs in to",
                           @"the OASIS daily to escape their terrible lives,\nlives affected by overpopulation,\nunemployment, and energy shortages.",
                           @"Eighteen-year-old Wade Watts is one of\nthese people, and he has a mission:\nto find an Easter egg hidden inside",
                           @"the OASIS by its wackadoodle creator,\nJames Halliday."
                           ];
    
    
    XCTAssertNotNil(slides);
    XCTAssertEqual(slides.count, slideText.count);
    
    for (NSUInteger idx = 0; idx < slides.count; idx++) {
        PROSlideData *data = slides[idx];
        NSString *text = slideText[idx];
        XCTAssertTrue([data.body isEqualToString:text], @"\n---\n%@\n---\ndoes not equal\n---\n%@\n---",data.body,text);
        if (idx > 0) {
            XCTAssertTrue(data.continueFromPrevious);
        } else {
            XCTAssertFalse(data.continueFromPrevious);
        }
    }
}

- (void)testFormattingLineBreakSpace {
    PROSlideItemInfo info = {0};
    info.insets = UIEdgeInsetsZero;
    info.fontSize = 42.0;
    info.lineCount = 4;
    info.performSmartFormatting = YES;
    
    NSString *body = @"Line One\n\nLine Two\nLine Three";
    
    NSArray *slides = [PROSlideDataCustomSlideBuilder createCustomSlidesWithText:body label:@"test" background:nil slideClass:[PROSlideData class] info:info orderPostion:0];
    
    XCTAssertEqual(slides.count, 1);
    
    PROSlideData *data = [slides firstObject];
    XCTAssertEqualObjects(data.body, @"Line One\n:\nLine Two\nLine Three");
}

@end
