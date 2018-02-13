/*!
 * LESLyricsSettingsController.m
 *
 *
 * Created by Skylar Schipper on 6/12/14
 */

#import "LESLyricsSettingsController.h"
#import "LayoutEditorColorPickerViewController.h"

@interface LESLyricsSettingsController () <LayoutEditorColorPickerViewControllerDelegate>

@end

@implementation LESLyricsSettingsController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Lyrics Settings", nil);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"colorPicker"]) {
        LayoutEditorColorPickerViewController *controller = segue.destinationViewController;
        if ([controller isKindOfClass:[LayoutEditorColorPickerViewController class]]) {
            controller.pickerDelegate = self;
            controller.showAutoContrastOption = NO;
            controller.color = self.textLayout.fontColor;
        }
    }
}

- (void)colorPicker:(LayoutEditorColorPickerViewController *)colorPicker didPickColor:(UIColor *)color withContrastColor:(UIColor *)contrastColor {
    self.textLayout.fontColor = color;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.fontSize.font = [UIFont defaultFontOfSize_12];
    self.fontFamily.font = [UIFont defaultFontOfSize_12];
    self.textAlignment.font = [UIFont defaultFontOfSize_12];
    
    self.fontSize.textColor = [UIColor layoutEditorSidebarTableViewValueTextColor];
    self.fontFamily.textColor = [UIColor layoutEditorSidebarTableViewValueTextColor];
    self.textAlignment.textColor = [UIColor layoutEditorSidebarTableViewValueTextColor];
    
    [self updateDisplayInfo];
}
- (void)updateDisplayInfo {
    self.fontSize.text = [self.layout.lyricTextLayout.fontSize stringValue];
    self.fontFamily.text = self.layout.lyricTextLayout.fontName;
    self.textAlignment.text = [[NSString stringWithFormat:@"%@ : %@",self.layout.lyricTextLayout.verticalAlignment,self.layout.lyricTextLayout.textAlignment] capitalizedString];
}
- (void)setLayout:(PCOSlideLayout *)layout {
    [super setLayout:layout];
    [self updateDisplayInfo];
}

@end
