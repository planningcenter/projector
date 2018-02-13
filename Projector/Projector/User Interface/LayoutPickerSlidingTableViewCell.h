/*!
 * LayoutPickerSlidingTableViewCell.h
 *
 *
 * Created by Skylar Schipper on 5/14/14
 */

#ifndef LayoutPickerSlidingTableViewCell_h
#define LayoutPickerSlidingTableViewCell_h

#import "PCOTableViewCell.h"

@protocol LayoutPickerSlidingTableViewCellDelegate;

@interface LayoutPickerSlidingTableViewCell : PCOTableViewCell

@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, assign) id<LayoutPickerSlidingTableViewCellDelegate> delegate;

@property (nonatomic, weak) PCOLabel *titleLabel;

@property (nonatomic, weak) PCOSlideLayout *layout;

- (void)showButtonsAnimated:(BOOL)animated completion:(void(^)(void))completion;
- (void)hideButtonsAnimated:(BOOL)animated completion:(void(^)(void))completion;

- (BOOL)isOpened;

- (void)prepareForDismiss;

@end

@protocol LayoutPickerSlidingTableViewCellDelegate <NSObject>

- (void)editLayoutButtonAction:(LayoutPickerSlidingTableViewCell *)cell;
- (void)deleteLayoutButtonAction:(LayoutPickerSlidingTableViewCell *)cell;
- (void)applyLayoutButtonAction:(LayoutPickerSlidingTableViewCell *)cell;

- (void)slidingDidBegin:(LayoutPickerSlidingTableViewCell *)cell;

@end

#endif
