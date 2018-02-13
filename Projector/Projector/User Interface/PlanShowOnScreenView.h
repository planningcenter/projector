/*!
 * PlanShowOnScreenView.h
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#ifndef PlanShowOnScreenView_h
#define PlanShowOnScreenView_h

#import "PCOView.h"

@class PROLogoPickerView;
@class BlackScreenButton;

@interface PlanShowOnScreenView : PCOView

@property (nonatomic, weak, readonly) PCOButton *alertButton;
@property (nonatomic, weak, readonly) PROLogoPickerView *logoView;
@property (nonatomic, weak, readonly) BlackScreenButton *blackScreenButton;

- (void)checkAlertActive;

@property (nonatomic) BOOL blackIsNext;
@property (nonatomic) BOOL blackIsCurrent;

@property (nonatomic) BOOL logoIsNext;
@property (nonatomic) BOOL logoIsCurrent;

@end

#endif
