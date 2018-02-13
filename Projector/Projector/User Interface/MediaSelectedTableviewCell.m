//
//  MediaSelectedTableviewCell.m
//  Projector
//
//  Created by Peter Fokos on 10/13/14.
//

#import "MediaSelectedTableviewCell.h"

#define CELL_HEIGHT 59
#define ACC_IMAGE_SIZE 30

@interface MediaSelectedTableviewCell ()

@property (nonatomic, strong) NSArray *cellContraints;
@property (nonatomic, weak) PCOView *progressView;
@property (nonatomic, weak) NSLayoutConstraint *deleteButtonWidthContraint;

@end

@implementation MediaSelectedTableviewCell

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
    self.cellAccessoryType = MediaSelectedAccessoryTypeChevron;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.mediaImage.image = nil;
    self.titleLabel.text = nil;
    self.subTitleLabel.text = nil;
    self.progressView.hidden = YES;
    _swipeLeft = nil;
    _swipeRight = nil;
    if (self.deleteVisible) {
        [self toggleDeleteAnimated:NO];
    }
    [self setNeedsUpdateConstraints];
}

- (void)toggleDeleteAnimated:(BOOL)animated {
    [self layoutIfNeeded];
    CGFloat width = 0.0;
    if (self.deleteVisible) {
        width = 0;
        self.deleteVisible = NO;
    } else {
        width = 60;
        self.deleteVisible = YES;
    }
    [self removeConstraint:self.deleteButtonWidthContraint];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint pco_width:width forView:self.deleteButton];
    _deleteButtonWidthContraint = widthConstraint;
    [self addConstraint:widthConstraint];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    }
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

//    self.progressFraction = 0.5;
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{
                              @"buffer": @(9),
                              @"acc_size": @(ACC_IMAGE_SIZE),
                              };
    
    NSDictionary *views = @{
                            @"title": self.titleLabel,
                            @"sub_title": self.subTitleLabel,
                            @"media": self.mediaImage,
                            @"accessory": self.accessoryImage,
                            @"progress": self.progressView,
                            };
    
    for (NSString *format in @[
                               @"H:|-buffer-[media(==72)]-buffer-[title]-[accessory(==acc_size)]-buffer-|",
                               @"V:|[accessory]|",
                               @"V:|-buffer-[media]-buffer-|",
                               @"V:[progress(==1)]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
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
    
    [array addObject:[NSLayoutConstraint constraintWithItem:self.progressView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.contentView
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0]];
    
    [array addObject:[NSLayoutConstraint constraintWithItem:self.progressView
                                                  attribute:NSLayoutAttributeWidth
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.contentView
                                                  attribute:NSLayoutAttributeWidth
                                                 multiplier:self.progressFraction
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

- (void)setCellAccessoryType:(MediaSelectedAccessoryType)cellAccessoryType {
    _cellAccessoryType = cellAccessoryType;
    switch (cellAccessoryType) {
        case MediaSelectedAccessoryTypeChevron:
            self.accessoryImage.image = [UIImage imageNamed:@"arrow_icon"];
            break;
        case MediaSelectedAccessoryTypeCheckmark:
            self.accessoryImage.image = [UIImage imageNamed:@"green-circle-check"];
            break;
        default:
            break;
    }
}


- (void)setShowCheckmark:(BOOL)showCheckmark {
    if (self.cellAccessoryType == MediaSelectedAccessoryTypeCheckmark) {
        _showCheckmark = showCheckmark;
        self.accessoryImage.image = [UIImage imageNamed:@"green-circle-check"];
        self.accessoryImage.hidden = !showCheckmark;
    }
}

#pragma mark - Setters
#pragma mark -

- (void)setProgressFraction:(CGFloat)progressFraction {
    _progressFraction = progressFraction;
    self.subTitleLabel.text = NSLocalizedString(@"Downloading", nil);
    self.progressView.hidden = NO;
    if (progressFraction == 1.0) {
        self.subTitleLabel.text = nil;
        self.progressView.hidden = YES;
    }
    [self setNeedsUpdateConstraints];
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

- (PCOView *)progressView {
    if (!_progressView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor projectorOrangeColor];
        view.hidden = YES;
        _progressView = view;
        [self.contentView addSubview:view];
    }
    return _progressView;
}

- (PCOButton *)deleteButton {
    if (!_deleteButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor customSlidesDeleteColor];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
        _deleteButton = button;
        [self addSubview:button];
        [self bringSubviewToFront:button];
        [self addConstraint:[NSLayoutConstraint pco_centerVertical:button inView:self]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
        NSLayoutConstraint *width = [NSLayoutConstraint pco_width:0 forView:button];
        self.deleteVisible = NO;
        
        _deleteButtonWidthContraint = width;
        [self addConstraint:width];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        
    }
    return _deleteButton;
}

-(UISwipeGestureRecognizer *)swipeLeft {
    if (!_swipeLeft) {
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] init];
        [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.contentView addGestureRecognizer:swipe];
        _swipeLeft = swipe;
    }
    return _swipeLeft;
}

- (UISwipeGestureRecognizer *)swipeRight {
    if (!_swipeRight) {
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] init];
        [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.contentView addGestureRecognizer:swipe];
        _swipeRight = swipe;
    }
    return _swipeRight;
}

@end

NSString *const kMediaSelectedTableviewCellIdentifier = @"kMediaSelectedTableviewCellIdentifier";
