/*!
 * LESLyricsSettingsController.h
 *
 *
 * Created by Skylar Schipper on 6/12/14
 */

#ifndef LESLyricsSettingsController_h
#define LESLyricsSettingsController_h

#import "LayoutEditorSidebarBaseTableViewController.h"

@interface LESLyricsSettingsController : LayoutEditorSidebarBaseTableViewController

@property (nonatomic, weak) IBOutlet UILabel *fontSize;
@property (nonatomic, weak) IBOutlet UILabel *fontFamily;
@property (nonatomic, weak) IBOutlet UILabel *textAlignment;

@end

#endif
