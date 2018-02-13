/*!
 * PROAlertTextStylePicker.h
 *
 *
 * Created by Skylar Schipper on 4/15/14
 */

#ifndef PROAlertTextStylePicker_h
#define PROAlertTextStylePicker_h

#import "PROAlertSettingsBaseView.h"

typedef NS_ENUM(NSInteger, PROAlertTextStyle) {
    PROAlertTextStyleClear = 0,
    PROAlertTextStyleBlack = 1,
    PROAlertTextStyleWhite = 2
};

@interface PROAlertTextStylePicker : PROAlertSettingsBaseView

+ (void)setStyle:(PROAlertTextStyle)style;
+ (PROAlertTextStyle)style;

@end

PCO_EXTERN_STRING PROAlertTextStylePickerChangeNotification;

#endif
