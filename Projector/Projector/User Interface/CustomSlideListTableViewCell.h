//
//  CustomSlideListTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 10/20/14.
//

#import "LeftHandReorderTableViewCell.h"

@interface CustomSlideListTableViewCell : LeftHandReorderTableViewCell

@property (weak, nonatomic) PCOLabel *titleLabel;
@property (weak, nonatomic) PCOLabel *subTitleLabel;
@property (nonatomic, weak) UIImageView *accessoryImage;
@property (nonatomic, weak) UIImageView *reorderImage;
@property (nonatomic, weak) PCOButton *deleteButton;
@property (nonatomic) BOOL deleteVisible;
@property (nonatomic, weak) UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic, weak) UISwipeGestureRecognizer *swipeRight;

+ (CGFloat)heightForCell;
- (void)toggleDeleteAnimated:(BOOL)animated;
- (void)accessoryTintColor:(UIColor *)color;

@end

OBJC_EXTERN NSString *const kCustomSlideListTableViewCellIdentifier;
