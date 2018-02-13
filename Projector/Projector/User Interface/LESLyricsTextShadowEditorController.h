//
//  LESLyricsTextShadowEditorController.h
//  Projector
//
//  Created by Skylar Schipper on 6/23/14.
//

#import "LayoutEditorSidebarBaseTableViewController.h"
#import "LESLyricsEditorTextShadowOffsetCell.h"

@interface LESLyricsTextShadowEditorController : LayoutEditorSidebarBaseTableViewController

@property (weak, nonatomic) IBOutlet LESLyricsEditorTextShadowOffsetCell *offsetPickerCell;
@property (weak, nonatomic) IBOutlet UISlider *blurSlider;
@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;

- (IBAction)blurValueChanged:(id)sender;
- (IBAction)opacityValueChanged:(id)sender;

@end
