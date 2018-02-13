/*!
 * LogoPickerSearchBarView.m
 *
 *
 * Created by Skylar Schipper on 7/10/14
 */

#import "LogoPickerSearchBarView.h"

@interface LogoPickerSearchBarView () <UITextFieldDelegate>

@property (nonatomic, weak) PCOView *strokeView;
@property (nonatomic, weak) UIImageView *searchIcon;
@property (nonatomic, weak) PCOTextField *searchField;

@end

@implementation LogoPickerSearchBarView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.clipsToBounds = YES;
    
    PCOKitLazyLoad(self.strokeView);
    PCOKitLazyLoad(self.searchField);
}

- (PCOView *)strokeView {
    if (!_strokeView) {
        PCOView *stroke = [PCOView newAutoLayoutView];
        stroke.backgroundColor = [UIColor projectorOrangeColor];
        
        _strokeView = stroke;
        [self addSubview:stroke];
        
        [self addConstraint:[NSLayoutConstraint height:PCOKitHairLine(1.0, self.window.screen) forView:stroke]];
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:stroke offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
    }
    return _strokeView;
}
- (UIImageView *)searchIcon {
    if (!_searchIcon) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage templateImageNamed:@"search_icon"]];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.tintColor = pco_kit_GRAY(65.0);
        
        [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [imageView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        _searchIcon = imageView;
        [self addSubview:imageView];
        
        [self addConstraint:[NSLayoutConstraint centerViewVerticalyInSuperview:imageView]];
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:imageView offset:16.0 edges:UIRectEdgeLeft]];
    }
    return _searchIcon;
}
- (PCOTextField *)searchField {
    if (!_searchField) {
        PCOTextField *field = [PCOTextField newAutoLayoutView];
        field.textColor = [UIColor whiteColor];
        field.delegate = self;
        field.font = [UIFont defaultFontOfSize_16];
        
        _searchField = field;
        [self addSubview:field];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:field attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.searchIcon attribute:NSLayoutAttributeRight multiplier:1.0 constant:8.0]];
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:field offset:8.0 edges:UIRectEdgeRight]];
        [self addConstraints:[[NSLayoutConstraint offsetViewEdgesInSuperview:field offset:4.0 edges:UIRectEdgeTop | UIRectEdgeBottom] each:^(id obj) {
            [obj setPriority:UILayoutPriorityDefaultHigh];
        }]];
    }
    return _searchField;
}

#pragma mark -
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.searchUpdateHandler) {
        self.searchUpdateHandler(textField.text, YES);
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *current = [textField.text mutableCopy];
    [current replaceCharactersInRange:range withString:string];
    if (self.searchUpdateHandler) {
        self.searchUpdateHandler([current copy], NO);
    }
    return YES;
}

@end
