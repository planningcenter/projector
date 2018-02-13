//
//  CustomSlideListTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 10/20/14.
//

#import "CustomSlideListTableViewCell.h"

#define CELL_HEIGHT 60
#define ACCESSORY_IMAGE @"row_arrow_icon"

@interface CustomSlideListTableViewCell ()

@property (nonatomic, strong) NSArray *cellContraints;
@property (nonatomic, weak) NSLayoutConstraint *deleteButtonWidthContraint;


@end

@implementation CustomSlideListTableViewCell

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
    self.backgroundView.backgroundColor = [UIColor mediaSelectedCellBackgroundColor];
    self.clipsToBounds = YES;
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor mediaSelectedCellSelectedColor];
    self.selectedBackgroundView = selectedView;
    PCOKitLazyLoad(self.accessoryImage);
    PCOKitLazyLoad(self.reorderImage);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _titleLabel.text = nil;
    _subTitleLabel.text = nil;
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
    }
    else {
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

- (void)accessoryTintColor:(UIColor *)color {
    if (color) {
        self.accessoryImage.image = [UIImage templateImageNamed:ACCESSORY_IMAGE];
        self.tintColor = color;
    }
    else {
        self.accessoryImage.image = [UIImage imageNamed:ACCESSORY_IMAGE];
        self.tintColor = color;
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
    
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{@"buffer": @(9)};
    
    NSDictionary *views = @{
                            @"title": self.titleLabel,
                            };
    
    for (NSString *format in @[
                               @"H:|-buffer-[title]-buffer-|",
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

- (UIImageView *)accessoryImage {
    if (!_accessoryImage) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        view.image = [UIImage imageNamed:ACCESSORY_IMAGE];
        _accessoryImage = view;
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint pco_centerVertical:view inView:self]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.deleteButton
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:-9.0]];
    }
    return _accessoryImage;
}

- (UIImageView *)reorderImage {
    if (!_reorderImage) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"drag-icon"];
        view.image = image;
        view.contentMode = UIViewContentModeCenter;
        _reorderImage = view;
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint pco_centerVertical:view inView:self]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:12.0]];
    }
    return _reorderImage;
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

- (UISwipeGestureRecognizer *)swipeLeft {
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

NSString *const kCustomSlideListTableViewCellIdentifier = @"kCustomSlideListTableViewCellIdentifier";

