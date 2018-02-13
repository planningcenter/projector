/*!
 * PROSlideStanzaProvider.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/18/14
 */

#import "PROSlideStanzaProvider.h"
#import "PCOSequenceItem.h"
#import "PCOStanza.h"

@interface PROSlideStanzaProvider ()

@property (nonatomic, weak) PCOItem *item;

@property (nonatomic, strong) NSArray *cache;

@end

@implementation PROSlideStanzaProvider

+ (instancetype)providerWithItem:(PCOItem *)item {
    PROSlideStanzaProvider *p = [[self alloc] init];
    p.item = item;
    return p;
}

- (PCOStanza *)stanzaAtIndex:(NSUInteger)index {
    if (self.cache.count == 0) {
        [self buildCache];
    }
    if (![self.cache hasObjectForIndex:index]) {
        return nil;
    }
    NSNumber *_index = self.cache[index];
    return [[[self.item.arrangement.stanzas filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"index == %@",_index]] allObjects] firstObject];
}

- (void)buildCache {
    self.cache = nil;
    
    NSMutableArray *cache = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray *cacheSeq = [NSMutableArray arrayWithCapacity:100];
    
    NSArray *orderedArrangementSequence = [self.item orderedArrangementSequence];
    
    NSUInteger index = 0;
    for (PCOSequenceItem *seq in orderedArrangementSequence) {
        seq.index = @(index);
        index++;
        [cacheSeq addObject:[seq asHash]];
    }
    
    for (NSUInteger idx = 0; idx < orderedArrangementSequence.count; idx++) {
        NSString *label = [orderedArrangementSequence[idx] label];
        NSString *normalizedLabel = [PROSlideStanzaProvider normalizedStanzaStringForCompare:label];
        
        PCOStanza *foundStanza = nil;
        
        NSSortDescriptor *indexSort = [NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES];
        NSArray *sortedStanzas = [self.item.arrangement.stanzas sortedArrayUsingDescriptors:@[indexSort]];
        
        for (PCOStanza *stanza in sortedStanzas) {
            NSString *normalizedStanzaLabel = [PROSlideStanzaProvider normalizedStanzaStringForCompare:stanza.label];
            if ([normalizedStanzaLabel isEqualToString:normalizedLabel]) {
                foundStanza = stanza;
                break;
            }
        }
        
        if (!foundStanza) {
            foundStanza = [PCOStanza objectInContext:[self.item managedObjectContext]];
            foundStanza.label = label;
            foundStanza.index = @(self.item.arrangement.stanzas.count);
            [self.item.arrangement addStanzasObject:foundStanza];
        }
        
        [cache addObject:foundStanza.index];
    }
    self.cache = [cache copy];
}

+ (NSString *)normalizedStanzaStringForCompare:(NSString *)string {
    NSString *output = [string lowercaseString];
    output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableString *strippedString = [NSMutableString stringWithCapacity:output.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:output];
    
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"-()*# "] invertedSet];
    
    while (!scanner.isAtEnd) {
        NSString *buffer = nil;
        if ([scanner scanCharactersFromSet:set intoString:&buffer]) {
            [strippedString appendString:buffer];
        } else {
            scanner.scanLocation = scanner.scanLocation + 1;
        }
    }
    
    return [strippedString copy];
}

@end
