//
//  MediaPlaylistTableviewCell.m
//  Projector
//
//  Created by Peter Fokos on 10/13/14.
//

#import "MediaPlaylistTableviewCell.h"

#define CELL_HEIGHT 67
#define ACC_IMAGE_SIZE 30

@interface MediaPlaylistTableviewCell ()

@property (nonatomic, strong) NSArray *cellContraints;

@end

@implementation MediaPlaylistTableviewCell

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
    self.backgroundColor = [UIColor mediaSelectedCellBackgroundColor];
    self.clipsToBounds = YES;
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor mediaSelectedCellSelectedColor];
    self.selectedBackgroundView = selectedView;
    self.cellAccessoryType = MediaPlaylistAccessoryTypeChevron;
}

#pragma mark - Layout
#pragma mark -

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    
    if (self.cellContraints) {
        [self.contentView removeConstraints:self.cellContraints];
    }
    
    [super updateConstraints];
    
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{
                              @"buffer": @(9),
                              @"acc_size": @(ACC_IMAGE_SIZE),
                              };
    
    NSDictionary *views = @{
                            @"title": self.titleLabel,
                            @"media": self.mediaImage,
                            @"accessory": self.accessoryImage,
                            };
    
    if (self.mediaImage.image) {
        for (NSString *format in @[
                                   @"H:|-buffer-[media(==40)]-buffer-[title]-buffer-[accessory(==acc_size)]-buffer-|",
                                   @"V:[media(==40)]",
                                   @"V:|[accessory]|",
                                   ]) {
            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
            [array addObjectsFromArray:constraints];
        }
        [array addObject:[NSLayoutConstraint constraintWithItem:self.mediaImage
                                                      attribute:NSLayoutAttributeCenterY
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.contentView
                                                      attribute:NSLayoutAttributeCenterY
                                                     multiplier:1.0
                                                       constant:0.0]];
        
    }
    else {
        for (NSString *format in @[
                                   @"H:|-buffer-[title]-buffer-[accessory(==acc_size)]-buffer-|",
                                   @"V:|[accessory]|",
                                   ]) {
            NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
            [array addObjectsFromArray:constraints];
        }
    }

    [array addObject:[NSLayoutConstraint constraintWithItem:self.subTitleLabel
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.titleLabel
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0]];
    
    [array addObject:[NSLayoutConstraint constraintWithItem:self.subTitleLabel
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.titleLabel
                                                  attribute:NSLayoutAttributeWidth
                                                 multiplier:1.0
                                                   constant:0.0]];
    
    CGFloat titleYAdj = 0.0;
    CGFloat subTitileYAdj = 0.0;
    
    if ([self.subTitleLabel.text length] > 0) {
        titleYAdj = -8.0;
        subTitileYAdj = 8.0;
    }
    
    [array addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.contentView
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0
                                                   constant:titleYAdj]];
    
    [array addObject:[NSLayoutConstraint constraintWithItem:self.subTitleLabel
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.contentView
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0
                                                   constant:subTitileYAdj]];
    
    [self.contentView addConstraints:array];
    self.cellContraints = [NSArray arrayWithArray:array];
    [self.contentView updateConstraintsIfNeeded];
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

- (void)setCellAccessoryType:(MediaPlaylistAccessoryType)cellAccessoryType {
    _cellAccessoryType = cellAccessoryType;
    switch (cellAccessoryType) {
        case MediaPlaylistAccessoryTypeChevron:
            self.accessoryImage.image = [UIImage imageNamed:@"row_arrow_icon"];
            break;
        case MediaPlaylistAccessoryTypeCheckmark:
            self.accessoryImage.image = [UIImage imageNamed:@"green-circle-check"];
            break;
        default:
            break;
    }
}


- (void)setShowCheckmark:(BOOL)showCheckmark {
    if (self.cellAccessoryType == MediaPlaylistAccessoryTypeCheckmark) {
        _showCheckmark = showCheckmark;
        self.accessoryImage.image = [UIImage imageNamed:@"green-circle-check"];
        self.accessoryImage.hidden = !showCheckmark;
    }
}


#pragma mark - Lazy loaders
#pragma mark -

- (PCOLabel *)titleLabel {
    if (!_titleLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor mediaSelectedCellTitleColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.backgroundColor = [UIColor clearColor];
        _titleLabel = label;
        [self.contentView addSubview:label];
    }
    return _titleLabel;
}

- (PCOLabel *)subTitleLabel {
    if (!_subTitleLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize:13];
        label.textColor = [UIColor mediaSelectedCellSubTitleColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.backgroundColor = [UIColor clearColor];
        _subTitleLabel = label;
        [self.contentView addSubview:label];
    }
    return _subTitleLabel;
}

- (UIImageView *)mediaImage {
    if (!_mediaImage) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        view.image = nil;
        view.contentMode = UIViewContentModeCenter;
        view.contentMode = UIViewContentModeScaleAspectFit;
        _mediaImage = view;
        [self.contentView addSubview:view];
    }
    return _mediaImage;
}

- (UIImageView *)accessoryImage {
    if (!_accessoryImage) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        _accessoryImage = view;
        [self.contentView addSubview:view];
    }
    return _accessoryImage;
}


@end

NSString *const kMediaPlaylistTableviewCellIdentifier = @"kMediaPlaylistTableviewCellIdentifier";
