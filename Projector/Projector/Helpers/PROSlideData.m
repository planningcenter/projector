/*!
 * PROSlideData.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/18/14
 */

#import "PROSlideData.h"

#import "PCOCustomSlide.h"
#import "PCOStanza.h"

#import "PROSlideStanzaProvider.h"
#import "PROSlideDataStanzaBuilder.h"
#import "PROSlideDataCustomSlideBuilder.h"

@interface PROSlideData_CustomSlide : PROSlideData

+ (NSArray *)slidesWithCustomSlide:(PCOCustomSlide *)slide info:(PROSlideItemInfo)info;

@end
@interface PROSlideData_Stanza : PROSlideData

+ (NSArray *)slidesWithStanza:(PCOStanza *)stanza info:(PROSlideItemInfo)info;

@end

@interface PROSlideData ()

@end

@implementation PROSlideData

+ (NSArray *)slidesWithItem:(PCOItem *)item stanzaProvider:(PROSlideStanzaProvider *)provider info:(PROSlideItemInfo)info {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:30];
    
    if (item.customSlides.count > 0) {
        for (PCOCustomSlide *customSlide in [item orderedCustomSlides]) {
            [array addObjectsFromArray:[PROSlideData_CustomSlide slidesWithCustomSlide:customSlide info:info]];
        }
    } else {
        NSUInteger stanzaCount = item.arrangementSequence.count;
        for (NSUInteger stanzaIndex = 0; stanzaIndex < stanzaCount; stanzaIndex++) {
            PCOStanza *stanza = [provider stanzaAtIndex:stanzaIndex];
            [array addObjectsFromArray:[PROSlideData_Stanza slidesWithStanza:stanza info:info]];
        }
    }
    return [array copy];
}

// MARK: - Copy
- (id)copyWithZone:(NSZone *)zone {
    PROSlideData *data = [[[self class] alloc] init];
    data.continueFromPrevious = [self continuesFromPrevious];
    data.body = [self.body copyWithZone:zone];
    data.title = [self.title copyWithZone:zone];
    data.orderPosition = self.orderPosition;
    return data;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: %p",NSStringFromClass(self.class),self];
    if (self.title) {
        [string appendFormat:@"\n  TITLE: %@",self.title];
    }
    if (self.body) {
        [string appendFormat:@"\n  BODY: %@",self.body];
    }
    if ([self isMultiBackground]) {
        [string appendFormat:@"\n  BG:"];
        [string appendFormat:@"\n    URL: %@",[self.slideBackgroundFileURL lastPathComponent]];
        [string appendFormat:@"\n    THUMB: %@",[self.slideBackgroundFileThumbnailURL lastPathComponent]];
    }
    [string appendString:@"\n>"];
    return [string copy];
}

- (BOOL)isMultiBackground {
    return NO;
}

@end

@implementation PROSlideData_CustomSlide

+ (NSArray *)slidesWithCustomSlide:(PCOCustomSlide *)slide info:(PROSlideItemInfo)info {
    return [PROSlideDataCustomSlideBuilder createCustomSlides:slide slideClass:[self class] info:info];
}
- (instancetype)initWithCustomSlide:(PCOCustomSlide *)slide {
    self = [super init];
    if (self) {
        self.body = [slide.body copy];
        self.title = [slide.label copy];
        self.orderPosition = [slide.order integerValue];
    }
    return self;
}

- (BOOL)isMultiBackground {
    return YES;
}

@end
@implementation PROSlideData_Stanza

+ (NSArray *)slidesWithStanza:(PCOStanza *)stanza  info:(PROSlideItemInfo)info {
    NSUInteger count = info.lineCount;
    if (count < 1) {
        count = 4;
    }
    return [PROSlideDataStanzaBuilder createSlidesForStanza:stanza slideClass:[self class] preferredNumberOfLines:count];
}

@end
