/*!
 * LESLyricsTextLineEditorController.m
 *
 *
 * Created by Skylar Schipper on 6/24/14
 */

#import "LESLyricsTextLineEditorController.h"

#define MAX_LINE_COUNT 14

@interface LESLyricsTextLineEditorController ()

@end

@implementation LESLyricsTextLineEditorController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Lines", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.lineSpacingSlider.value = [self.textLayout.lineSpacing floatValue];
    self.lineCountSliderControl.maximumValue = MAX_LINE_COUNT;
    self.lineCountLabel.font = [UIFont defaultFontOfSize_18];
    self.lineCountLabel.textColor = [UIColor whiteColor];
    
    [self updateLineCount:RANGE(1, MAX_LINE_COUNT, [self.textLayout.defaultLinesPerSlide integerValue])];
}

- (IBAction)lineSpacingValueChanged:(id)sender {
    self.textLayout.lineSpacing = @(self.lineSpacingSlider.value);
    [self.rootController updateUserInterfaceUpdateForObjectChange:self];
}
- (IBAction)lineCountSliderValueChanged:(id)sender {
    float_t value = roundf(self.lineCountSliderControl.value);
    [self updateLineCount:(NSInteger)value];
}

- (void)updateLineCount:(NSInteger)count {
    self.lineCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%td Line%@", nil),count,(count == 1) ? @"" : @"s"];
    [self.lineCountSliderControl setValue:(float_t)count animated:YES];
    
    self.textLayout.defaultLinesPerSlide = @(RANGE(1, MAX_LINE_COUNT, count));
    [self.rootController updateUserInterfaceUpdateForObjectChange:self];
}

@end
