/*!
 * PROLogoLoadingView.m
 *
 *
 * Created by Skylar Schipper on 5/9/14
 */

#import "PROLogoLoadingView.h"

@interface _PROLogoLoadingViewBase : PCOView
@property (nonatomic) CGFloat width;
@end

@interface _PROLogoLoadingViewContent : _PROLogoLoadingViewBase @end
@interface _PROLogoLoadingViewOuter : _PROLogoLoadingViewBase @end
@interface _PROLogoLoadingViewInner : _PROLogoLoadingViewBase @end

@interface PROLogoLoadingView ()

@property (nonatomic) BOOL animating;

@property (nonatomic, weak) _PROLogoLoadingViewContent *contentView;
@property (nonatomic, weak) _PROLogoLoadingViewInner *innerView;
@property (nonatomic, weak) _PROLogoLoadingViewOuter *outerView;

@end

@implementation PROLogoLoadingView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.sizeIndex = 8.0;
    
    self.layer.cornerRadius = floorf([self intrinsicContentSize].width / 2.0);
    self.clipsToBounds = YES;
    
    self.backgroundColor = [UIColor projectorOrangeColor];
    
    self.contentView.alpha = 0.0;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(48.0, 48.0);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    CGFloat playInsets = self.sizeIndex;
    CGRect playFrame = CGRectIntegral(UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(playInsets, playInsets, playInsets, playInsets)));
    self.outerView.frame = playFrame;
    
    playInsets += (self.sizeIndex);
    if (self.sizeIndex > 4.0) {
        
    }
    playFrame = CGRectIntegral(UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(playInsets, playInsets, playInsets, playInsets)));
    self.innerView.frame = playFrame;
    
    [super layoutSubviews];
}

- (void)startAnimating {
    if ([self isAnimating]) {
        return;
    }
    self.animating = YES;
    
    [self spinOuter];
    [self spinInner];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.alpha = 1.0;
    }];
}
- (void)stopAnimating {
    if (![self isAnimating]) {
        return;
    }
    self.animating = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self cleanup];
    }];
}
- (BOOL)isAnimating {
    return self.animating;
}

- (void)spinOuter {
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @0.0;
    animation.toValue = @(2 * M_PI);
    animation.duration = 2.0;
    animation.repeatCount = MAXFLOAT;
    [self.outerView.layer addAnimation:animation forKey:@"rotation_outer"];
}
- (void)spinInner {
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @0.0;
    animation.toValue = @(-(2 * M_PI));
    animation.duration = 2.5;
    animation.repeatCount = MAXFLOAT;
    [self.innerView.layer addAnimation:animation forKey:@"rotation_innerz"];
}
- (void)cleanup {
    [self.outerView.layer removeAllAnimations];
    [self.innerView.layer removeAllAnimations];
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark - Lazy Loaders
- (_PROLogoLoadingViewOuter *)outerView {
    if (!_outerView) {
        _PROLogoLoadingViewOuter *outer = [[_PROLogoLoadingViewOuter alloc] initWithFrame:CGRectZero];
        outer.backgroundColor = [UIColor clearColor];
        _outerView = outer;
        [self.contentView addSubview:outer];
    }
    return _outerView;
}
- (_PROLogoLoadingViewInner *)innerView {
    if (!_innerView) {
        _PROLogoLoadingViewInner *inner = [[_PROLogoLoadingViewInner alloc] initWithFrame:CGRectZero];
        inner.backgroundColor = [UIColor clearColor];
        _innerView = inner;
        [self.contentView addSubview:inner];
    }
    return _innerView;
}
- (_PROLogoLoadingViewContent *)contentView {
    if (!_contentView) {
        _PROLogoLoadingViewContent *content = [[_PROLogoLoadingViewContent alloc] initWithFrame:CGRectZero];
        content.backgroundColor = self.backgroundColor;
        _contentView = content;
        [self addSubview:content];
    }
    return _contentView;
}

- (void)setSizeIndex:(CGFloat)sizeIndex {
    _sizeIndex = sizeIndex;
    self.contentView.width = ceilf(sizeIndex / 2.0);
    self.outerView.width = MAX(ceilf(sizeIndex / 2.0) - 1.0, 2.0);
    self.innerView.width = self.outerView.width;
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.contentView.backgroundColor = backgroundColor;
    [self.contentView setNeedsDisplay];
}

@end


@implementation _PROLogoLoadingViewOuter

- (void)drawRect:(CGRect)rect {
    [[UIColor whiteColor] set];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), PCOKitRectGetHalfHeight(self.bounds))] addClip];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1.5, 1.5, 1.5, 1.5))];
    path.lineWidth = self.width;
    [path stroke];
}

@end

@implementation _PROLogoLoadingViewInner

- (void)drawRect:(CGRect)rect {
    [[UIColor whiteColor] set];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0.0, PCOKitRectGetHalfHeight(self.bounds), CGRectGetWidth(self.bounds), PCOKitRectGetHalfHeight(self.bounds))] addClip];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1.5, 1.5, 1.5, 1.5))];
    path.lineWidth = self.width;
    [path stroke];
}

@end

@implementation _PROLogoLoadingViewContent

- (void)drawRect:(CGRect)rect {
    [self layoutIfNeeded];
    
    [[UIColor whiteColor] set];
    
    [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.superview.layer.cornerRadius] fill];
    
    [self.backgroundColor set];
    
    [[UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(self.width, self.width, self.width, self.width)) cornerRadius:self.superview.layer.cornerRadius - self.width] fill];
}

@end

@implementation _PROLogoLoadingViewBase

- (void)setWidth:(CGFloat)width {
    _width = width;
    [self setNeedsDisplay];
}

@end
