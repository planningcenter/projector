/*!
 * LESSongInfoSettingsController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 10/3/14
 */

#import "LESSongInfoSettingsController.h"
#import "LayoutEditorColorPickerViewController.h"

@interface LESSongInfoSettingsController () <LayoutEditorColorPickerViewControllerDelegate>

@end

@implementation LESSongInfoSettingsController


- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Song Info Settings", nil);
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

- (BOOL)useCurrentTextLayout {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.fontSize.font = [UIFont defaultFontOfSize_12];
    self.fontFamily.font = [UIFont defaultFontOfSize_12];
    self.textAlignment.font = [UIFont defaultFontOfSize_12];
    self.showOnSlide.font = [UIFont defaultFontOfSize_12];
    
    self.fontSize.textColor = [UIColor layoutEditorSidebarTableViewValueTextColor];
    self.fontFamily.textColor = [UIColor layoutEditorSidebarTableViewValueTextColor];
    self.textAlignment.textColor = [UIColor layoutEditorSidebarTableViewValueTextColor];
    self.showOnSlide.textColor = [UIColor layoutEditorSidebarTableViewValueTextColor];
    
    [self updateDisplayInfo];
}
- (void)updateDisplayInfo {
    self.fontSize.text = [self.layout.songInfoLayout.fontSize stringValue];
    self.fontFamily.text = self.layout.songInfoLayout.fontName;
    self.textAlignment.text = [[NSString stringWithFormat:@"%@ : %@",self.layout.songInfoLayout.verticalAlignment,self.layout.songInfoLayout.textAlignment] capitalizedString];
    
    if ([self.layout.songInfoLayout.showOnAllSlides boolValue]) {
        self.showOnSlide.text = NSLocalizedString(@"All", nil);
    } else if ([self.layout.songInfoLayout.showOnlyOnFirstSlide boolValue]) {
        self.showOnSlide.text = NSLocalizedString(@"First", nil);
    } else if ([self.layout.songInfoLayout.showOnlyOnLastSlide boolValue]) {
        self.showOnSlide.text = NSLocalizedString(@"Last", nil);
    } else {
        self.showOnSlide.text = NSLocalizedString(@"None", nil);
    }
}
- (void)setLayout:(PCOSlideLayout *)layout {
    [super setLayout:layout];
    [self updateDisplayInfo];
}

@end
