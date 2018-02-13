//
//  MediaSwitchTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 10/13/14.
//

#import "PCOTableViewCell.h"
#import "PROSwitch.h"

@interface MediaSwitchTableViewCell : PCOTableViewCell

@property (weak, nonatomic) PCOLabel *titleLabel;
@property (weak, nonatomic) PCOLabel *subTitleLabel;
@property (weak, nonatomic) PROSwitch *mediaSwitch;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kMediaSwitchTableviewCellIdentifier;
