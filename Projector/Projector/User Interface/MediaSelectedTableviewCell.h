//
//  MediaSelectedTableviewCell.h
//  Projector
//
//  Created by Peter Fokos on 10/13/14.
//

#import "PCOTableViewCell.h"

typedef NS_ENUM(NSInteger, MediaSelectedAccessoryType) {
    MediaSelectedAccessoryTypeChevron       = 0,
    MediaSelectedAccessoryTypeCheckmark     = 1,
};


@interface MediaSelectedTableviewCell : PCOTableViewCell

@property (weak, nonatomic) PCOLabel *titleLabel;
@property (weak, nonatomic) PCOLabel *subTitleLabel;
@property (nonatomic, weak) UIImageView *mediaImage;
@property (nonatomic, weak) UIImageView *accessoryImage;
@property (nonatomic) MediaSelectedAccessoryType cellAccessoryType;
@property (nonatomic) BOOL showCheckmark;
@property (nonatomic) CGFloat progressFraction;

@property (nonatomic, weak) PCOButton *deleteButton;
@property (nonatomic) BOOL deleteVisible;
@property (nonatomic, weak)UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic, weak)UISwipeGestureRecognizer *swipeRight;

+ (CGFloat)heightForCell;

- (void)toggleDeleteAnimated:(BOOL)animated;

@end

OBJC_EXTERN NSString *const kMediaSelectedTableviewCellIdentifier;
