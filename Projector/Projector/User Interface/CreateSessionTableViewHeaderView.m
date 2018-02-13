//
//  CreateSessionTableViewHeaderView.m
//  Projector
//
//  Created by Peter Fokos on 6/19/14.
//

#import "CreateSessionTableViewHeaderView.h"
#import "ConnectToSessionTableViewHeaderView.h"

#define VIEW_HEIGHT_DEFAULT 44
#define VIEW_HEIGHT_WITH_INFO 100

@implementation CreateSessionTableViewHeaderView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor sessionsCellNormalBackgroundColor];
    self.clipsToBounds = YES;
    
    NSMutableArray *array = [NSMutableArray array];
    
    CGFloat titleHeight = [ConnectToSessionTableViewHeaderView heightForView];
    CGFloat statusHeight = 40;
    CGFloat infoLabelY = titleHeight + statusHeight - 10;
    
    NSDictionary *metrics = @{@"title_height": @(titleHeight),
                              @"status_height": @(statusHeight),
                              @"info_y": @(infoLabelY)};
    
    NSDictionary *views = @{
                            @"status_label": self.statusLabel,
                            @"info_label": self.infoLabel,
                            @"plus": self.imageView,
                            @"start_button": self.startButton,
                            @"info_button": self.infoButton,
                            @"title_view": self.titleView,
                            @"bottom_stroke": self.bottomStroke,
                            };
    
    for (NSString *format in @[
                               @"H:|[title_view]|",
                               @"V:|[title_view(==title_height)]",
                               @"H:|-4-[plus(==status_height)]-4-[status_label(>=60)]-4-[info_button(==status_height)]-4-|",
                               @"H:|[start_button]|",
                               @"V:|-title_height-[status_label(==status_height)]",
                               @"V:|-title_height-[plus(==status_height)]",
                               @"V:|-title_height-[start_button(==status_height)]",
                               @"V:|-title_height-[info_button(==status_height)]",
                               @"H:|-38-[info_label]-38-|",
                               @"V:|-info_y-[info_label]|",
                               @"H:|[bottom_stroke]|",
                               @"V:[bottom_stroke(==1)]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    [self addConstraints:array];
    [self updateConstraintsIfNeeded];
}

+ (CGFloat)heightForViewWithInfoShowing:(BOOL)showInfo {
    CGFloat height = [ConnectToSessionTableViewHeaderView heightForView];
    if (showInfo) {
        return height + VIEW_HEIGHT_WITH_INFO;
    }
    return height + VIEW_HEIGHT_DEFAULT;
}

- (void)setStatusColor:(UIColor *)statusColor {
    _statusColor = statusColor;
    self.statusLabel.textColor = statusColor;
    self.startButton.tintColor = statusColor;
    self.bottomStroke.backgroundColor = statusColor;
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOLabel *)statusLabel {
    if (!_statusLabel) {
        PCOLabel *label = [[PCOLabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor sessionsTintColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 3;
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = NSLocalizedString(@"Start Session", nil);
        _statusLabel = label;
        [self addSubview:label];
    }
    return _statusLabel;
}

- (PCOLabel *)infoLabel {
    if (!_infoLabel) {
        PCOLabel *label = [[PCOLabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = [UIColor sessionsInfoTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 3;
        label.backgroundColor = [UIColor clearColor];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = NSLocalizedString(@"Sessions allow one iOS device to control the same service plan on all connected iOS devices.", nil);
        _infoLabel = label;
        [self addSubview:label];
    }
    return _infoLabel;
}


- (PCOButton *)startButton {
    if (!_startButton) {
        PCOButton *button = [[PCOButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor clearColor];
        [self addSubview:button];
        _startButton = button;
    }
    return _startButton;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *image = [UIImageView newAutoLayoutView];
        image.contentMode = UIViewContentModeCenter;
        image.tintColor = [UIColor sessionsTintColor];
        image.image = [UIImage templateImageNamed:@"plus_icon"];
        [self addSubview:image];
        _imageView = image;
    }
    return _imageView;
}

- (PCOButton *)infoButton {
    if (!_infoButton) {
        PCOButton *button = [[PCOButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor clearColor];
        
        [button setImage:[UIImage templateImageNamed:@"info-icon"] forState:UIControlStateNormal];
        [self addSubview:button];
        _infoButton = button;
    }
    return _infoButton;
}

- (ConnectToSessionTableViewHeaderView *)titleView {
    if (!_titleView) {
        ConnectToSessionTableViewHeaderView *view = [[ConnectToSessionTableViewHeaderView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.nameLabel.text = NSLocalizedString(@"SESSIONS", nil);
        [self addSubview:view];
        _titleView = view;
    }
    return _titleView;
}

- (UIView *)bottomStroke {
    if (!_bottomStroke) {
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor sessionsTintColor];
        [self addSubview:view];
        _bottomStroke = view;
    }
    return _bottomStroke;
}

@end
