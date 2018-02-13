/*!
 * HelpButton.m
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#import "HelpButton.h"

@interface HelpButton ()

@end

@implementation HelpButton

- (void)initializeDefaults {
    [super initializeDefaults];
    
    [self pco_startListeningForFontSizeChanges];
    
    self.intrinsicContentSizeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor projectorOrangeColor] CGColor];
    self.layer.cornerRadius = 6.0;
    
    [self setTitleColor:[UIColor sidebarTextColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}
- (void)dealloc {
    [self pco_stopListeningForFontSizeChanges];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width = MAX(280.0, size.width);
    return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = ({
        CGRect frame = CGRectZero;
        frame.size = self.imageView.image.size;
        frame.origin.x = 20.0 - CGRectGetWidth(frame) / 2.0;
        frame.origin.y = (CGRectGetHeight(self.bounds) / 2.0) - (CGRectGetHeight(frame) / 2.0);
        CGRectIntegral(frame);
    });
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = [UIColor blackColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)updatePreferredFontSize {
    self.titleLabel.font = [UIFont defaultFontForStyle:UIFontTextStyleSubheadline];
}

@end
