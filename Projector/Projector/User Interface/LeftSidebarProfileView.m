/*!
 * LeftSidebarProfileView.m
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#import "LeftSidebarProfileView.h"
#import <MCTDataCache/MCTDataCache.h>

@interface LeftSidebarProfileView ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) PCOLabel *nameLabel;
@property (nonatomic, weak) PCOLabel *orgLabel;

@end

@implementation LeftSidebarProfileView

- (void)initializeDefaults {
    [super initializeDefaults];
    self.backgroundColor = [UIColor sidebarBackgroundColor];
}

#pragma mark -
#pragma mark - Lazy loaders
- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *image = [UIImageView newAutoLayoutView];
        image.contentMode = UIViewContentModeProjectorPreferred;
        
        _imageView = image;
        [self addSubview:image];
        
        [self addConstraints:[NSLayoutConstraint size:CGSizeMake(40.0, 40.0) forView:image]];
        [self addConstraint:[NSLayoutConstraint centerVertical:image inView:self]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:image attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10.0]];
    }
    return _imageView;
}
- (PCOLabel *)nameLabel {
    if (!_nameLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_16];
        label.textColor = [UIColor sidebarDetailsTextColor];
        
        _nameLabel = label;
        [self addSubview:label];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:2.0]];
    }
    return _nameLabel;
}
- (PCOLabel *)orgLabel {
    if (!_orgLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = [UIColor sidebarDetailsTextColor];
        
        _orgLabel = label;
        [self addSubview:label];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:10.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-2.0]];
    }
    return _orgLabel;
}


#pragma mark -
#pragma mark - Layout
- (CGSize)intrinsicContentSize {
    return CGSizeMake(0.0, 60.0);
}

#pragma mark -
#pragma mark - data
- (void)setUser:(PCOUserData *)user {
    _user = user;
    
    NSURL *userURL = [NSURL URLWithString:user.photoUrl];
    if (userURL) {
        [[MCTDataCacheController sharedCache] cachedImageAtURL:userURL completion:^(UIImage *image, NSError *error) {
            if (image) {
                self.imageView.image = image;
            }
        }];
    }
    
    self.nameLabel.text = [user fullName];
}
- (void)setOrganization:(PCOOrganization *)organization {
    _organization = organization;
    self.orgLabel.text = [organization localizedDescription];
}

@end
