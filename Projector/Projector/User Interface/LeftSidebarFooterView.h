/*!
 * LeftSidebarFooterView.h
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#ifndef LeftSidebarFooterView_h
#define LeftSidebarFooterView_h

#import "PCOView.h"

@interface LeftSidebarFooterView : PCOView

@property (nonatomic, weak) PCOButton *logoutButton;
@property (nonatomic, weak) PCOButton *helpButton;
@property (nonatomic, weak) PCOButton *settingsButton;

@end

#endif
