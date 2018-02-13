/*!
 * PROAlertView.h
 *
 *
 * Created by Skylar Schipper on 5/6/14
 */

#ifndef PROAlertView_h
#define PROAlertView_h

#import "PROScreenPositionPicker.h"
#import "PROAlertTextStylePicker.h"

@interface PROAlertView : NSObject

- (instancetype)initWithText:(NSString *)text;

@property (nonatomic, strong, readonly) NSString *alertText;
@property (nonatomic, readonly) PROScreenPosition position;
@property (nonatomic, readonly) PROAlertTextStyle style;

- (void)configureLabel:(UILabel *)label;

@end

#endif
