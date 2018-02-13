/*!
 * PlanViewGridItemCell.m
 *
 *
 * Created by Skylar Schipper on 3/26/14
 */

#import "PlanViewGridItemCell.h"
#import "PlanViewGridCollectionViewLayout.h"

@interface PlanViewGridItemCell ()

@property (nonatomic, weak) PCOView *previewView;

@end

@implementation PlanViewGridItemCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor clearColor];
}

- (PCOView *)previewView {
    if (!_previewView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        
        _previewView = view;
        [self.contentView addSubview:view];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:PlanViewGridPadding edges:UIRectEdgeAll]];
    }
    return _previewView;
}

- (void)setThumbnailView:(UIView *)thumbnailView {
    if ([thumbnailView superview]) {
        [thumbnailView removeFromSuperview];
    }
    
    if (_thumbnailView != thumbnailView && _thumbnailView.superview == self.previewView) {
        [_thumbnailView removeFromSuperview];
    }
    
    _thumbnailView = thumbnailView;
    
    if (!thumbnailView) {
        return;
    }
    
    thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.previewView addSubview:thumbnailView];
    
    [self.previewView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:thumbnailView offset:0.0 edges:UIRectEdgeAll]];
}

@end
