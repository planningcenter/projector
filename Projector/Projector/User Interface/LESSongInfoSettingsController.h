/*!
 * LESSongInfoSettingsController.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 10/3/14
 */

#ifndef Projector_LESSongInfoSettingsController_h
#define Projector_LESSongInfoSettingsController_h

#import "LayoutEditorSidebarBaseTableViewController.h"

@interface LESSongInfoSettingsController : LayoutEditorSidebarBaseTableViewController

@property (nonatomic, weak) IBOutlet UILabel *fontSize;
@property (nonatomic, weak) IBOutlet UILabel *fontFamily;
@property (nonatomic, weak) IBOutlet UILabel *textAlignment;
@property (nonatomic, weak) IBOutlet UILabel *showOnSlide;

@end

#endif
