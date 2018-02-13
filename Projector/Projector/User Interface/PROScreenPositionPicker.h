/*!
 * PROScreenPositionPicker.h
 *
 *
 * Created by Skylar Schipper on 4/15/14
 */

#ifndef PROScreenPositionPicker_h
#define PROScreenPositionPicker_h

#import "PCOControl.h"

typedef NS_ENUM(NSInteger, PROScreenPosition) {
    PROScreenTopLeftPosition      = 0,
    PROScreenTopMiddlePosition    = 1,
    PROScreenTopRightPosition     = 2,
    
    PROScreenMiddleLeftPosition   = 3,
    PROScreenMiddleMiddlePosition = 4,
    PROScreenMiddleRightPosition  = 5,
    
    PROScreenBottomLeftPosition   = 6,
    PROScreenBottomMiddlePosition = 7,
    PROScreenBottomRightPosition  = 8,
};

#import "PROAlertSettingsBaseView.h"

@interface PROScreenPositionPicker : PROAlertSettingsBaseView

@property (nonatomic) PROScreenPosition position;

+ (PROScreenPosition)screenPosition;
+ (void)setScreenPosition:(PROScreenPosition)position;

- (PROScreenPosition)positionForPoint:(CGPoint)point;

@end

PCO_EXTERN_STRING PROScreenPositionPickerDidPickPosition;

#endif
