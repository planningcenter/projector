//
//  LeftHandReorderTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 10/20/14.
//

#import "LeftHandReorderTableViewCell.h"

@implementation LeftHandReorderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.showsReorderControl = YES;
    if (self.backgroundView == nil) {
        self.backgroundView = [[UIView alloc] init];
    }
    self.backgroundView.backgroundColor = [UIColor redColor];
}

+ (void)clearSubviewsTransforms:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if (!CGAffineTransformIsIdentity(subview.transform)) {
            subview.transform = CGAffineTransformIdentity;
        }
        [self clearSubviewsTransforms:subview];
    }
}

- (void)repositionReorderControl {
    for (UIView* view in [self subviews]) {
        if ([[[view class] description] isEqualToString:@"UITableViewCellReorderControl"]) {
            view.backgroundColor = [UIColor clearColor];
            UIView* resizedGripView = [[UIView alloc] initWithFrame:self.bounds];
            resizedGripView.tag = 12345;
            resizedGripView.backgroundColor = [UIColor clearColor];
            [resizedGripView addSubview:view];
            [self addSubview:resizedGripView];
            
            CGSize sizeDifference = CGSizeMake(CGRectGetWidth(resizedGripView.frame) - CGRectGetWidth(view.frame), CGRectGetHeight(resizedGripView.frame) - CGRectGetHeight(view.frame));
            sizeDifference.width += 15;
            
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformTranslate(transform, -sizeDifference.width, -sizeDifference.height);
            [resizedGripView setTransform:transform];
            
            for (UIImageView* cellGrip in view.subviews) {
                if ([cellGrip isKindOfClass:[UIImageView class]]) {
                    cellGrip.contentMode = UIViewContentModeCenter;
                    [cellGrip setImage:[UIImage imageNamed:@"drag-icon"]];
                    cellGrip.hidden = YES;
                    
                    cellGrip.frame = CGRectMake(cellGrip.frame.origin.x, cellGrip.frame.origin.y, cellGrip.frame.size.width, cellGrip.frame.size.height * 2.5);
                }
            }
        }
        if (view.tag == 12345) {
            view.transform = CGAffineTransformIdentity;
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformTranslate(transform, -(self.frame.size.width-52+15), 0);
            [view setTransform:transform];
        }
    }
}

@end
