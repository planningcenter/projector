//
//  PlanEditItemNameTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 11/13/14.
//

#import "PCOTableViewCell.h"

typedef void (^PlanEditItemNameChangeHandler)(NSString *name);

@interface PlanEditItemNameTableViewCell : PCOTableViewCell

@property (weak, nonatomic) UITextField *textField;
@property (nonatomic, copy) PlanEditItemNameChangeHandler changeHandler;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kPlanEditItemNameTableViewCellIdentifier;
