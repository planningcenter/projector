//
//  PlanEditItemSongLinkTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 11/14/14.
//

#import "PlanEditItemSongLinkTableViewCell.h"

#define CELL_HEIGHT 60
#define ACCESSORY_IMAGE @"row_arrow_icon"

@interface PlanEditItemSongLinkTableViewCell ()

@property (nonatomic, strong) NSArray *cellContraints;

@end

@implementation PlanEditItemSongLinkTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.backgroundColor = HEX(0x25252a);
    self.backgroundView.backgroundColor = HEX(0x25252a);
    self.clipsToBounds = YES;
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor blackColor];
    self.selectedBackgroundView = selectedView;
    PCOKitLazyLoad(self.titleLabel);
    PCOKitLazyLoad(self.accessoryImage);
}

-(void)prepareForReuse {
    [super prepareForReuse];
    _titleLabel.text = nil;
    [self setNeedsUpdateConstraints];
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOLabel *)titleLabel {
    if (!_titleLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = HEX(0xc8cee0);
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.backgroundColor = [UIColor clearColor];
        _titleLabel = label;
        [self.contentView addSubview:label];
        [self.contentView addConstraints:[NSLayoutConstraint pco_fitView:label inView:self.contentView insets:UIEdgeInsetsMake(0, 40, 0, 40)]];
    }
    return _titleLabel;
}

- (UIImageView *)accessoryImage {
    if (!_accessoryImage) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        view.image = [UIImage imageNamed:ACCESSORY_IMAGE];
        _accessoryImage = view;
        [self.contentView addSubview:view];
        [self.contentView addConstraint:[NSLayoutConstraint pco_centerVertical:view inView:self.contentView]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.contentView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-19.0]];
    }
    return _accessoryImage;
}

@end

NSString *const kPlanEditItemSongLinkTableViewCellIdentifier = @"kPlanEditItemSongLinkTableViewCellIdentifier";

