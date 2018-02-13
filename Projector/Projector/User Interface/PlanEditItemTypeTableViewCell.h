//
//  PlanEditItemTypeTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 11/13/14.
//

#import "PCOTableViewCell.h"

typedef NS_ENUM(NSInteger, ItemTypeSelected) {
    ItemTypeSelectedItem                    = 0,
    ItemTypeSelectedHeader                  = 1,
};

typedef void (^PlanEditItemTypeChangeHandler)(ItemTypeSelected index);

@interface PlanEditItemTypeTableViewCell : PCOTableViewCell

@property (nonatomic) ItemTypeSelected index;
@property (weak, nonatomic) PCOButton *itemButton;
@property (weak, nonatomic) PCOButton *headerButton;
@property (nonatomic, copy) PlanEditItemTypeChangeHandler changeHandler;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kPlanEditItemTypeTableViewCellIdentifier;
