/*!
 * PROLayoutPreviewEdgeInsetsView.h
 *
 *
 * Created by Skylar Schipper on 6/18/14
 */

#ifndef PROLayoutPreviewEdgeInsetsView_h
#define PROLayoutPreviewEdgeInsetsView_h

#import "PCOView.h"

@class PROLayoutPreviewEdgeInsetsView;
@protocol PROLayoutPreviewEdgeInsetsViewDelegate <NSObject>

- (void)insetView:(PROLayoutPreviewEdgeInsetsView *)view didChangeInsets:(UIEdgeInsets)insets;

@end

@interface PROLayoutPreviewEdgeInsetsView : PCOView

@property (nonatomic, assign) id<PROLayoutPreviewEdgeInsetsViewDelegate> delegate;

@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIColor *color;

@end

#endif
