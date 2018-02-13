//
//  PlanItemEditingController.h
//  Projector
//
//  Created by Peter Fokos on 11/4/14.
//

#import <Foundation/Foundation.h>

@interface PlanItemEditingController : NSObject

+ (instancetype)sharedController;

- (void)changeBackgroundToAttachment:(PCOAttachment *)attachment forSlide:(PCOCustomSlide *)slide item:(PCOItem *)item plan:(PCOPlan *)plan;
- (void)changeBackgroundToAttachment:(PCOAttachment *)attachment forItem:(PCOItem *)item inPlan:(PCOPlan *)plan;
- (void)changeItem:(PCOItem *)item backgroundAttachment:(PCOAttachment *)attachment;
- (void)saveBackgroundEditingChangesForItem:(PCOItem *)item inPlan:(PCOPlan *)plan;
- (void)saveEditingChangesLocally;
- (void)addMedia:(PCOMedia *)media toItem:(PCOItem *)item inPlan:(PCOPlan *)plan;
- (void)warnIfNotEditorForPlan:(PCOPlan *)plan;

- (void)changeLayoutOfItem:(PCOItem *)item toLayout:(PCOSlideLayout *)layout inPlan:(PCOPlan *)plan;

- (void)saveArrangementSequenceEditingChangesForItem:(PCOItem *)item inPlan:(PCOPlan *)plan;
- (void)warnIfNotArrangementSequenceEditorForPlan:(PCOPlan *)plan;

- (BOOL)saveSlideBreaksForItem:(PCOItem *)item inPlan:(PCOPlan *)plan withStanza:(PCOStanza *)stanza lyrics:(NSArray *)lyrics completionBlock:(void (^)(void))completionBlock;

- (void)saveLyrics:(NSString *)lyrics forItem:(PCOItem *)item inPlan:(PCOPlan *)plan;

- (void)warnIfNotCustomSlideEditorForPlan:(PCOPlan *)plan;
- (void)saveCustomSlides:(NSArray *)slideIds deletedSlideIds:(NSArray *)deletedSlideIds forItem:(PCOItem *)item inPlan:(PCOPlan *)plan completionBlock:(void (^)(void))completionBlock;

@end

PCO_EXTERN_STRING PlanItemBackgroundChangedNotification;
PCO_EXTERN_STRING PlanItemLayoutChangedNotification;
PCO_EXTERN_STRING ArrangementSequenceChangesNotification;
PCO_EXTERN_STRING SlideNumberText;
