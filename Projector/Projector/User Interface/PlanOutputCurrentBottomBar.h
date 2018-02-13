/*!
 * PlanOutputCurrentBottomBar.h
 *
 *
 * Created by Skylar Schipper on 4/16/14
 */

#ifndef PlanOutputCurrentBottomBar_h
#define PlanOutputCurrentBottomBar_h

#import "PCOView.h"

@protocol PlanOutputCurrentBottomBarDelegate <NSObject>

- (void)playNextSlide;
- (void)playPreviousSlide;

@end

@interface PlanOutputCurrentBottomBar : PCOControl

@property (nonatomic, weak) id<PlanOutputCurrentBottomBarDelegate> delegate;

@property (nonatomic, weak) PCOView *lineView;
@property (nonatomic, weak) PCOLabel *nameLabel;

@property (nonatomic, weak) PCOButton *leftArrowButton;
@property (nonatomic, weak) PCOButton *rightArrowButton;

@property (nonatomic, weak) UIImageView *loopingIcon;

@end

#endif
