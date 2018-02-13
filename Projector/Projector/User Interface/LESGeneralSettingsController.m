/*!
 * LESGeneralSettingsController.m
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#import "LESGeneralSettingsController.h"
#import "LayoutEditorColorPickerViewController.h"
#import "LayoutEditorSidebarTextFieldTableViewCell.h"

@interface LESGeneralSettingsController () <LayoutEditorColorPickerViewControllerDelegate>

@end

@implementation LESGeneralSettingsController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"General Settings", nil);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"colorPickerSegue"]) {
        LayoutEditorColorPickerViewController *controller = segue.destinationViewController;
        if ([controller isKindOfClass:[LayoutEditorColorPickerViewController class]]) {
            controller.pickerDelegate = self;
            controller.color = self.layout.backgroundColor;
            controller.showAutoContrastOption = YES;
            controller.autoContrastColor = [self.layout isNew];
        }
    }
}

- (void)colorPicker:(LayoutEditorColorPickerViewController *)colorPicker didPickColor:(UIColor *)color withContrastColor:(UIColor *)contrastColor {
    self.layout.backgroundColor = color;
    if (contrastColor) {
        self.textLayout.fontColor = contrastColor;
        self.textLayout.fontShadowColor = [contrastColor contrastColor];
    }
}

- (BOOL)shouldNotShowSection:(NSInteger)section {
    if (section < 2 && [[PROAppDelegate delegate] isPad]) {
        return YES;
    }
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self shouldNotShowSection:section]) {
        return 1;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self shouldNotShowSection:indexPath.section]) {
        return 0;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self shouldNotShowSection:section]) {
        return nil;
    }
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self shouldNotShowSection:section]) {
        return nil;
    }
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    welf();
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
        {
            LayoutEditorSidebarTextFieldTableViewCell *tCell = (LayoutEditorSidebarTextFieldTableViewCell *)cell;
            tCell.textField.text = self.layout.name;
            tCell.textFieldStringChangeHandler = ^(NSString *text) {
                welf.layout.name = text;
            };

            break;
        }
        case 1:
        {
            LayoutEditorSidebarTextFieldTableViewCell *tCell = (LayoutEditorSidebarTextFieldTableViewCell *)cell;
            tCell.textField.text = self.layout.layoutDescription;
            tCell.textFieldStringChangeHandler = ^(NSString *text) {
                welf.layout.layoutDescription = text;
            };
            break;
        }
        case 2:
            
            break;
        default:
            break;
    }
    return cell;
}

@end
