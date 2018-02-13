//
//  PlanEditItemArrangementKeyTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 11/14/14.
//

#import "PCOTableViewCell.h"

typedef NS_ENUM(NSInteger, ArrangementKeySelected) {
    ArrangementKeySelectedNone              = 0,
    ArrangementKeySelectedArrangment        = 1,
    ArrangementKeySelectedKey               = 2,
};

typedef void (^PlanEditItemArrangementKeyChangeHandler)(ArrangementKeySelected state);

@interface PlanEditItemArrangementKeyTableViewCell : PCOTableViewCell

@property (nonatomic) ArrangementKeySelected state;
@property (nonatomic, strong) NSString *arrangementTitle;
@property (nonatomic, strong) NSString *keyTitle;
@property (nonatomic, copy) PlanEditItemArrangementKeyChangeHandler changeHandler;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kPlanEditItemArrangementKeyTableViewCellIdentifier;
