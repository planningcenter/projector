/*!
 * PROSwitchTableViewCell.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/14/14
 */

#ifndef Projector_PROSwitchTableViewCell_h
#define Projector_PROSwitchTableViewCell_h

#import "PCOTableViewCell.h"

@interface PROSwitchTableViewCell : PCOTableViewCell

@property (nonatomic, getter = isOn) BOOL on;
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@property (nonatomic, copy) void(^valueChanged)(BOOL value);

@end

OBJC_EXTERN NSString *const PROSwitchTableViewCellIdentifier;

#endif
