//
//  PRORecordingListTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 6/3/15.
//

#import "PCOTableViewCell.h"

@interface PRORecordingListTableViewCell : PCOTableViewCell

- (void)showCheckMark:(BOOL)show;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kPRORecordingListTableViewCellIdentifier;
