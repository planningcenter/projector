//
//  SequenceReorderTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 10/22/14.
//

#import "SequenceReorderTableViewCell.h"

#define CELL_HEIGHT 44

@implementation SequenceReorderTableViewCell

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

@end

NSString *const kSequenceReorderTableViewCellIdentifier = @"kSequenceReorderTableViewCellIdentifier";
