//
//  CreateSessionTableViewCellZero.m
//  Projector
//
//  Created by Peter Fokos on 6/23/14.
//

#import "CreateSessionTableViewCellZero.h"
#import "UIColor+PROColors.h"

#define CELL_HEIGHT_DEFAULT 0
#define CELL_HEIGHT_SESSION_STARTED 44

@implementation CreateSessionTableViewCellZero

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.backgroundColor = [UIColor sidebarBackgroundColor];
    self.clipsToBounds = YES;
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{@"cell_height": @(CELL_HEIGHT_SESSION_STARTED-CELL_HEIGHT_DEFAULT)};
    
    NSDictionary *views = @{
                            @"connections_label": self.connectionsLabel,
                            @"allow_control_label": self.allowControlLabel,
                            };
    
    for (NSString *format in @[
                               @"H:|-10-[connections_label][allow_control_label(==connections_label)]-10-|",
                               @"V:|-2-[connections_label(==cell_height)]",
                               @"V:|-2-[allow_control_label(==cell_height)]",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    [self.contentView addConstraints:array];
    [self.contentView updateConstraintsIfNeeded];
}

+ (CGFloat)heightForCellWithSessionStarted:(BOOL)sessionStarted {
    if (sessionStarted) {
        return CELL_HEIGHT_SESSION_STARTED;
    }
    return CELL_HEIGHT_DEFAULT;
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOLabel *)connectionsLabel {
    if (!_connectionsLabel) {
        PCOLabel *label = [[PCOLabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor sessionsHeaderTextColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 3;
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = NSLocalizedString(@"Connections", nil);
        _connectionsLabel = label;
        [self.contentView addSubview:label];
    }
    return _connectionsLabel;
}

- (PCOLabel *)allowControlLabel {
    if (!_allowControlLabel) {
        PCOLabel *label = [[PCOLabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor sessionsHeaderTextColor];
        label.textAlignment = NSTextAlignmentRight;
        label.numberOfLines = 3;
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = NSLocalizedString(@"Allow Control", nil);
        _allowControlLabel = label;
        [self.contentView addSubview:label];
    }
    return _allowControlLabel;
}

@end
