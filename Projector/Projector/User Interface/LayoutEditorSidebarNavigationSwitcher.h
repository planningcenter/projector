/*!
 * LayoutEditorSidebarNavigationSwitcher.h
 *
 *
 * Created by Skylar Schipper on 6/25/14
 */

#ifndef LayoutEditorSidebarNavigationSwitcher_h
#define LayoutEditorSidebarNavigationSwitcher_h

#import "PCOControl.h"

typedef NS_ENUM(NSUInteger, LayoutEditorSidebarNavigationSwitcherSection) {
    LayoutEditorSidebarNavigationSwitcherSectionGeneral  = 0,
    LayoutEditorSidebarNavigationSwitcherSectionLyrics   = 1,
    LayoutEditorSidebarNavigationSwitcherSectionSongInfo = 2,
};

@interface LayoutEditorSidebarNavigationSwitcher : PCOControl

@property (nonatomic) LayoutEditorSidebarNavigationSwitcherSection section;

@end

#endif
