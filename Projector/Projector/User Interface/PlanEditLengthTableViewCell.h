//
//  PlanEditLengthTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 11/13/14.
//

#import "PCOTableViewCell.h"

typedef void (^PlanEditItemLengthChangeHandler)(NSNumber *length);

@interface PlanEditLengthTableViewCell : PCOTableViewCell <UITextFieldDelegate>

@property (nonatomic, copy) PlanEditItemLengthChangeHandler changeHandler;
@property (nonatomic, strong) NSNumber *length;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kPlanEditLengthTableViewCellIdentifier;
