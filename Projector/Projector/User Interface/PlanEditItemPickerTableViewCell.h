//
//  PlanEditItemPickerTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 11/14/14.
//

#import "PCOTableViewCell.h"

typedef void (^PlanEditItemPickerChangeHandler)(NSInteger index);

@interface PlanEditItemPickerTableViewCell : PCOTableViewCell

@property (nonatomic, copy) PlanEditItemPickerChangeHandler changeHandler;
@property (nonatomic) NSInteger index;
@property (strong, nonatomic) NSArray *choices;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kPlanEditItemPickerTableViewCellIdentifier;
