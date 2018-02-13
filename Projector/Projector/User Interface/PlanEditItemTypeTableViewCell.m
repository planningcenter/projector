//
//  PlanEditItemTypeTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 11/13/14.
//

#import "PlanEditItemTypeTableViewCell.h"

#define CELL_HEIGHT 60

@implementation PlanEditItemTypeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = HEX(0x25252a);
    self.backgroundView.backgroundColor = HEX(0x393940);
    self.index = 0;
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

#pragma mark - Layout
#pragma mark -

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    
    [self.contentView removeConstraints:self.constraints];
    
    [super updateConstraints];
    
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{};
    
    NSDictionary *views = @{
                            @"item": self.itemButton,
                            @"header": self.headerButton,
                            };
    
    for (NSString *format in @[
                               @"H:|[item]-1-[header(==item)]|",
                               @"V:|[item]|",
                               @"V:|[header]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    [self.contentView addConstraints:array];
    [self.contentView updateConstraintsIfNeeded];
}

- (void)setIndex:(ItemTypeSelected)index {
    _index = index;
    switch (index) {
        case 0:
            self.itemButton.selected = YES;
            self.headerButton.selected = NO;
            break;
        case 1:
            self.itemButton.selected = NO;
            self.headerButton.selected = YES;
            break;

        default:
            break;
    }
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOButton *)itemButton {
    if (!_itemButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:HEX(0x25252A) forState:UIControlStateNormal];
        [button setBackgroundColor:HEX(0x313137) forState:UIControlStateSelected];
        [button setTitle:NSLocalizedString(@"Item", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(itemButtonTouched:) forControlEvents:UIControlEventTouchDown];
        [button setImage:[UIImage imageNamed:@"green-circle-check"] forState:UIControlStateSelected];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -80, 0, 0);
        [self.contentView addSubview:button];
        _itemButton = button;
    }
    return _itemButton;
}

- (PCOButton *)headerButton {
    if (!_headerButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:HEX(0x25252A) forState:UIControlStateNormal];
        [button setBackgroundColor:HEX(0x313137) forState:UIControlStateSelected];
        [button setTitle:NSLocalizedString(@"Header", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(headerButtonTouched:) forControlEvents:UIControlEventTouchDown];
        [button setImage:[UIImage imageNamed:@"green-circle-check"] forState:UIControlStateSelected];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -80, 0, 0);
        [self.contentView addSubview:button];
        _headerButton = button;
    }
    return _headerButton;
}

#pragma mark -
#pragma mark - Action Methods

- (void)itemButtonTouched:(id)sender {
    self.index = ItemTypeSelectedItem;
    if (_changeHandler) {
        self.changeHandler(self.index);
    }
}

- (void)headerButtonTouched:(id)sender {
    self.index = ItemTypeSelectedHeader;
    if (_changeHandler) {
        self.changeHandler(self.index);
    }
}


@end

NSString *const kPlanEditItemTypeTableViewCellIdentifier = @"kPlanEditItemTypeTableViewCellIdentifier";
