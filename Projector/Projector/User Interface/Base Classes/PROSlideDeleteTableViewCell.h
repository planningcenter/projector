/*!
 * PROSlideDeleteTableViewCell.h
 *
 *
 * Created by Skylar Schipper on 5/15/14
 */

#ifndef PROSlideDeleteTableViewCell_h
#define PROSlideDeleteTableViewCell_h

#import "PCOSlidingActionCell.h"

@class PROSlideDeleteTableViewCell;

@protocol PROSlideDeleteTableViewCellDelegate;

@interface PROSlideDeleteTableViewCell : PCOSlidingActionCell

@property (nonatomic, assign) id<PROSlideDeleteTableViewCellDelegate> delegate;

@end

@protocol PROSlideDeleteTableViewCellDelegate <NSObject>

- (void)slideCellShouldDelete:(PROSlideDeleteTableViewCell *)cell;

@end

OBJC_EXTERN CGFloat const PROSlideDeleteTableViewCellDeleteOffset; // 100.0

#endif
