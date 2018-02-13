/*!
 * PROAlertView.m
 *
 *
 * Created by Skylar Schipper on 5/6/14
 */

#import "PROAlertView.h"

@interface PROAlertView ()

@property (nonatomic, strong, readwrite) NSString *alertText;
@property (nonatomic, readwrite) PROScreenPosition position;
@property (nonatomic, readwrite) PROAlertTextStyle style;

@end

@implementation PROAlertView

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.alertText = text;
        self.position = [PROScreenPositionPicker screenPosition];
        self.style = [PROAlertTextStylePicker style];
    }
    return self;
}

- (void)configureLabel:(UILabel *)label {
    label.textColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.shadowColor = [UIColor blackColor];
    
    switch (self.style) {
        case PROAlertTextStyleClear:
            label.backgroundColor = [UIColor clearColor];
            break;
        case PROAlertTextStyleBlack:
            label.backgroundColor = [UIColor blackColor];
            break;
        case PROAlertTextStyleWhite:
            label.backgroundColor = [UIColor whiteColor];
            label.textColor = [UIColor blackColor];
            label.shadowOffset = CGSizeMake(0.0, 0.0);
            break;
        default:
            break;
    }
}

@end
