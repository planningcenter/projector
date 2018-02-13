/*!
 * PROSwitch.h
 * MCTSwitch
 *
 *
 * Created by Skylar Schipper on 11/11/14
 */

#ifndef MCTSwitch_PROSwitch_h
#define MCTSwitch_PROSwitch_h

@import UIKit;

@interface PROSwitch : UIControl

@property (nonatomic, getter=isOn) BOOL on;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@property (nonatomic, strong) UIColor *offBackgroundColor;
@property (nonatomic, strong) UIColor *offThumbColor;

@property (nonatomic, strong) UIColor *onBackgroundColor;
@property (nonatomic, strong) UIColor *onThumbColor;

@end

#endif
