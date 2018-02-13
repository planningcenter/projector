//
//  CreateSessionTableViewCellZero.h
//  Projector
//
//  Created by Peter Fokos on 6/23/14.
//

#import "PCOTableViewCell.h"

@interface CreateSessionTableViewCellZero : PCOTableViewCell

@property (weak, nonatomic) PCOLabel *connectionsLabel;
@property (weak, nonatomic) PCOLabel *allowControlLabel;

+ (CGFloat)heightForCellWithSessionStarted:(BOOL)sessionStarted;

@end
