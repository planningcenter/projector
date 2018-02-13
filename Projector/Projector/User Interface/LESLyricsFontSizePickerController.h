/*!
 * LESLyricsFontSizePickerController.h
 *
 *
 * Created by Skylar Schipper on 6/12/14
 */

#ifndef LESLyricsFontSizePickerController_h
#define LESLyricsFontSizePickerController_h

#import "LayoutEditorSidebarBaseTableViewController.h"

@interface LESLyricsFontSizePickerController : LayoutEditorSidebarBaseTableViewController

@property (weak, nonatomic) IBOutlet UILabel *fontSizeLabel;

@property (weak, nonatomic) IBOutlet UISlider *sizeSlider;
- (IBAction)sizeSliderChangedValue:(id)sender;

@end

#endif
