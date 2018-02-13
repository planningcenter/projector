/*!
 * PlanViewGridUpNextPlayDecorationView.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/13/14
 */

#import "PlanViewGridUpNextPlayDecorationView.h"

@interface PlanViewGridUpNextPlayDecorationView ()

@end

@implementation PlanViewGridUpNextPlayDecorationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        imageView.image = [UIImage imageNamed:@"blue-play-btn"];
        
        [self addSubview:imageView];
    }
    return self;
}

@end
