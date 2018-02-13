//
//  AvailableSessionTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 6/19/14.
//

#import "AvailableSessionTableViewCell.h"
#import "UIColor+PROColors.h"

#define CELL_HEIGHT 56
#define CELL_HEIGHT_CONNECTED CELL_HEIGHT+88

@implementation AvailableSessionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
        self.selectedBackgroundView = [UIView new];
        self.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor sessionsCellNormalBackgroundColor];
    self.clipsToBounds = YES;
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{};
    
    NSDictionary *views = @{
                            @"name_label": self.nameLabel,
                            @"cloud_button": self.cloudButton,
                            @"mirror_button": self.mirrorButton,
                            @"confidence_button": self.confidenceButton,
                            @"no_lyrics_button": self.noLyricsButton,
                            @"mirror_label": self.mirrorLabel,
                            @"confidence_label": self.confidenceLabel,
                            @"no_lyrics_label": self.noLyricsLabel,
                            @"mid_stroke": self.midStroke,
                            };
    
    for (NSString *format in @[
                               @"H:|-10-[name_label]-4-[cloud_button(==40)]-10-|",
                               @"V:|[name_label(==54)]",
                               @"V:|[cloud_button(==54)]",
                               @"H:|[mirror_button][confidence_button(==mirror_button)][no_lyrics_button(==mirror_button)]|",
                               @"V:[mirror_button(==88)]|",
                               @"V:[confidence_button(==88)]|",
                               @"V:[no_lyrics_button(==88)]|",
                               @"H:|[mirror_label][confidence_label(==mirror_label)][no_lyrics_label(==mirror_label)]|",
                               @"V:[mirror_label(==20)]-10-|",
                               @"V:[confidence_label(==20)]-10-|",
                               @"V:[no_lyrics_label(==20)]-10-|",
                               @"H:|[mid_stroke]|",
                               @"V:[mid_stroke(==1)]-88-|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    [self.contentView addConstraints:array];
    [self.contentView updateConstraintsIfNeeded];
}

+ (CGFloat)heightForCellConnected:(BOOL)connected {
    if (connected) {
        return CELL_HEIGHT_CONNECTED;
    }
    return CELL_HEIGHT;
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
        _nameLabel = label;
        [self.contentView addSubview:label];
    }
    return _nameLabel;
}

- (PCOButton *)cloudButton {
    if (!_cloudButton) {
        PCOButton *button = [[PCOButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor clearColor];
        button.tintColor = [UIColor sessionsTintColor];
        [button setImage:[UIImage templateImageNamed:@"cloud_connect"] forState:UIControlStateNormal];
        [self.contentView addSubview:button];
        _cloudButton = button;
    }
    return _cloudButton;
}

- (PCOButton *)mirrorButton {
    if (!_mirrorButton) {
        PCOButton *button = [[PCOButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor sidebarLightBackgroundColor];
        button.tintColor = [UIColor sessionsHeaderTextColor];
        [button setImage:[UIImage templateImageNamed:@"sessions-mirror"] forState:UIControlStateNormal];
        [button setImage:[UIImage templateImageNamed:@"sessions-mirror-circle"] forState:UIControlStateHighlighted];
        button.highlighted = YES;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 15, 0);
        [self.contentView addSubview:button];
        _mirrorButton = button;
    }
    return _mirrorButton;
}

- (PCOButton *)confidenceButton {
    if (!_confidenceButton) {
        PCOButton *button = [[PCOButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor sidebarLightBackgroundColor];
        button.tintColor = [UIColor sessionsHeaderTextColor];
        [button setImage:[UIImage templateImageNamed:@"sessions-confidence"] forState:UIControlStateNormal];
        [button setImage:[UIImage templateImageNamed:@"sessions-confidence-circle"] forState:UIControlStateHighlighted];
        button.highlighted = YES;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 15, 0);
        [self.contentView addSubview:button];
        _confidenceButton = button;
    }
    return _confidenceButton;
}

- (PCOButton *)noLyricsButton {
    if (!_noLyricsButton) {
        PCOButton *button = [[PCOButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.backgroundColor = [UIColor sidebarLightBackgroundColor];
        button.tintColor = [UIColor sessionsHeaderTextColor];
        [button setImage:[UIImage templateImageNamed:@"sessions-no-lyrics"] forState:UIControlStateNormal];
        [button setImage:[UIImage templateImageNamed:@"sessions-no-lyrics-circle"] forState:UIControlStateHighlighted];
        button.highlighted = YES;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 15, 0);
        [self.contentView addSubview:button];
        _noLyricsButton = button;
    }
    return _noLyricsButton;
}

- (UILabel *)mirrorLabel {
    if (!_mirrorLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = [UIColor sessionsHeaderTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"Mirror", nil);
        _mirrorLabel = label;
        [self.contentView addSubview:label];
    }
    return _mirrorLabel;
}

- (UILabel *)confidenceLabel {
    if (!_confidenceLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = [UIColor sessionsHeaderTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"Confidence", nil);
        _confidenceLabel = label;
        [self.contentView addSubview:label];
    }
    return _confidenceLabel;
}

- (UILabel *)noLyricsLabel {
    if (!_noLyricsLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = [UIColor sessionsHeaderTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"No Lyrics", nil);
        _noLyricsLabel = label;
        [self.contentView addSubview:label];
    }
    return _noLyricsLabel;
}

- (UIView *)midStroke {
    if (!_midStroke) {
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:view];
        _midStroke = view;
    }
    return _midStroke;
}

#pragma mark - Setter Methods
#pragma mark -

-(void)setClientMode:(P2PClientMode)clientMode {
    _clientMode = clientMode;

    self.mirrorButton.tintColor = [UIColor sessionsHeaderTextColor];
    self.confidenceButton.tintColor = [UIColor sessionsHeaderTextColor];
    self.noLyricsButton.tintColor = [UIColor sessionsHeaderTextColor];
    self.mirrorLabel.textColor = [UIColor sessionsHeaderTextColor];
    self.confidenceLabel.textColor = [UIColor sessionsHeaderTextColor];
    self.noLyricsLabel.textColor = [UIColor sessionsHeaderTextColor];
    
    self.mirrorButton.highlighted = NO;
    self.confidenceButton.highlighted = NO;
    self.noLyricsButton.highlighted = NO;
    
    switch (clientMode) {
        case P2PClientModeNone:
        {
            break;
        }
        case P2PClientModeMirror:
        {
            self.mirrorButton.tintColor = [UIColor sessionsMirrorModeColor];
            self.mirrorLabel.textColor = [UIColor sessionsMirrorModeColor];
            self.mirrorButton.highlighted = YES;
            break;
        }
        case P2PClientModeConfidence:
        {
            self.confidenceButton.tintColor = [UIColor sessionsConfidenceColor];
            self.confidenceLabel.textColor = [UIColor sessionsConfidenceColor];
            self.confidenceButton.highlighted = YES;
            break;
        }
        case P2PClientModeNoLyrics:
        {
            self.noLyricsButton.tintColor = [UIColor sessionsNoLyricsColor];
            self.noLyricsLabel.textColor = [UIColor sessionsNoLyricsColor];
            self.noLyricsButton.highlighted = YES;
            break;
        }
        default:
            break;
    }
}

-(void)setConnected:(BOOL)connected {
    _connected = connected;
    if (connected) {
        self.mirrorButton.hidden = NO;
        self.mirrorLabel.hidden = NO;
        self.confidenceButton.hidden = NO;
        self.confidenceLabel.hidden = NO;
        self.noLyricsButton.hidden = NO;
        self.noLyricsLabel.hidden = NO;
    }
    else {
        self.mirrorButton.hidden = YES;
        self.mirrorLabel.hidden = YES;
        self.confidenceButton.hidden = YES;
        self.confidenceLabel.hidden = YES;
        self.noLyricsButton.hidden = YES;
        self.noLyricsLabel.hidden = YES;
    }
}

@end
