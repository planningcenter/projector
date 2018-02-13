/*!
 * PROSlideHelper.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/19/14
 */

#import "PROSlideHelper.h"

#import "PCOCustomSlide.h"
#import "PCOSequenceItem.h"
#import "PCOStanza.h"
#import "PCOSlideBreak.h"
#import "PCOItem.h"

#define pro_slide_error(_ec, msg) [NSError errorWithDomain:PROSlideHelperErrorDomain code:_ec userInfo:@{NSLocalizedDescriptionKey: msg}]

@interface PROSlideHelper ()

@end

@implementation PROSlideHelper

// MARK: - Custom Slide Server Methods
+ (void)saveCustomSlide:(PCOCustomSlide *)slide itemID:(NSNumber *)itemID completion:(void(^)(NSError *error))completion {
    if (!itemID) {
        if (completion) {
            completion(pro_slide_error(PROSlideHelperErrorBadParam, NSLocalizedString(@"Invalid item ID", nil)));
        }
        return;
    }
    if (!slide) {
        if (completion) {
            completion(pro_slide_error(PROSlideHelperErrorBadParam, NSLocalizedString(@"Invalid slide", nil)));
        }
        return;
    }
    
    NSManagedObjectID *objectID = [slide objectID];
    
    PCOServerRequest *request = nil;
    if ([slide isNew]) {
        request = [PCOServerRequest requestWithFormat:@"/plan_items/%@/custom_slides.json",itemID];
        request.HTTPMethod = HTTPMethodPost;
    } else {
        request = [PCOServerRequest requestWithFormat:@"/plan_items/%@/custom_slides/%@.json",itemID,slide.remoteId];
        request.HTTPMethod = HTTPMethodPatch;
    }
    
    [request setJSONBody:@{@"custom_slide": [slide asHash]}];
    
    [request startWithCompletion:^(PCOServerResponse *response) {
        PCOError(response.error);
        if ([response responseOK] && !response.error) {
            PCOCustomSlide *bSlide = [[PCOCoreDataManager sharedManager] objectWithID:objectID];
            NSDictionary *JSON = [response JSONBody];
            if (JSON[@"id"] && [JSON[@"id"] isKindOfClass:[NSNumber class]]) {
                bSlide.remoteId = JSON[@"id"];
            }
            if (JSON[@"label"] && [JSON[@"label"] isKindOfClass:[NSString class]]) {
                bSlide.label = JSON[@"label"];
            }
            NSError *saveError = nil;
            if (![[PCOCoreDataManager sharedManager] save:&saveError]) {
                if (completion) {
                    completion(saveError);
                }
                return;
            }
        }
        if (completion) {
            completion(response.error);
        }
    }];
}

+ (void)deleteCustomSlide:(NSNumber *)slideID itemID:(NSNumber *)itemID completion:(void(^)(NSError *error))completion {
    if (!itemID) {
        if (completion) {
            completion(pro_slide_error(PROSlideHelperErrorBadParam, NSLocalizedString(@"Invalid item ID", nil)));
        }
        return;
    }
    if (!slideID) {
        if (completion) {
            completion(pro_slide_error(PROSlideHelperErrorBadParam, NSLocalizedString(@"Invalid slide ID", nil)));
        }
        return;
    }
    
    PCOServerRequest *request = [PCOServerRequest requestWithFormat:@"/plan_items/%@/custom_slides/%@.json",itemID,slideID];
    request.HTTPMethod = HTTPMethodDelete;
    
    [request startWithCompletion:^(PCOServerResponse *response) {
        if (completion) {
            completion(response.error);
        }
    }];
}

+ (void)saveCustomSlideOrder:(PCOItem *)item completion:(void(^)(NSError *error))completion {
    if (!item) {
        if (completion) {
            completion(pro_slide_error(PROSlideHelperErrorBadParam, NSLocalizedString(@"Invalid item", nil)));
        }
        return;
    }
    
    NSArray *itemHash = [[item orderedCustomSlides] collectSafe:^id(PCOCustomSlide *object) {
        if (object.remoteId) {
            return @{
                     @"id": object.remoteId,
                     @"order": (object.order) ?: @0
                     };
        }
        return nil;
    }];
    
    PCOServerRequest *request = [PCOServerRequest requestWithFormat:@"/plan_items/%@/custom_slides/order.json",item.remoteId];
    request.HTTPMethod = HTTPMethodPut;
    
    [request setJSONBody:@{@"custom_slides": itemHash}];
    
    [request startWithCompletion:^(PCOServerResponse *response) {
        if (completion) {
            completion(response.error);
        }
    }];
}

// MARK: - Chord Chart
+ (void)saveChordChart:(NSString *)chordChart item:(PCOItem *)item completion:(void(^)(NSError *error))completion {
    if (!item) {
        if (completion) {
            completion(pro_slide_error(PROSlideHelperErrorBadParam, NSLocalizedString(@"Invalid item", nil)));
        }
        return;
    }
    if (!chordChart) {
        if (completion) {
            completion(pro_slide_error(PROSlideHelperErrorBadParam, NSLocalizedString(@"Invalid chord chart", nil)));
        }
        return;
    }
    
    NSString *existingSequence = [self _URLStringForItemSequence:item];
    NSString *chordChartKeyValue = item.arrangement.chordChartKey;
    if (chordChartKeyValue.length == 0) {
        chordChartKeyValue = @"C";
    }
    
    NSDictionary *payload = @{
                              @"arrangement": @{
                                      @"chord_chart_key": chordChartKeyValue,
                                      @"chord_chart": chordChart
                                      }
                              };
    
    PCOServerRequest *request = [PCOServerRequest requestWithFormat:@"/arrangements/%@.json",item.arrangement.remoteId];
    request.HTTPMethod = HTTPMethodPut;
    [request setJSONBody:payload];
    [request startWithCompletion:^(PCOServerResponse *response) {
        if (response.error) {
            if (completion) {
                completion(response.error);
            }
            return;
        }
        if (existingSequence.length > 0) {
            [self updatePlanItemArrangementSequence:item completion:completion];
        } else {
            if (completion) {
                completion(nil);
            }
        }
    }];
}

// MARK: - Internal Helpers
+ (NSString *)_URLStringForItemSequence:(PCOItem *)item {
    NSMutableString * sequenceString = [NSMutableString string];
    
    for (PCOSequenceItem * seqItem in [item orderedArrangementSequence]) {
        if ([sequenceString length] > 0) {
            [sequenceString appendString:@"&"];
        }
        
        [sequenceString appendFormat:@"plan_item[arrangement_sequence][]=%@", [seqItem label]];
    }
    
    return [sequenceString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
+ (void)updatePlanItemArrangementSequence:(PCOItem *)item completion:(void(^)(NSError *error))completion {
    NSDictionary *payload = @{
                              @"plan_item": @{
                                      @"arrangement_sequence": [item sequenceLabels]
                                      }
                              };
    
    PCOServerRequest *request = [PCOServerRequest requestWithFormat:@"/plan_items/%@.json",item.remoteId];
    request.HTTPMethod = HTTPMethodPut;
    [request setJSONBody:payload];
    [request startWithCompletion:^(PCOServerResponse *response) {
        if (completion) {
            completion(response.error);
        }
    }];
}

@end

_PCO_EXTERN_STRING PROSlideHelperErrorDomain = @"PROSlideHelperErrorDomain";
