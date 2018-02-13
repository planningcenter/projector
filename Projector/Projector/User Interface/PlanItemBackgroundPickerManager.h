/*!
 * PlanItemBackgroundPickerManager.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 2/20/15
 */

#ifndef Projector_PlanItemBackgroundPickerManager_h
#define Projector_PlanItemBackgroundPickerManager_h

@import Foundation;

#import "PCOPlan.h"
#import "PCOItem.h"
#import "PCOCustomSlide.h"
#import "PCOAttachment.h"

@interface PlanItemBackgroundPickerManager : NSObject

@property (nonatomic, weak) PCOPlan *plan;
@property (nonatomic, weak) PCOItem *item;
@property (nonatomic, weak) PCOCustomSlide *slide;

- (void)selectAttachment:(PCOAttachment *)attachment;

@end

#endif
