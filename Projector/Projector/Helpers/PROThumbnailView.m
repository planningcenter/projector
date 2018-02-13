//
//  PROSlideThumbnail.m
//  
//
//  Created by Skylar Schipper on 4/10/14.
//
//

#import "PROThumbnailView.h"

@interface PROThumbnailView ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) PCOLabel *label;

@end

static CGFloat __PROThumbnailViewCellHeight = 44.0;

@implementation PROThumbnailView
@synthesize slideNameView = _slideNameView;

- (void)initializeDefaults {
    [super initializeDefaults];

    self.clipsToBounds = YES;
}


+ (void)setThumbnailViewNameHeight:(CGFloat)height {
    __PROThumbnailViewCellHeight = height;
}
+ (CGFloat)thumbnailViewNameHeight {
    return __PROThumbnailViewCellHeight;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.label.text = title;
}

- (PCOLabel *)label {
    if (!_label) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.backgroundColor = self.slideNameView.backgroundColor;
        label.textColor = [UIColor sidebarTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        if ([self.class thumbnailViewNameHeight] < 44.0) {
            label.font = [UIFont defaultFontOfSize_12];
        } else {
            label.font = [UIFont defaultFontOfSize_14];
        }
        
        _label = label;
        [self.slideNameView addSubview:label];
        
        [self.slideNameView addConstraints:[NSLayoutConstraint insetViewInSuperview:label insets:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)]];
    }
    return _label;
}

- (PCOView *)slideNameView {
    if (!_slideNameView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor projectorBlackColor];
        
        _slideNameView = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight]];
        [self addConstraint:[NSLayoutConstraint height:[self.class thumbnailViewNameHeight] forView:view]];
    }
    return _slideNameView;
}
- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [UIImageView newAutoLayoutView];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeProjectorPreferred;
        
        _imageView = imageView;
        [self insertSubview:imageView atIndex:0];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:imageView offset:-1.0 edges:UIRectEdgeTop | UIRectEdgeLeft | UIRectEdgeRight]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.slideNameView attribute:NSLayoutAttributeTop multiplier:1.0 constant:1.0]];
    }
    return _imageView;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _contentView = contentView;
    
    [self addSubview:contentView];
    
    [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:contentView offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeTop | UIRectEdgeRight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.slideNameView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    self.imageView.contentMode = contentMode;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    if (!backgroundImage) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    } else {
        self.imageView.image = backgroundImage;
    }
}

- (PROSlideTextLabel *)textLabel {
    if (!_textLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        
        _textLabel = label;
        self.contentView = label;
    }
    return _textLabel;
}
- (PROSlideTextLabel *)infoLabel {
    if (!_infoLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        
        _infoLabel = label;
        [self insertSubview:label aboveSubview:self.textLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    }
    return _infoLabel;
}

@end
