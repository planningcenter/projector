/*!
 * PlanShowOnScreenButton.h
 *
 *
 * Created by Skylar Schipper on 7/14/14
 */

#ifndef PlanShowOnScreenButton_h
#define PlanShowOnScreenButton_h

#import "PCOButton.h"

@interface PlanShowOnScreenButton : PCOButton

@property (nonatomic, strong) UIColor *currentColor;

@property (nonatomic, weak) PCOButton *innerButton;
@property (nonatomic, weak) UIImageView *aspectImageView;

@property (nonatomic) BOOL showPlayButton;

@end

#endif
