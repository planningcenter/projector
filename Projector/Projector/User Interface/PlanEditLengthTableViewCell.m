//
//  PlanEditLengthTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 11/13/14.
//

#define CELL_HEIGHT 100.0
#define CONTAINER_HEIGHT 60.0
#define TEXT_INPUT_WIDTH 100.0

#import "PlanEditLengthTableViewCell.h"

@interface PlanEditLengthTableViewCell () {
}

@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSInteger seconds;
@property (nonatomic, weak) PCOView *containerView;
@property (nonatomic, weak) PCOView *minView;
@property (nonatomic, weak) PCOView *secView;
@property (nonatomic, weak) UITextField *minTextField;
@property (nonatomic, weak) UITextField *secTextField;
@property (nonatomic, weak) PCOLabel *minLabel;
@property (nonatomic, weak) PCOLabel *secLabel;
@property (nonatomic, weak) UIImageView *colonImage;

@end

@implementation PlanEditLengthTableViewCell

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
    self.backgroundView.backgroundColor = HEX(0x25252a);
    PCOKitLazyLoad(self.containerView);
    PCOKitLazyLoad(self.minView);
    PCOKitLazyLoad(self.secView);
    PCOKitLazyLoad(self.colonImage);
    PCOKitLazyLoad(self.minTextField);
    PCOKitLazyLoad(self.secTextField);
    PCOKitLazyLoad(self.minLabel);
    PCOKitLazyLoad(self.secLabel);
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

- (void)setLength:(NSNumber *)length {
    _length = length;
    self.minutes = [length integerValue] / 60;
    self.seconds = [length integerValue] % 60;
    self.minTextField.text = [NSString stringWithFormat:@"%td", self.minutes];
    self.secTextField.text = [NSString stringWithFormat:@"%td", self.seconds];
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOView *)containerView {
    if (!_containerView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = HEX(0x25252a);
        [self.contentView addSubview:view];
        [self.contentView addConstraints:[NSLayoutConstraint pco_center:view inView:self.contentView]];
        [self.contentView addConstraint:[NSLayoutConstraint pco_height:CONTAINER_HEIGHT forView:view]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        _containerView = view;
    }
    return _containerView;
}

- (UIImageView *)colonImage {
    if (!_colonImage) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        view.backgroundColor = [UIColor clearColor];
        view.image = [UIImage imageNamed:@"length-seperator"];
        _colonImage = view;
        [self.containerView addSubview:view];
        [self addConstraints:[NSLayoutConstraint pco_center:view inView:self.containerView]];
    }
    return _colonImage;
}

- (PCOView *)minView {
    if (!_minView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = HEX(0x1e1e22);
        view.layer.borderColor = [HEX(0x393940) CGColor];
        view.layer.borderWidth = 1.0;
        view.layer.cornerRadius = 3.0;
        [self.containerView addSubview:view];
        [self.containerView addConstraint:[NSLayoutConstraint pco_width:TEXT_INPUT_WIDTH forView:view]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0.0]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:-20.0]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1.0
                                                                        constant:0.0]];
        _minView = view;
    }
    return _minView;
}

- (PCOView *)secView {
    if (!_secView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = HEX(0x1e1e22);
        view.layer.borderColor = [HEX(0x393940) CGColor];
        view.layer.borderWidth = 1.0;
        view.layer.cornerRadius = 3.0;
        [self.containerView addSubview:view];
        [self.containerView addConstraint:[NSLayoutConstraint pco_width:TEXT_INPUT_WIDTH forView:view]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0.0]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:20.0]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.containerView
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1.0
                                                                        constant:0.0]];
        _secView = view;
    }
    return _secView;
}

- (UITextField *)minTextField {
    if (!_minTextField) {
        UITextField *textField = [UITextField newAutoLayoutView];
        [textField addTarget:self action:@selector(minTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.delegate = self;
        textField.backgroundColor = [UIColor clearColor];
        textField.textColor = HEX(0xc8cee0);
        textField.font = [UIFont defaultFontOfSize:24];
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.textAlignment = NSTextAlignmentCenter;
        [self.minView addSubview:textField];
        [self.minView addConstraints:[NSLayoutConstraint pco_fitView:textField inView:self.minView insets:UIEdgeInsetsMake(0, 10, 0, 10)]];
        _minTextField = textField;
    }
    return _minTextField;
}

- (UITextField *)secTextField {
    if (!_secTextField) {
        UITextField *textField = [UITextField newAutoLayoutView];
        [textField addTarget:self action:@selector(secTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.delegate = self;
        textField.backgroundColor = [UIColor clearColor];
        textField.textColor = HEX(0xc8cee0);
        textField.font = [UIFont defaultFontOfSize:24];
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.textAlignment = NSTextAlignmentCenter;
        [self.secView addSubview:textField];
        [self.secView addConstraints:[NSLayoutConstraint pco_fitView:textField inView:self.secView insets:UIEdgeInsetsMake(0, 10, 0, 10)]];
        _secTextField = textField;
    }
    return _secTextField;
}

- (PCOLabel *)minLabel {
    if (!_minLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = HEX(0x5c5c66);
        label.textAlignment = NSTextAlignmentRight;
        label.text = NSLocalizedString(@"MIN", nil);
        label.backgroundColor = [UIColor clearColor];
        _minLabel = label;
        [self.containerView addSubview:label];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.minView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0
                                                                        constant:-10.0]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.minView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0.0]];

    }
    return _minLabel;
}

- (PCOLabel *)secLabel {
    if (!_secLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = HEX(0x5c5c66);
        label.textAlignment = NSTextAlignmentLeft;
        label.text = NSLocalizedString(@"SEC", nil);
        label.backgroundColor = [UIColor clearColor];
        _secLabel = label;
        [self.containerView addSubview:label];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.secView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:10.0]];
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.secView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0.0]];
        
    }
    return _secLabel;
}

#pragma mark - UITextFieldDelegate Methods
#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if (textField == self.minTextField) {
        if (textField.text.length < 3) {
            return [self isStringNumber:string];
        }
        return NO;
    }
    if (textField == self.secTextField) {
        if (textField.text.length < 2) {
            return [self isStringNumber:string];
        }
        return NO;
    }
    return YES;
}

- (BOOL)isStringNumber:(NSString *)string {
    NSString *numbers = @"0123456789";
    NSArray *allCharacters = [self convertToArray:string];
    for (NSString *character in allCharacters) {
        if (![numbers containsString:character]) {
            return NO;
        }
    }
    return YES;
}

- (NSArray *)convertToArray:(NSString *)string {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSUInteger i = 0;
    while (i < string.length) {
        NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *chStr = [string substringWithRange:range];
        [array addObject:chStr];
        i += range.length;
    }
    
    return [NSArray arrayWithArray:array];
}


#pragma mark -
#pragma mark - Action Methods

- (void)minTextFieldDidChange:(id)sender {
    self.minutes = [self.minTextField.text integerValue];
    [self lengthChanged];
}

- (void)secTextFieldDidChange:(id)sender {
    self.seconds = [self.secTextField.text integerValue];
    [self lengthChanged];
}

- (void)lengthChanged {
    NSNumber *length = @((self.minutes * 60) + self.seconds);
    if (_changeHandler) {
        self.changeHandler(length);
    }
}

@end

NSString *const kPlanEditLengthTableViewCellIdentifier = @"kPlanEditLengthTableViewCellIdentifier";
