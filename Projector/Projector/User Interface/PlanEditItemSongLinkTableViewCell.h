//
//  PlanEditItemSongLinkTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 11/14/14.
//

#import "PCOTableViewCell.h"

@interface PlanEditItemSongLinkTableViewCell : PCOTableViewCell

@property (weak, nonatomic) PCOLabel *titleLabel;
@property (nonatomic, weak) UIImageView *accessoryImage;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kPlanEditItemSongLinkTableViewCellIdentifier;
