/*!
 * PROItemStanzaHelper.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/24/14
 */

#import "PROItemStanzaHelper.h"
#import "PCOSequenceItem.h"
#import "NSCache+PCOCocoaAdditions.h"
#import "PCOStanza.h"
#import "PCOSlideBreak.h"

@interface PROItemStanzaHelper ()

@property (nonatomic, strong) NSCache *itemStanzaIDCache;

@end

@implementation PROItemStanzaHelper

+ (instancetype)shared {
    static PROItemStanzaHelper *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

+ (void)clearCache {
    [[self shared] setItemStanzaIDCache:nil];
}

// MARK: - Lazy Loaders
- (NSCache *)itemStanzaIDCache {
    if (!_itemStanzaIDCache) {
        _itemStanzaIDCache = [[NSCache alloc] init];
    }
    return _itemStanzaIDCache;
}

// MARK: - Public
+ (void)addStanzaWithLabel:(NSString *)label toItem:(PCOItem *)item index:(NSInteger)index {
    if (label.length == 0) {
        return;
    }
    
    PCOSequenceItem *sequence = [PCOSequenceItem objectInContext:item.managedObjectContext];
    sequence.label = label;
    sequence.index = @(index);
    
    for (PCOSequenceItem *seqItem in [item orderedArrangementSequence]) {
        if ([seqItem.index integerValue] >= index) {
            seqItem.index = @([seqItem.index integerValue] + 1);
        }
    }
    
    [item addArrangementSequenceObject:sequence];
    
    [[PCOCoreDataManager sharedManager] save:NULL];
    
    [self clearCache];
}

+ (PCOStanza *)stanzaAtIndex:(NSInteger)index item:(PCOItem *)item {
    NSArray *stanzas = [[[self shared] itemStanzaIDCache] objectForKey:[item.remoteId stringValue] compute:^id(id key) {
        return [self stanzasForIndexesOfItem:item];
    }];
    
    if (![stanzas hasObjectForIndex:index]) {
        return nil;
    }
    
    NSNumber *sIndex = stanzas[index];
    
    return [[[item.arrangement.stanzas filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"index == %@",sIndex]] allObjects] firstObject];
}

+ (NSArray *)stanzasForIndexesOfItem:(PCOItem *)item {
    NSUInteger index = 0;
    for (PCOSequenceItem *sequence in [item orderedArrangementSequence]) {
        sequence.index = @(index);
        index++;
    }
    
    NSString *(^normalizeString)(NSString *) = ^ NSString * (NSString *string) {
        NSString * output = [[[[string lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        output = [output stringByReplacingOccurrencesOfString:@"(" withString:@""];
        output = [output stringByReplacingOccurrencesOfString:@")" withString:@""];
        output = [output stringByReplacingOccurrencesOfString:@"*" withString:@""];
        output = [output stringByReplacingOccurrencesOfString:@"#" withString:@""];
        
        return output;
    };
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:100];
    
    NSUInteger sequenceCount = [item.arrangementSequence count];
    for (NSUInteger idx = 0; idx < sequenceCount; idx++) {
        NSString *label =  [[[item orderedArrangementSequence] objectAtIndex:idx] label];
        NSString *filterLabel = normalizeString(label);
        
        NSSortDescriptor *indexSort = [NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES];
        NSArray *sortedStanzas = [item.arrangement.stanzas sortedArrayUsingDescriptors:@[indexSort]];
        
        PCOStanza *stanza = nil;
        for (PCOStanza *_s in sortedStanzas) {
            NSString *filterStanza = normalizeString(_s.label);
            if ([filterLabel isEqualToString:filterStanza]) {
                stanza = _s;
            }
        }
        
        if (!stanza) {
            stanza = [PCOStanza objectInContext:item.managedObjectContext];
            stanza.label = label;
            stanza.index = @(item.arrangement.stanzas.count);
            [item.arrangement addStanzasObject:stanza];
        }
        
        [array addObject:stanza.index];
    }
    
    return [array copy];
}

+ (void)removeStanzaAtIndex:(NSInteger)index item:(PCOItem *)item {
    PCOSequenceItem *sequence = [[item orderedArrangementSequence] objectAtIndex:index];
    
    [item removeArrangementSequenceObject:sequence];
    
    [[PCOCoreDataManager sharedManager] save:NULL];
    
    [self clearCache];
}

@end
