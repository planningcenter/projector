/*!
 * LESLyricsAlignmentHorizontalController.h
 *
 *
 * Created by Skylar Schipper on 6/16/14
 */

#ifndef LESLyricsAlignmentHorizontalController_h
#define LESLyricsAlignmentHorizontalController_h

#import "LayoutEditorSidebarBaseTableViewController.h"
#import "LayoutEditorStepperCell.h"

@interface LESLyricsTextMarginsEditorController : LayoutEditorSidebarBaseTableViewController

@property (weak, nonatomic) IBOutlet LayoutEditorStepperCell *topCell;
@property (weak, nonatomic) IBOutlet LayoutEditorStepperCell *bottomCell;
@property (weak, nonatomic) IBOutlet LayoutEditorStepperCell *leftCell;
@property (weak, nonatomic) IBOutlet LayoutEditorStepperCell *rightCell;

@end

#endif
