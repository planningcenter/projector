/*!
 * SidebarRoundButton.m
 *
 *
 * Created by Skylar Schipper on 3/18/14
 */

#import "SidebarRoundButton.h"

@interface SidebarRoundButton ()

@property (nonatomic) BOOL bouncing;

@end

@implementation SidebarRoundButton

- (void)initializeDefaults {
    [super initializeDefaults];
    self.layer.borderWidth = 2.0;
    self.layer.cornerRadius = 25.0;
    
    self.selected = NO;
    
    [self addTarget:self action:@selector(pro_bounceImage:) forControlEvents:UIControlEventTouchUpInside];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(50.0, 50.0);
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        
        _imageView = view;
        [self addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint center:view inView:self]];
    }
    return _imageView;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.tintColor = [UIColor projectorOrangeColor];
        self.layer.borderColor = [[UIColor projectorOrangeColor] CGColor];
    } else {
        self.tintColor = [UIColor sidebarRoundButtonsOffColor];
        self.layer.borderColor = [[UIColor sidebarRoundButtonsOffColor] CGColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        if (!self.bouncing) {
            [UIView animateWithDuration:0.1 animations:^{
                self.imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
            }];
        }
        self.backgroundColor = pco_kit_GRAY(30.0);
    } else {
        if (!self.bouncing) {
            [UIView animateWithDuration:0.1 animations:^{
                self.imageView.transform = CGAffineTransformIdentity;
            }];
        }
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)pro_bounceImage:(id)sender {
    self.bouncing = YES;
    self.imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:0.3 initialSpringVelocity:10.0 options:0 animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.bouncing = NO;
    }];
    
}

@end
