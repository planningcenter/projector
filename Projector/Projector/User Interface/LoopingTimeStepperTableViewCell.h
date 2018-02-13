//
//  LoopingTimeStepperTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 10/10/14.
//

#import "PCOTableViewDetailsCell.h"

@interface LoopingTimeStepperTableViewCell : PCOTableViewCell

@property (weak, nonatomic) PCOLabel *titleLabel;
@property (weak, nonatomic) PCOLabel *subTitleLabel;

@property (nonatomic, weak) UIStepper *stepperControl;

@property(nonatomic, retain) UIColor *onTintColor;
@property(nonatomic, retain) UIColor *thumbTintColor;

@end

OBJC_EXTERN NSString *const kLoopingTimeStepperTableViewCellIdentifier;
