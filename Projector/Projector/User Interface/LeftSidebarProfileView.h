/*!
 * LeftSidebarProfileView.h
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#ifndef LeftSidebarProfileView_h
#define LeftSidebarProfileView_h

#import "PCOView.h"

@interface LeftSidebarProfileView : PCOView

@property (nonatomic, weak) PCOOrganization *organization;
@property (nonatomic, weak) PCOUserData *user;

@end

#endif
