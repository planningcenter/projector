/*!
 * PlanViewMobileInfoView.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/3/14
 */

#ifndef Projector_PlanViewMobileInfoView_h
#define Projector_PlanViewMobileInfoView_h

#import "PCOView.h"

@interface PlanViewMobileInfoView : PCOView

@property (nonatomic, weak) PCOLabel *textLabel;

@property (nonatomic, weak) PCOButton *leftButton;
@property (nonatomic, weak) PCOButton *rightButton;

@property (nonatomic, weak) UIImageView *loopingIcon;

@end

#endif
