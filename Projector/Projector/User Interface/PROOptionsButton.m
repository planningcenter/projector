/*!
 * PROOptionsButton.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/9/14
 */

#import "PROOptionsButton.h"

@interface PROOptionsButtonInnerView : PCOView

@end

@interface PROOptionsButton ()

@property (nonatomic, weak) UIVisualEffectView *effectView;

@property (nonatomic, weak) PROOptionsButtonInnerView *inner;

@end

@implementation PROOptionsButton

- (CGSize)intrinsicContentSize {
    return CGSizeMake(40.0, 40.0);
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.layer.needsDisplayOnBoundsChange = YES;
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:effect];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.userInteractionEnabled = NO;
    
    view.layer.cornerRadius = self.intrinsicContentSize.width / 2.0;
    view.layer.masksToBounds = YES;
    
    _effectView = view;
    [self addSubview:view];
    [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeAll]];
    
    PROOptionsButtonInnerView *inner = [PROOptionsButtonInnerView newAutoLayoutView];
    inner.backgroundColor = [UIColor clearColor];
    
    _inner = inner;
    [self.contentView addSubview:inner];
    [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:inner offset:0.0 edges:UIRectEdgeAll]];
    
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (UIView *)contentView {
    return self.effectView.contentView;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.inner.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        self.inner.transform = CGAffineTransformIdentity;
    }
}

@end

@implementation PROOptionsButtonInnerView

- (void)drawRect:(CGRect)rect {
    [[UIColor whiteColor] set];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Oval Drawing
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0))];
    ovalPath.lineWidth = 2.0;
    [ovalPath stroke];
    
    //// Group
    {
        //// Rectangle Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 8, 22.27);
        CGContextRotateCTM(context, -30 * M_PI / 180);
        
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 14, 2) cornerRadius: 1];
        [rectanglePath fill];
        
        CGContextRestoreGState(context);
        
        
        //// Rectangle 2 Drawing
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 20, 15.27);
        CGContextRotateCTM(context, 30 * M_PI / 180);
        
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 14, 2) cornerRadius: 1];
        [rectangle2Path fill];
        
        CGContextRestoreGState(context);
    }

}

@end
