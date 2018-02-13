/*!
 * PRODisplayViewActionButton.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/10/14
 */

#ifndef Projector_PRODisplayViewActionButton_h
#define Projector_PRODisplayViewActionButton_h

#import "PCOControl.h"

typedef NS_ENUM(NSInteger, PRODisplayViewActionButtonState) {
    PRODisplayViewActionButtonStateOff     = 0,
    PRODisplayViewActionButtonStateNext    = 1,
    PRODisplayViewActionButtonStateCurrent = 2
};

@interface PRODisplayViewActionButton : PCOControl

- (instancetype)initWithTitle:(NSString *)title;

@property (nonatomic, strong, readonly) NSString *title;

@property (nonatomic, weak, readonly) UIView *contentView;

@property (nonatomic) PRODisplayViewActionButtonState actionState;

@end

#endif
