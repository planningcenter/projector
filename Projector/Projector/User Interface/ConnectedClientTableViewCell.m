//
//  ConnectedClientTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 6/19/14.
//

#import "ConnectedClientTableViewCell.h"
#import "UIColor+PROColors.h"

#define CELL_HEIGHT 56

@implementation ConnectedClientTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)prepareForReuse {
    self.contentView.alpha = 1.0;
    self.nameLabel.text = nil;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.backgroundColor = [UIColor sessionsCellNormalBackgroundColor];
    self.clipsToBounds = YES;
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{};
    
    NSDictionary *views = @{
                            @"name_label": self.nameLabel,
                            @"switch": self.switchControl,
                            };
    
    for (NSString *format in @[
                               @"H:|-10-[name_label]-4-[switch]-10-|",
                               @"V:|[name_label]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    [self.contentView addConstraints:array];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.switchControl attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

    [self.contentView updateConstraintsIfNeeded];
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}


#pragma mark - Lazy loaders
#pragma mark -

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor sessionsClientTextColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 2;
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        _nameLabel = label;
        [self.contentView addSubview:label];
    }
    return _nameLabel;
}

- (PROSwitch *)switchControl {
    if (!_switchControl) {
        PROSwitch *view = [[PROSwitch alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
//        view.thumbTintColor = [UIColor sessionsHeaderTextColor];
//        view.tintColor = [UIColor sessionsTintColor];
//        view.onTintColor = [UIColor sessionsTintColor];
//        view.thumbTintColor = [UIColor sessionsHeaderTextColor];
        view.on = NO;
        view.hidden = YES;
        _switchControl = view;
        [self.contentView addSubview:view];
    }
    return _switchControl;
}

@end
