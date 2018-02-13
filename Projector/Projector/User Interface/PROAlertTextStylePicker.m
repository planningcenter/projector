/*!
 * PROAlertTextStylePicker.m
 *
 *
 * Created by Skylar Schipper on 4/15/14
 */

static NSString *const kPROAlertTextStylePickerSetting = @"kPROAlertTextStylePickerSetting";

#import "PROAlertTextStylePicker.h"
#import "PCODecorationImageView.h"
#import "PCOKeyValueStore.h"

@interface PROAlertTextStylePicker ()

@property (nonatomic, weak) PCOButton *topRow;
@property (nonatomic, weak) PCOButton *middleRow;
@property (nonatomic, weak) PCOButton *bottomRow;
@property (nonatomic, weak) PCODecorationImageView *selectedImageView;

@end

@implementation PROAlertTextStylePicker

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor planGridSectionHeaderItemHeaderBackgroundColor];
    
    PCOLabel *(^newLabel)(void) = ^ PCOLabel * {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Your Text", nil) attributes:@{NSKernAttributeName: @(-0.8)}];
        label.attributedText = string;
        
        return label;
    };
    
    PCOLabel *topLabel = newLabel();
    topLabel.layer.borderColor = [self.strokeColor CGColor];
    topLabel.layer.borderWidth = 1.0;
    
    PCOLabel *middleLabel = newLabel();
    middleLabel.backgroundColor = [UIColor blackColor];
    
    PCOLabel *bottomLabel = newLabel();
    bottomLabel.backgroundColor = [UIColor whiteColor];
    bottomLabel.textColor = [UIColor blackColor];
    
    [self.topRow addSubview:topLabel];
    [self.middleRow addSubview:middleLabel];
    [self.bottomRow addSubview:bottomLabel];
    
    PCOLabel *(^newText)(void) = ^ PCOLabel * {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = [UIColor modalTextLabelTextColor];
        
        return label;
    };
    
    PCOLabel *none = newText();
    none.text = NSLocalizedString(@"None", nil);
    
    PCOLabel *black = newText();
    black.text = NSLocalizedString(@"Black", nil);
    
    PCOLabel *white = newText();
    white.text = NSLocalizedString(@"White", nil);
    
    [self.topRow addSubview:none];
    [self.middleRow addSubview:black];
    [self.bottomRow addSubview:white];
    
    NSArray *strings = @[
                         @"V:|-10-[label]-10-|",
                         @"V:|-10-[text]-10-|",
                         @"H:|-10-[label(==70)]",
                         @"H:[label]-[text(<=100)]"
                         ];
    
    [self.topRow addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:strings metrics:nil views:@{@"label": topLabel, @"text": none}]];
    [self.middleRow addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:strings metrics:nil views:@{@"label": middleLabel, @"text": black}]];
    [self.bottomRow addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:strings metrics:nil views:@{@"label": bottomLabel, @"text": white}]];
    
    [self updateSelected];
}

// MARK: - Actions
- (void)changeBackgroundAction:(id)sender {
    if (sender == self.topRow) {
        [[self class] setStyle:PROAlertTextStyleClear];
        [PCOEventLogger logEvent:@"Nursery Alert Settings - No Background"];
    } else if (sender == self.middleRow) {
        [[self class] setStyle:PROAlertTextStyleBlack];
        [PCOEventLogger logEvent:@"Nursery Alert Settings - Black Background"];
    } else {
        [[self class] setStyle:PROAlertTextStyleWhite];
        [PCOEventLogger logEvent:@"Nursery Alert Settings - White Background"];
    }
    [self updateSelected];
}
- (void)updateSelected {
    PROAlertTextStyle style = [[self class] style];

    [_selectedImageView removeFromSuperview];
    _selectedImageView = nil;
    
    switch (style) {
        case PROAlertTextStyleClear:
            [self addConstraint:[NSLayoutConstraint centerVertical:self.selectedImageView inView:self.topRow]];
            break;
        case PROAlertTextStyleBlack:
            [self addConstraint:[NSLayoutConstraint centerVertical:self.selectedImageView inView:self.middleRow]];
            break;
        case PROAlertTextStyleWhite:
            [self addConstraint:[NSLayoutConstraint centerVertical:self.selectedImageView inView:self.bottomRow]];
            break;
            
        default:
            break;
    }
}

// MARK: - Lazy Loaders
- (PCODecorationImageView *)selectedImageView {
    if (!_selectedImageView) {
        PCODecorationImageView *iv = [PCODecorationImageView newAutoLayoutView];
        iv.image = [UIImage imageNamed:@"small_white_check_mark"];
        iv.imagePadding = UIEdgeInsetsMake(10.0, 9.0, 10.0, 9.0);
        iv.backgroundColor = [UIColor modalTextStyleBackgroundColor];
        iv.layer.borderColor = [[UIColor modalTextStyleStrokeColor] CGColor];
        iv.layer.borderWidth = 1.0;
        
        CGSize size = [iv intrinsicContentSize];
        iv.layer.cornerRadius = size.height / 2.0;
        
        _selectedImageView = iv;
        [self addSubview:iv];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:iv offset:10.0 edges:UIRectEdgeRight]];
    }
    return _selectedImageView;
}

// MARK: - Buttons Loaders
- (PCOButton *)topRow {
    if (!_topRow) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor modalPositionPickerBackgroundColor] forState:UIControlStateNormal];
        [view setBackgroundColor:[UIColor modalViewHeaderViewBackgroundColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [view addTarget:self action:@selector(changeBackgroundAction:) forControlEvents:UIControlEventTouchUpInside];

        _topRow = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeTop]];
    }
    return _topRow;
}
- (PCOButton *)middleRow {
    if (!_middleRow) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor modalPositionPickerBackgroundColor] forState:UIControlStateNormal];
        [view setBackgroundColor:[UIColor modalViewHeaderViewBackgroundColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [view addTarget:self action:@selector(changeBackgroundAction:) forControlEvents:UIControlEventTouchUpInside];

        _middleRow = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.topRow attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topRow attribute:NSLayoutAttributeBottom multiplier:1.0 constant:1.0]];
    }
    return _middleRow;
}
- (PCOButton *)bottomRow {
    if (!_bottomRow) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor modalPositionPickerBackgroundColor] forState:UIControlStateNormal];
        [view setBackgroundColor:[UIColor modalViewHeaderViewBackgroundColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        [view addTarget:self action:@selector(changeBackgroundAction:) forControlEvents:UIControlEventTouchUpInside];

        _bottomRow = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.middleRow attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.middleRow attribute:NSLayoutAttributeBottom multiplier:1.0 constant:1.0]];
    }
    return _bottomRow;
}

#pragma mark -
#pragma mark - Setting
+ (void)setStyle:(PROAlertTextStyle)style {
    [[PCOKeyValueStore defaultStore] setObject:@(style) forKey:kPROAlertTextStylePickerSetting];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PROAlertTextStylePickerChangeNotification object:nil];
    });
}
+ (PROAlertTextStyle)style {
    NSNumber *num = [[PCOKeyValueStore defaultStore] objectForKey:kPROAlertTextStylePickerSetting];
    if (!num) {
        return PROAlertTextStyleClear;
    }
    return [num integerValue];
}

@end

_PCO_EXTERN_STRING PROAlertTextStylePickerChangeNotification = @"PROAlertTextStylePickerChangeNotification";
