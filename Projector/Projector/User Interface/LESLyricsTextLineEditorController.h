/*!
 * LESLyricsTextLineEditorController.h
 *
 *
 * Created by Skylar Schipper on 6/24/14
 */

#ifndef LESLyricsTextLineEditorController_h
#define LESLyricsTextLineEditorController_h

#import "LayoutEditorSidebarBaseTableViewController.h"

@interface LESLyricsTextLineEditorController : LayoutEditorSidebarBaseTableViewController

@property (weak, nonatomic) IBOutlet UISlider *lineSpacingSlider;
@property (weak, nonatomic) IBOutlet UISlider *lineCountSliderControl;
@property (weak, nonatomic) IBOutlet UILabel *lineCountLabel;

- (IBAction)lineSpacingValueChanged:(id)sender;
- (IBAction)lineCountSliderValueChanged:(id)sender;

@end

#endif
