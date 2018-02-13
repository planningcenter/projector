//
//  CapitalizedTableviewHeaderView.m
//  Projector
//
//  Created by Peter Fokos on 10/10/14.
//

#import "CapitalizedTableviewHeaderView.h"
#import "UIColor+PROColors.h"

#define VIEW_HEIGHT 36

@implementation CapitalizedTableviewHeaderView

- (id)init {
    self = [super init];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    self.backgroundColor = [UIColor captializedTextHeaderBackgroundColor];
    NSMutableArray *array = [NSMutableArray array];
    
    [array addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                  attribute:NSLayoutAttributeBaseline
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:-9]];
    [array addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:9]];
    
    [self addConstraints:array];
    [self updateConstraintsIfNeeded];
}

+ (CGFloat)heightForView {
    return VIEW_HEIGHT;
}

- (void)capitalizedTitle:(NSString *)title {
    self.titleLabel.text = [title uppercaseString];
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOLabel *)titleLabel {
    if (!_titleLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor captializedTextHeaderTextColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor clearColor];
        _titleLabel = label;
        [self addSubview:label];
    }
    return _titleLabel;
}


@end
