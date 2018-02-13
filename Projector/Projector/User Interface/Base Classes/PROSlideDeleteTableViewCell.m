/*!
 * PROSlideDeleteTableViewCell.m
 *
 *
 * Created by Skylar Schipper on 5/15/14
 */

#import "PROSlideDeleteTableViewCell.h"

#import "PCOSlidingSideViewController.h"

#import "PCOLabel.h"
#import "PCOView.h"

#import "PCOKitHelpers.h"

@interface PROSlideDeleteTableViewCell ()

@property (nonatomic, weak) PCOLabel *deleteLabel;

@end

@implementation PROSlideDeleteTableViewCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.rightPannerMax = 0.0;
    self.leftPannerMax = PROSlideDeleteTableViewCellDeleteOffset;
    self.deleteLabel.text = NSLocalizedString(@"Delete", nil);
    self.leftPannerView.backgroundColor = [UIColor sidebarRoundButtonsOffColor];
    
    CGFloat progress = 0.7;
    
    self.closeAction.progress = progress;
    self.openLeftAction.enabled = NO;
    
    welf();
    [self addAction:[PCOSlidingAction actionForType:PCOSlidingActionTypeContinuous direction:PCOSlidingActionDirectionLeft handler:^(PCOSlidingActionCell *cell) {
        if ([welf panProgress] > progress) {
            welf.leftPannerView.backgroundColor = [UIColor projectorDeleteColor];
        } else {
            welf.leftPannerView.backgroundColor = [UIColor sidebarRoundButtonsOffColor];
        }
    }]];
    [self addAction:[PCOSlidingAction actionForType:PCOSlidingActionTypeEndOver direction:PCOSlidingActionDirectionLeft progress:progress handler:^(PCOSlidingActionCell *cell) {
        [welf hidePannerViewsAnimated:YES];
        if ([welf.delegate respondsToSelector:@selector(slideCellShouldDelete:)]) {
            [welf.delegate slideCellShouldDelete:welf];
        }
    }]];
}

- (PCOLabel *)deleteLabel {
    if (!_deleteLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_16];
        label.textColor = [UIColor whiteColor];
        
        _deleteLabel = label;
        [self.leftPannerView addSubview:label];
        
        [self.leftPannerView addConstraint:[NSLayoutConstraint centerViewVerticalyInSuperview:label]];
        [self.leftPannerView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:6.0 edges:UIRectEdgeLeft]];
    }
    return _deleteLabel;
}

@end

CGFloat const PROSlideDeleteTableViewCellDeleteOffset = 100.0;
