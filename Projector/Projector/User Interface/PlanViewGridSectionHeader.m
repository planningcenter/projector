/*!
 * PlanViewGridSectionHeader.m
 *
 *
 * Created by Skylar Schipper on 3/17/14
 */

#import "PlanViewGridSectionHeader.h"

@interface PlanViewGridSectionHeaderView ()

@property (nonatomic, weak) PCOView *statusView;

@end

@interface PlanViewGridSectionHeaderImageView : UIImageView

@end

@implementation PlanViewGridSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor planGridSectionHeaderBackgroundColor];
        self.state = PlanViewGridSectionStateOff;
    }
    return self;
}

- (void)setState:(PlanViewGridSectionState)state {
    _state = state;
    
    PCOKitLazyLoad(self.lyricsButton);
    
    self.titleLabel.textColor = [UIColor planGridSectionHeaderOffTextColor];
    self.tintColor = [UIColor planGridSectionHeaderOffTextColor];
    self.loopingIcon.highlighted = NO;
    
    if (state == PlanViewGridSectionStateNext) {
        self.statusView.backgroundColor = [UIColor nextUpItemBlueColor];
        self.tintColor = [UIColor planGridSectionHeaderButtonOnColor];
        self.titleLabel.textColor = [UIColor planGridSectionHeaderButtonOnColor];
    } else if (state == PlanViewGridSectionStateCurrent) {
        self.titleLabel.textColor = [UIColor whiteColor];
        self.statusView.backgroundColor = [UIColor currentItemGreenColor];
        self.titleLabel.textColor = [UIColor planGridSectionHeaderButtonOnColor];
        self.tintColor = [UIColor planGridSectionHeaderButtonOnColor];
        self.loopingIcon.highlighted = YES;
    } else {
        self.statusView.backgroundColor = [UIColor planGridSectionHeaderBackgroundColor];
    }
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}
- (NSString *)title {
    return self.titleLabel.text;
}

- (PCOLabel *)titleLabel {
    if (!_titleLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = self.backgroundColor;
        label.font = [UIFont defaultFontOfSize_16];
        
        _titleLabel = label;
        [self addSubview:label];
        
        [self addConstraint:[NSLayoutConstraint centerVertical:label inView:self]];
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:10.0 edges:UIRectEdgeLeft]];
    }
    return _titleLabel;
}
- (PCOView *)statusView {
    if (!_statusView) {
        PCOView *view = [PCOView newAutoLayoutView];
        
        _statusView = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight]];
        [self addConstraint:[NSLayoutConstraint height:2.0 forView:view]];
    }
    return _statusView;
}
- (PCOButton *)lyricsButton {
    if (!_lyricsButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.minimumIntrinsicContentSize = CGSizeMake(44.0, CGRectGetHeight(self.bounds) - 6.0);
        [button setImage:[UIImage templateImageNamed:@"plan_lyrics_icon"] forState:UIControlStateNormal];
        
        _lyricsButton = button;
        [self addSubview:button];
        
        [self addConstraint:[NSLayoutConstraint centerVertical:button inView:self]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.settingsButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    }
    return _lyricsButton;
}
- (PCOButton *)settingsButton {
    if (!_settingsButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        button.minimumIntrinsicContentSize = CGSizeMake(44.0, CGRectGetHeight(self.bounds) - 6.0);
        [button setImage:[UIImage templateImageNamed:@"plan_settings_icon"] forState:UIControlStateNormal];
        
        _settingsButton = button;
        [self addSubview:button];
        
        [self addConstraint:[NSLayoutConstraint centerVertical:button inView:self]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-8.0]];
    }
    return _settingsButton;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.titleLabel.backgroundColor = backgroundColor;
}

- (UIImageView *)loopingIcon {
    if (!_loopingIcon) {
        UIImageView *view = [PlanViewGridSectionHeaderImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        view.tintColor = [UIColor projectorOrangeColor];
        view.image = [UIImage templateImageNamed:@"looping_icon"];
        _loopingIcon = view;
        view.hidden = YES;
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint centerVertical:view inView:self]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0]];
    }
    return _loopingIcon;
}

@end

@implementation PlanViewGridSectionHeaderImageView

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.tintColor = [UIColor projectorOrangeColor];
    } else {
        self.tintColor = [UIColor planGridSectionHeaderOffTextColor];
    }
}

@end


@implementation PlanViewGridSectionHeader

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.view.state = PlanViewGridSectionStateOff;
}

- (PlanViewGridSectionHeaderView *)view {
    if (!_view) {
        PlanViewGridSectionHeaderView *view = [[[self class] headerViewClass] newAutoLayoutView];
        
        _view = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeAll]];
    }
    return _view;
}

+ (Class)headerViewClass {
    return [PlanViewGridSectionHeaderView class];
}

@end

@implementation PlanViewGridSectionMobileHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.view.backgroundColor = [UIColor projectorBlackColor];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.view.state = PlanViewGridSectionStateOff;
}

- (PlanViewGridSectionHeaderView *)view {
    if (!_view) {
        PlanViewGridSectionHeaderView *view = [[[self class] headerViewClass] newAutoLayoutView];
        
        _view = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeAll]];
    }
    return _view;
}


+ (Class)headerViewClass {
    return [PlanViewGridSectionHeaderView class];
}

@end