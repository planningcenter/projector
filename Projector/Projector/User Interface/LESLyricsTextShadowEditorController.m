//
//  LESLyricsTextShadowEditorController.m
//  Projector
//
//  Created by Skylar Schipper on 6/23/14.
//

#import "LESLyricsTextShadowEditorController.h"
#import "LayoutEditorColorPickerViewController.h"

@interface LESLyricsTextShadowEditorController () <LayoutEditorColorPickerViewControllerDelegate>

@end

@implementation LESLyricsTextShadowEditorController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Text Shadow", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    welf();
    self.offsetPickerCell.sizePickerHandler = ^(CGSize size) {
        welf.textLayout.fontShadowOffsetX = @(size.width);
        welf.textLayout.fontShadowOffsetY = @(size.height);
        [welf.rootController updateUserInterfaceUpdateForObjectChange:welf];
    };
    [self.offsetPickerCell setSize:[self.textLayout fontShadowOffset]];
    
    self.blurSlider.value = [self.textLayout.fontShadowBlur floatValue];
    self.opacitySlider.value = [self.textLayout.fontShadowOpacity floatValue];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"shadowColorPickerSegue"]) {
        LayoutEditorColorPickerViewController *controller = segue.destinationViewController;
        if ([controller isKindOfClass:[LayoutEditorColorPickerViewController class]]) {
            controller.pickerDelegate = self;
            controller.showAutoContrastOption = NO;
            controller.color = self.textLayout.fontShadowColor;
        }
    }
}

- (void)colorPicker:(LayoutEditorColorPickerViewController *)colorPicker didPickColor:(UIColor *)color withContrastColor:(UIColor *)contrastColor {
    self.textLayout.fontShadowColor = color;
}

- (IBAction)blurValueChanged:(id)sender {
    self.textLayout.fontShadowBlur = @(self.blurSlider.value);
    [self.rootController updateUserInterfaceUpdateForObjectChange:self];
}

- (IBAction)opacityValueChanged:(id)sender {
    self.textLayout.fontShadowOpacity = @(self.opacitySlider.value);
    [self.rootController updateUserInterfaceUpdateForObjectChange:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (indexPath.section == 1 && ![[PROAppDelegate delegate] isPad]) {
        height -= 60;
    }
    return height;
}


@end
