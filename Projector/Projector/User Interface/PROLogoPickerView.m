/*!
 * PROLogoPickerView.m
 *
 *
 * Created by Skylar Schipper on 6/26/14
 */

#import "PROLogoPickerView.h"

@interface PROLogoPickerView ()

@end

@implementation PROLogoPickerView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.innerButton.userInteractionEnabled = YES;
    
    self.innerButton.layer.borderColor = [[self.innerButton titleColorForState:UIControlStateNormal] CGColor];
    self.innerButton.layer.borderWidth = 1.0;
    self.innerButton.layer.cornerRadius = 4.0;
}

@end
