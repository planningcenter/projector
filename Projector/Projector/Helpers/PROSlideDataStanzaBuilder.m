/*!
 * PROSlideDataStanzaBuilder.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/18/14
 */

#import "PROSlideDataStanzaBuilder.h"
#import "PCOSlideBreak.h"
#import "PCOStanza.h"
#import "PROSlideData.h"

@interface NSString (PROSlideDataStanzaBuilder)

- (NSArray *)stanzaBuilderLines;
- (NSUInteger)stanzaBuilderLineCount;

@end

@interface PROSlideDataStanzaBuilder ()

@end

@implementation PROSlideDataStanzaBuilder

+ (NSArray *)createSlidesForStanza:(PCOStanza *)stanza slideClass:(Class)klass preferredNumberOfLines:(NSUInteger)lineCount {
    NSArray *components = [stanza.lyrics stanzaBuilderLines];
    
    if (components.count == 0) {
        PROSlideData *data = [[klass alloc] init];
        data.body = @"";
        data.title = [stanza.label copy];
        data.continueFromPrevious = NO;
        return @[data];
    } else {
        return [self createSlidesForStanza:stanza slideClass:klass preferredNumberOfLines:lineCount components:components];
    }
    
    return @[];
}

+ (NSArray *)createSlidesForStanza:(PCOStanza *)stanza slideClass:(Class)klass preferredNumberOfLines:(NSUInteger)lineCount components:(NSArray *)components {
    PCOSlideBreak *slideBreak = [self slideBreakForStanza:stanza preferredNumberOfLines:lineCount];
    BOOL shouldAutoBreak = (slideBreak == nil);
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    NSUInteger index = 0;
    NSUInteger continueIndex = 0;
    PROSlideData *slide = nil;
    
    for (NSString *line in components) {
        if (!slide) {
            slide = [[klass alloc] init];
            slide.title = [stanza.label copy];
            slide.body = @"";
            
            if (continueIndex > 0) {
                slide.continueFromPrevious = YES;
            }
            
            [array addObject:slide];
        }
        
        if (slide.body.length > 0) {
            slide.body = [slide.body stringByAppendingString:@"\n"];
        }
        
        if ([[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
            slide.body = [slide.body stringByAppendingString:line];
        } else {
            slide.body = [slide.body stringByAppendingString:@" "];
        }
        
        if (shouldAutoBreak && [slide.body stanzaBuilderLineCount] == lineCount) {
            slide = nil;
            continueIndex++;
        }
        
        if (slideBreak) {
            for (NSInteger breakIndex = 0; breakIndex < [slideBreak numberOfManualSlideBreaksAfterLineAtIndex:index]; breakIndex++) {
                slide = [[klass alloc] init];
                
                slide.body = @"";
                slide.title = [stanza.label copy];
                
                slide.continueFromPrevious = YES;
                
                [array addObject:slide];
            }
        }
        
        index++;
    }
    
    return [array copy];
}


+ (PCOSlideBreak *)slideBreakForStanza:(PCOStanza *)stanza preferredNumberOfLines:(NSUInteger)lineCount {
    for (PCOSlideBreak *b in stanza.breaks) {
        if ([b numberOfLinesPerSlide] == (NSInteger)lineCount) {
            return b;
        }
    }
    return nil;
}

@end


@implementation NSString (PROSlideDataStanzaBuilder)

- (NSArray *)stanzaBuilderLines {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    [self enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (line.length > 0) {
            [array addObject:line];
        }
    }];
    return array;
}
- (NSUInteger)stanzaBuilderLineCount {
    return [[self stanzaBuilderLines] count];
}

@end
