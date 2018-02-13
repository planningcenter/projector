/*!
 * LESLyricsFontSizePickerController.m
 *
 *
 * Created by Skylar Schipper on 6/12/14
 */

#import "LESLyricsFontSizePickerController.h"

@interface LESLyricsFontSizePickerController ()

@end

@implementation LESLyricsFontSizePickerController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Font Size", nil);
    
    self.fontSizeLabel.font = [UIFont defaultFontOfSize_18];
    self.fontSizeLabel.textColor = [UIColor whiteColor];
}

- (void)setTextLayout:(PCOSlideTextLayout *)textLayout {
    [super setTextLayout:textLayout];
    self.sizeSlider.value = [textLayout.fontSize floatValue];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%.0f pt",[textLayout.fontSize floatValue]];
}

- (IBAction)sizeSliderChangedValue:(id)sender {
    self.textLayout.fontSize = @(self.sizeSlider.value);
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%.0f pt",self.sizeSlider.value];
    [self.rootController updateUserInterfaceUpdateForObjectChange:self];
}

@end
