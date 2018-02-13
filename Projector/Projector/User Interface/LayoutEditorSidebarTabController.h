/*!
 * LayoutEditorSidebarTabController.h
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#ifndef LayoutEditorSidebarTabController_h
#define LayoutEditorSidebarTabController_h

#import "PCOViewController.h"
#import "LayoutEditorInterfaceContainerController.h"

@interface LayoutEditorSidebarTabController : PCOViewController <LayoutEditorInterfaceContainerSubController>

- (void)presentContentViewController:(UIViewController *)controller animated:(BOOL)flag completion:(void (^)(void))completion;

- (void)presentGeneralAnimated:(BOOL)animated;
- (void)presentLyricsAnimated:(BOOL)animated;
- (void)presentSongInfoAnimated:(BOOL)animated;

- (IBAction)controlValueChangedAction:(id)sender;

@end

PCO_EXTERN_STRING LayoutEditorSidebarTabControllerShowSongInfoNotification;
PCO_EXTERN_STRING LayoutEditorSidebarTabControllerHideSongInfoNotification;

#endif
