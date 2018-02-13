//
//  CommonNavButton.m
//  Projector
//
//  Created by Peter Fokos on 10/17/14.
//

#import "CommonNavButton.h"

@implementation CommonNavButton

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont defaultFontOfSize_14];
        [self setTitle:text forState:UIControlStateNormal];
        [self setTitleColor:color forState:UIControlStateNormal];
    }
    return self;
}

- (void)showBackArrow {
    UIImage *arrow = [UIImage imageNamed:@"nav_back_arrow"];
    [self setImage:arrow forState:UIControlStateNormal];
    self.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
}

+ (CGRect)frameWithText:(NSString *)text backArrow:(BOOL)backArrow {
    CGSize size = [text sizeWithAttributes:@{ NSFontAttributeName :[UIFont defaultFontOfSize_14] }] ;
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    if (backArrow) {
        frame.size.width += 20;
    }
    return frame;
}

@end
