/*!
 * PROSlideDataCustomSlideBuilder.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/18/14
 */

#import "PROSlideDataCustomSlideBuilder.h"
#import "PCOCustomSlide.h"
#import "PROSlideData.h"
#import "PROSlideManager.h"
#import "PCOAttachment.h"
#import "PCOAttachment+ProjectorAdditions.h"

#define CUSTOM_SLIDE_BREAK @":::"
#define CUSTOM_LINE_BREAK @"::"

#define PUNCTUATION_FORCE_WRAP(count) floor(count * 0.9)
#define MAX_WORD_LENGTH_FOR_NEXT_WRAP 7

@interface PROSlideDataCustomSlideBuilder ()

@end

@implementation PROSlideDataCustomSlideBuilder

+ (NSArray *)createCustomSlides:(PCOCustomSlide *)slide slideClass:(Class)klass info:(PROSlideItemInfo)info {
    info.performSmartFormatting = [slide.performSmartFormatting boolValue];
    return [self createCustomSlidesWithText:slide.body label:slide.label background:[slide selectedBackgroundAttachment] slideClass:klass info:info orderPostion:[slide.order integerValue]];
}
+ (NSArray *)createCustomSlidesWithText:(NSString *)slideText label:(NSString *)label background:(PCOAttachment *)attachment slideClass:(Class)klass info:(PROSlideItemInfo)info orderPostion:(NSInteger)orderPosition {
    if (!slideText) {
        slideText = @"";
    }
    NSArray *brokenSlides = [self customSlideBreaks:slideText];
    NSMutableArray *slides = [NSMutableArray arrayWithCapacity:8];
    
    for (NSString *lines in brokenSlides) {
        NSArray *_lines = [self createSmartLines:lines info:info];
        
        if (_lines.count > info.lineCount) {
            [slides addObjectsFromArray:[self createCustomSlidesWithLabel:label slideClass:klass lines:_lines info:info orderPostion:orderPosition]];
        } else {
            PROSlideData *data = [[klass alloc] init];
            data.title = [label copy];
            NSString *fixedString = [[_lines componentsJoinedByString:@"\n"] stringByReplacingOccurrencesOfString:CUSTOM_LINE_BREAK withString:@"  "];
            data.body = fixedString;
            data.orderPosition = orderPosition;
            [slides addObject:data];
        }
    }
    
    NSUInteger idx = 0;
    for (PROSlideData *data in slides) {
        if (idx > 0) {
            data.continueFromPrevious = YES;
        }
        if (attachment) {
            NSString *key = [attachment fileCacheKey];
            NSString *name = [attachment filename];
            NSString *thumb = [attachment thumbnailCacheKey];
            data.slideBackgroundFileURL = [[PROSlideManager sharedManager] URLForAttachmentFile:name cacheKey:key];
            data.slideBackgroundFileThumbnailURL = [[PROSlideManager sharedManager] URLForAttachmentFileThumbnail:thumb];
        }
        idx++;
    }
    
    return [slides copy];
}

// Creates an array of string broken on `CUSTOM_SLIDE_BREAK`
+ (NSArray *)customSlideBreaks:(NSString *)breaks {
    return [breaks componentsSeparatedByString:CUSTOM_SLIDE_BREAK];
}

// Breaks the string into lines first on `CUSTOM_LINE_BREAK` then by words
+ (NSArray *)createSmartLines:(NSString *)body info:(PROSlideItemInfo)info {
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:6];
    NSArray *compLines = [body componentsSeparatedByString:CUSTOM_LINE_BREAK];
    
    for (NSString *line in compLines) {
        [line enumerateLinesUsingBlock:^(NSString *myLine, BOOL *stop) {
            if (myLine.length > 0) {
                [lines addObject:myLine];
            } else {
                [lines addObject:CUSTOM_LINE_BREAK];
            }
        }];
    }
    
    if (info.performSmartFormatting) {
        NSArray *tempLines = [lines copy];
        [lines removeAllObjects];
        NSUInteger charCount = [self preferredCharactersPerLineForFontSize:info.fontSize];
        for (NSString *line in tempLines) {
            if (line.length > charCount) {
                [lines addObjectsFromArray:[self linesByWordBreakingLine:line fontSize:info.fontSize]];
            } else {
                [lines addObject:line];
            }
        }
    }
    
    return [lines copy];
}

// Creates custom slides if the slides should
+ (NSArray *)createCustomSlidesWithLabel:(NSString *)label slideClass:(Class)klass lines:(NSArray *)lines info:(PROSlideItemInfo)info orderPostion:(NSInteger)orderPosition {
    if (lines.count <= info.lineCount) {
        PROSlideData *data = [[klass alloc] init];
        data.title = [label copy];
        data.body = [lines componentsJoinedByString:@"\n"];
        data.orderPosition = orderPosition;
        return @[data];
    }
    
    NSUInteger targetLines = info.lineCount;
    BOOL addToFirst = NO;
    BOOL borrowFromPreviousLastSlide = NO;

    // Perform logic if the target number of lines isn't perfect
    if (info.performSmartFormatting && lines.count % info.lineCount != 0) {
        float_t lineCount = (float_t)info.lineCount / (float_t)lines.count;
        if (floor(lineCount) <= 1.0) { // If there are say 7 lines in a 6 line layout, this corrects for 2 lines being used
            targetLines = info.lineCount;
        } else {
            targetLines = (NSUInteger)ceilf(lineCount);
        }
        
        // Correct slide layout for minimum
        if (lines.count % targetLines == 1 && info.lineCount > 2) {
            float_t slideCount = ((float_t)lines.count / (float_t)targetLines);

            // Don't reduce the number of lines if there are a bunch of slides already.  Just have a 1 slide line
            if (slideCount < 4) {
                targetLines--;
                if (targetLines <= 1) { // This is here insted of in the first for because we still want the add to first logic to run
                    targetLines++;
                }
                // If there is 1 line on the last slide and we can reduce total slides without dropping to 1 per slide we'll do that.
                if (lines.count % targetLines == 1 && info.lineCount > 2) {
                    // If we've reduced the number lines and we still have a 1 line slide add to the first slide
                    addToFirst = YES;
                }
            } else {
                // Pull a line off the previous slides.
                borrowFromPreviousLastSlide = YES;

                if (targetLines - 1 < 2) {
                    // Don't do that if it would leave the 2nd to last slide with only 1 line
                    borrowFromPreviousLastSlide = NO;
                }

            }
        }
        
        // Last check to fix the target lines just in case.
        targetLines = MIN(targetLines, info.lineCount);
    }

    NSArray *slides = [self joinLines:lines linesPerGroup:targetLines flag1:addToFirst flag2:borrowFromPreviousLastSlide];
    
    NSMutableArray *final = [NSMutableArray arrayWithCapacity:slides.count];
    for (NSString *string in slides) {
        NSString *fixedString = [string stringByReplacingOccurrencesOfString:CUSTOM_LINE_BREAK withString:@"  "];
        PROSlideData *data = [[klass alloc] init];
        data.title = [label copy];
        data.body = fixedString;
        data.orderPosition = orderPosition;
        if (final.count > 0) {
            data.continueFromPrevious = YES;
        }
        [final addObject:data];
    }
    
    return [final copy];
}

// Creates an array of strings for each line in the passed in line
+ (NSArray *)linesByWordBreakingLine:(NSString *)line fontSize:(CGFloat)fontSize {
    NSArray *components = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] collectSafe:^id(id object) {
        if ([object length] > 0) {
            return object;
        }
        return nil;
    }];
    
    NSUInteger preferredCharacters = [self preferredCharactersPerLineForFontSize:fontSize];
    NSUInteger targetLines = line.length / preferredCharacters;
    NSUInteger wordsPerLine = components.count / targetLines;
    
    if (wordsPerLine == components.count) {
        return @[line];
    }
    
    BOOL(^isLastPunctuation)(NSString *) = ^ BOOL (NSString *string) {
        if (string.length > 0) {
            NSString *last = [string substringFromIndex:string.length - 1];
            if (last.length > 0 && [[last stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]] length] == 0) {
                return YES;
            }
        }
        return NO;
    };
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:targetLines];
    NSMutableString *newLine = nil;
    NSUInteger currentWordIndex = 0;
    NSUInteger currentIndex = 0;
    for (NSString *word in components) {
        if (!newLine) {
            newLine = [NSMutableString string];
        }
        
        [newLine appendString:word];
        [newLine appendString:@" "];
        
        currentWordIndex++;
        BOOL newLineStart = NO;
        BOOL forceWrap = NO;
        if (currentWordIndex > wordsPerLine) {
            // Got enough words, new line time
            newLineStart = YES;
        } else if (currentWordIndex == wordsPerLine && isLastPunctuation(word)) {
            // If the last character of the "word" is punctuation, we're going to wrap early because it reads better
            newLineStart = YES;
            forceWrap = YES;
        } else if (newLine.length > preferredCharacters) {
            // Lines to long, new line
            newLineStart = YES;
            forceWrap = YES;
        }
        
        if (isLastPunctuation(word) && newLine.length > PUNCTUATION_FORCE_WRAP(preferredCharacters)) {
            // If the current word ends in punctuation and it's long enough, wrap
            newLineStart = YES;
            forceWrap = YES;
        }
        
        if (newLineStart && !forceWrap) {
            // If we're not forcing the wrap and the nex word has punctuation and isn't long, put it on this line and break on punctuation
            if ([components hasObjectForIndex:currentIndex + 1]) {
                NSString *nextWord = components[currentIndex + 1];
                if (nextWord.length < MAX_WORD_LENGTH_FOR_NEXT_WRAP && nextWord.length > 0 && isLastPunctuation(nextWord)) {
                    newLineStart = NO;
                }
            }
        }
        
        if (newLineStart) {
            // Start a new line
            currentWordIndex = 0;
            [array addObject:[newLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            newLine = nil;
        }
        
        currentIndex++;
    }
    
    if (newLine.length > 0) {
        [array addObject:[newLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
    
    return [array copy];
}

+ (NSUInteger)preferredCharactersPerLineForFontSize:(CGFloat)fontSize {
    // This should make a curve of values
    /**
     *    | *
     *    |  *
     *    |    *
     *    |      *
     *    |         *
     *    |             *
     *    |                 *
     *    |                      *
     *    |                           *
     *    |                                 *
     *    |                                         *
     *    |                                                 *
     *    ____________________________________________________
     *
     *    Something kinda like that.
     */
    return ceil(pow((100.0 - fontSize), 2.45) * 0.001) + 20.0;
}


// flag1: Add line to first group
// flag2: Borrow line from 2nd to last group
+ (NSArray<NSString *> *)joinLines:(NSArray<NSString *> *)lines linesPerGroup:(NSUInteger)count flag1:(BOOL)flag1 flag2:(BOOL)flag2 {
    NSMutableArray *slides = [NSMutableArray arrayWithCapacity:count];

    NSUInteger index = 0;
    while (index < lines.count) {
        NSRange range = NSMakeRange(index, count);
        if (flag1 && index == 0) {
            range.length += 1;
        }
        if (NSMaxRange(range) > lines.count) {
            range.length = lines.count - range.location;
        }

        NSArray *sub = [lines subarrayWithRange:range];

        [slides addObject:sub];

        index += count;
    }

    if (flag2 && slides.count >= 2) {
        NSUInteger oneIndex = slides.count - 1;
        NSUInteger twoIndex = slides.count - 2;
        NSArray *one = [slides objectAtIndex:oneIndex];
        NSArray *two = [slides objectAtIndex:twoIndex];

        NSArray *last = [two lastObject];
        NSArray *twoFinal = [two subarrayWithRange:NSMakeRange(0, two.count - 1)];
        if (twoFinal.count > 1) {
            NSMutableArray *oneFinal = [one mutableCopy];
            [oneFinal insertObject:last atIndex:0];
            [slides replaceObjectAtIndex:twoIndex withObject:twoFinal];
            [slides replaceObjectAtIndex:oneIndex withObject:oneFinal];
        }
    }

    return [slides collect:^id(NSArray *sub) {
        return [sub componentsJoinedByString:@"\n"];
    }];
}

@end
