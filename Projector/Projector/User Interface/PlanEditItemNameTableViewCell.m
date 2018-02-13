//
//  PlanEditItemNameTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 11/13/14.
//

#define CELL_HEIGHT 100

#import "PlanEditItemNameTableViewCell.h"

@interface PlanEditItemNameTableViewCell ()

@property (nonatomic, weak) PCOView *containerView;

@end

@implementation PlanEditItemNameTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = HEX(0x25252a);
    self.backgroundView.backgroundColor = HEX(0x25252a);
    PCOKitLazyLoad(self.textField);
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

- (PCOView *)containerView {
    if (!_containerView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = HEX(0x313137);
        view.layer.borderColor = [HEX(0x414147) CGColor];
        view.layer.borderWidth = 1.0;
        view.layer.cornerRadius = 3.0;
        [self.contentView addSubview:view];
        [self.contentView addConstraints:[NSLayoutConstraint pco_fitView:view inView:self.contentView insets:UIEdgeInsetsMake(19, 19, 19, 19)]];
        _containerView = view;
    }
    return _containerView;
}

- (UITextField *)textField {
    if (!_textField) {
        UITextField *textField = [UITextField newAutoLayoutView];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.backgroundColor = [UIColor clearColor];
        textField.textColor = [UIColor whiteColor];
        textField.font = [UIFont defaultFontOfSize_16];
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.textAlignment = NSTextAlignmentLeft;
        if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = [UIColor whiteColor];
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"New Item", nil) attributes:@{NSForegroundColorAttributeName: color}];
        }
        else {
            textField.placeholder = NSLocalizedString(@"New Item", nil);
        }
        [self.containerView addSubview:textField];
        [self.containerView addConstraints:[NSLayoutConstraint pco_fitView:textField inView:self.containerView insets:UIEdgeInsetsMake(10, 10, 10, 10)]];
        _textField = textField;
    }
    return _textField;
}

- (void)textFieldDidChange:(id)sender {
    if (_changeHandler) {
        self.changeHandler(self.textField.text);
    }
}

@end

NSString *const kPlanEditItemNameTableViewCellIdentifier = @"kPlanEditItemNameTableViewCellIdentifier";
