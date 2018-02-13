//
//  LayoutEditorColorPickerHexTableViewCell.m
//  Projector
//
//  Created by Skylar Schipper on 6/23/14.
//

#import "LayoutEditorColorPickerHexTableViewCell.h"
#import "PROHEXColorStringNormalizer.h"

@interface LayoutEditorColorPickerHexTableViewCell () <UITextFieldDelegate>

@property (nonatomic, weak) PCOLabel *hexLabel;
@property (nonatomic, weak) ColorPickerHexTextField *hexField;
@property (nonatomic, weak) PCOView *displayView;

@end

@implementation LayoutEditorColorPickerHexTableViewCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PCOKitLazyLoad(self.hexField);
}

#pragma mark -
#pragma mark - Setters
- (void)setColor:(UIColor *)color {
    _color = color;
    self.hexField.text = [color hexStringFromColor];
    self.displayView.backgroundColor = color;
}

#pragma mark -
#pragma mark - Lazy Loaders
- (PCOLabel *)hexLabel {
    if (!_hexLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.text = NSLocalizedString(@"HEX #", nil);
        label.textColor = [UIColor layoutEditorSidebarColorPickerHexTextColor];
        label.font = [UIFont defaultFontOfSize_14];
        
        _hexLabel = label;
        [self.contentView addSubview:label];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:16.0 edges:UIRectEdgeLeft]];
        [self.contentView addConstraint:[NSLayoutConstraint centerViewVerticalyInSuperview:label]];
    }
    return _hexLabel;
}
- (ColorPickerHexTextField *)hexField {
    if (!_hexField) {
        ColorPickerHexTextField *field = [ColorPickerHexTextField newAutoLayoutView];
        field.delegate = self;
        
        _hexField = field;
        [self.contentView addSubview:field];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:field attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.hexLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:8.0]];
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:field offset:8.0 edges:UIRectEdgeTop | UIRectEdgeBottom]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:field attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100.0]];
        [self.contentView addConstraint:[NSLayoutConstraint centerViewVerticalyInSuperview:field]];
    }
    return _hexField;
}
- (PCOView *)displayView {
    if (!_displayView) {
        PCOView *view = [PCOView newAutoLayoutView];
        
        _displayView = view;
        [self.contentView addSubview:view];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:12.0 edges:UIRectEdgeTop | UIRectEdgeBottom | UIRectEdgeRight]];
        [self.contentView addConstraint:[NSLayoutConstraint width:60.0 forView:view]];
    }
    return _displayView;
}

#pragma mark -
#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIColor *color = [PROHEXColorStringNormalizer colorFromString:textField.text];
    if (self.hexColorStringChangeHandler) {
        self.hexColorStringChangeHandler(color);
    }
}

@end
