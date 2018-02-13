//
//  ConnectToSessionTableViewHeaderView.m
//  Projector
//
//  Created by Peter Fokos on 6/19/14.
//

#import "ConnectToSessionTableViewHeaderView.h"
#import "UIColor+PROColors.h"

#define VIEW_HEIGHT 44

@implementation ConnectToSessionTableViewHeaderView

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
    self.backgroundColor = [UIColor sidebarBackgroundColor];
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{};
    
    NSDictionary *views = @{
                            @"name_label": self.nameLabel,
                            };
    
    for (NSString *format in @[
                               @"H:|-10-[name_label]-10-|",
                               @"V:[name_label]-4-|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    [self addConstraints:array];
    [self updateConstraintsIfNeeded];
}

+ (CGFloat)heightForView {
    return VIEW_HEIGHT;
}

#pragma mark - Lazy loaders
#pragma mark -

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor sessionsHeaderTextColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 3;
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = NSLocalizedString(@"AVAILABLE SESSIONS", nil);
        _nameLabel = label;
        [self addSubview:label];
    }
    return _nameLabel;
}

@end
