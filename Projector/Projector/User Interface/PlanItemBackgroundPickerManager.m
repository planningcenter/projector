/*!
 * PlanItemBackgroundPickerManager.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 2/20/15
 */

#import "PlanItemBackgroundPickerManager.h"
#import "PROSlideManager.h"
#import "PlanItemEditingController.h"

@interface PlanItemBackgroundPickerManager ()

@end

@implementation PlanItemBackgroundPickerManager

- (void)selectAttachment:(PCOAttachment *)attachment {
    if (!attachment) {
        [self setAttachmentToNone];
        return;
    }
    [[PROSlideManager sharedManager] addMediaAttachment:attachment toItem:self.item];
    
    if (self.slide) {
        [[PlanItemEditingController sharedController] changeBackgroundToAttachment:attachment forSlide:self.slide item:self.item plan:self.plan];
    } else {
        [[PlanItemEditingController sharedController] changeBackgroundToAttachment:attachment forItem:self.item inPlan:self.plan];
    }
    
    [[PROSlideManager sharedManager] emptyCacheOfItem:self.item];
}

- (void)setAttachmentToNone {
    if (self.slide) {
        [[PlanItemEditingController sharedController] changeBackgroundToAttachment:nil forSlide:self.slide item:self.item plan:self.plan];
    } else {
        [[PlanItemEditingController sharedController] changeBackgroundToAttachment:nil forItem:self.item inPlan:self.plan];
    }
    [[PROSlideManager sharedManager] emptyCacheOfItem:self.item];
}

@end
