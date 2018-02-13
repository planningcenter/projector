//
//  ConnectedClientTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 6/19/14.
//

#import "PCOTableViewCell.h"
#import "PROSwitch.h"

@interface ConnectedClientTableViewCell : PCOTableViewCell

@property (weak, nonatomic) UILabel *nameLabel;
@property (nonatomic, weak) PROSwitch *switchControl;

+ (CGFloat)heightForCell;

@end
