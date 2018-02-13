//
//  MediaPlaylistTableviewCell.h
//  Projector
//
//  Created by Peter Fokos on 10/13/14.
//

#import "PCOTableViewCell.h"

typedef NS_ENUM(NSInteger, MediaPlaylistAccessoryType) {
    MediaPlaylistAccessoryTypeChevron       = 0,
    MediaPlaylistAccessoryTypeCheckmark     = 1,
};

@interface MediaPlaylistTableviewCell : PCOTableViewCell

@property (weak, nonatomic) PCOLabel *titleLabel;
@property (weak, nonatomic) PCOLabel *subTitleLabel;
@property (nonatomic, weak) UIImageView *mediaImage;
@property (nonatomic, weak) UIImageView *accessoryImage;
@property (nonatomic) MediaPlaylistAccessoryType cellAccessoryType;
@property (nonatomic) BOOL showCheckmark;

+ (CGFloat)heightForCell;

@end

OBJC_EXTERN NSString *const kMediaPlaylistTableviewCellIdentifier;
