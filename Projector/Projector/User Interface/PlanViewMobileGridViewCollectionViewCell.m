/*!
 * PlanViewMobileGridViewCollectionViewCell.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/4/14
 */

#import "PlanViewMobileGridViewCollectionViewCell.h"
#import "PROSlide.h"
#import "PROThumbnailView.h"

@interface PlanViewMobileGridViewCollectionViewCell ()

@end

@implementation PlanViewMobileGridViewCollectionViewCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor blackColor];
}

- (void)setSlide:(PROSlide *)slide {
    _slide = slide;
    
    UIView *view = [slide thumbnailView];
    if (!view.superview || view.superview != self.contentView) {
        [view removeFromSuperview];
        
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:view];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeAll]];
    }
}

@end

_PCO_EXTERN_STRING PlanViewMobileGridViewCollectionViewCellIdentifier = @"PlanViewMobileGridViewCollectionViewCellIdentifier";
CGFloat const PlanViewMobileGridViewCollectionViewCellBottomBarHeight = 24.0;