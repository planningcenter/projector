//
//  PROAlertSettingsBaseView.m
//  
//
//  Created by Skylar Schipper on 4/15/14.
//
//

#import "PROAlertSettingsBaseView.h"

@implementation PROAlertSettingsBaseView

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor modalPositionPickerBackgroundColor];
    self.selectedColor = [UIColor projectorConfirmColor];
    self.selectedStrokeColor = [UIColor modalPositionSelectedStrokeColor];
    self.strokeColor =  [UIColor planGridSectionHeaderItemHeaderBackgroundColor];
    
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 8.0;
    self.layer.masksToBounds = YES;
    self.layer.needsDisplayOnBoundsChange = YES;
}
- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    
    self.layer.borderColor = [strokeColor CGColor];
    self.layer.borderWidth = 1.0;
}

@end
