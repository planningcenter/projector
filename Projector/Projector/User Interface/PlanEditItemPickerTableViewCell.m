//
//  PlanEditItemPickerTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 11/14/14.
//

#import "PlanEditItemPickerTableViewCell.h"

#define CELL_HEIGHT 160

@interface PlanEditItemPickerTableViewCell () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) UIPickerView *picker;

@end

@implementation PlanEditItemPickerTableViewCell

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
    self.backgroundView.backgroundColor = HEX(0x25252a);
    self.index = 0;
    PCOKitLazyLoad(self.picker);
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

#pragma mark - Setters
#pragma mark -

- (void)setChoices:(NSArray *)choices {
    _choices = choices;
    [self.picker reloadAllComponents];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    [self.picker selectRow:index inComponent:0 animated:YES];
}

#pragma mark - Lazy loaders
#pragma mark -

- (UIPickerView *)picker {
    if (!_picker) {
        UIPickerView *view = [UIPickerView newAutoLayoutView];
        view.backgroundColor = HEX(0x25252a);
        view.contentMode = UIViewContentModeCenter;
        view.dataSource = self;
        view.delegate = self;
        _picker = view;
        [self.contentView addSubview:view];
        [self.contentView addConstraints:[NSLayoutConstraint pco_fitView:view inView:self.contentView insets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    }
    return _picker;
}

#pragma mark - Picker Methods
#pragma mark -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.choices count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 34;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    PCOLabel *label = [[PCOLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    label.font = [UIFont defaultFontOfSize_18];
    label.textColor = HEX(0xc8cee0);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [self.choices objectAtIndex:row];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.changeHandler) {
        self.changeHandler(row);
    }
}

@end

NSString *const kPlanEditItemPickerTableViewCellIdentifier = @"kPlanEditItemPickerTableViewCellIdentifier";
