//
//  PlanEditItemArrangementKeyTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 11/14/14.
//

#import "PlanEditItemArrangementKeyTableViewCell.h"

#define CELL_HEIGHT 60

@interface PlanEditItemArrangementKeyTableViewCell ()

@property (weak, nonatomic) PCOButton *arrangementButton;
@property (weak, nonatomic) PCOButton *keyButton;

@end

@implementation PlanEditItemArrangementKeyTableViewCell

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
                            @"arrangement": self.arrangementButton,
                            @"key": self.keyButton,
                            };
    
    for (NSString *format in @[
                               @"H:|[arrangement]-1-[key(==150)]|",
                               @"V:|[arrangement]|",
                               @"V:|[key]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    [self.contentView addConstraints:array];
    [self.contentView updateConstraintsIfNeeded];
}

#pragma mark - Setters
#pragma mark -

- (void)setState:(ArrangementKeySelected)state {
    _state = state;
    switch (state) {
        case ArrangementKeySelectedArrangment:
        {
            self.arrangementButton.selected = YES;
            self.keyButton.selected = NO;
            break;
        }
        case ArrangementKeySelectedKey:
        {
            self.arrangementButton.selected = NO;
            self.keyButton.selected = YES;
            break;
        }
        case ArrangementKeySelectedNone:
        {
            self.arrangementButton.selected = NO;
            self.keyButton.selected = NO;
        }
        default:
            break;
    }
}

- (void)setArrangementTitle:(NSString *)arrangementTitle {
    _arrangementTitle = arrangementTitle;
    [self.arrangementButton setTitle:arrangementTitle forState:UIControlStateNormal];
}

- (void)setKeyTitle:(NSString *)keyTitle {
    _keyTitle = keyTitle;
    [self.keyButton setTitle:keyTitle forState:UIControlStateNormal];
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOButton *)arrangementButton {
    if (!_arrangementButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:HEX(0x25252A) forState:UIControlStateNormal];
        [button setBackgroundColor:HEX(0x313137) forState:UIControlStateSelected];
        [button addTarget:self action:@selector(arrangementButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        _arrangementButton = button;
    }
    return _arrangementButton;
}

- (PCOButton *)keyButton {
    if (!_keyButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.titleLabel.font = [UIFont defaultFontOfSize_14];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:HEX(0x25252A) forState:UIControlStateNormal];
        [button setBackgroundColor:HEX(0x313137) forState:UIControlStateSelected];
        [button addTarget:self action:@selector(keyButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        _keyButton = button;
    }
    return _keyButton;
}

#pragma mark -
#pragma mark - Action Methods

- (void)arrangementButtonTouched:(id)sender {
    if (self.arrangementButton.selected) {
        self.state = ArrangementKeySelectedNone;
    }
    else {
        self.state = ArrangementKeySelectedArrangment;
    }
    self.changeHandler(self.state);
}

- (void)keyButtonTouched:(id)sender {
    if (self.keyButton.selected) {
        self.state = ArrangementKeySelectedNone;
    }
    else {
        self.state = ArrangementKeySelectedKey;
    }
    self.changeHandler(self.state);
}


@end

NSString *const kPlanEditItemArrangementKeyTableViewCellIdentifier = @"kPlanEditItemArrangementKeyTableViewCellIdentifier";
