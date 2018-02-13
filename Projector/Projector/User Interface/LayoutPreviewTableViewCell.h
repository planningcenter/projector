//
//  LayoutPreviewTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 12/8/14.
//

#import "MediaSelectedTableviewCell.h"

@class PCOSlideLayout;

@interface LayoutPreviewTableViewCell : MediaSelectedTableviewCell

@property (nonatomic, weak) PCOSlideLayout *layout;

@end

OBJC_EXTERN NSString *const kLayoutPreviewTableViewCellIdentifier;
