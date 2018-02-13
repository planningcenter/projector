/*!
 * LayoutEditorSidebarBaseTableViewController.h
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#ifndef LayoutEditorSidebarBaseTableViewController_h
#define LayoutEditorSidebarBaseTableViewController_h

@import UIKit;

#import "LayoutEditorInterfaceContainerController.h"

#import "PCOSlideLayout.h"
#import "PCOSlideTextLayout.h"

@interface LayoutEditorSidebarBaseTableViewController : UITableViewController <LayoutEditorInterfaceContainerSubController>

@property (nonatomic, weak, readonly) LayoutEditorInterfaceContainerController *rootController;

@property (nonatomic, weak) PCOSlideLayout *layout;

@property (nonatomic, weak) PCOSlideTextLayout *textLayout;

- (BOOL)useCurrentTextLayout;

@end

#endif
