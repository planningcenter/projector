/*!
 * LogoPickerSearchBarView.h
 *
 *
 * Created by Skylar Schipper on 7/10/14
 */

#ifndef LogoPickerSearchBarView_h
#define LogoPickerSearchBarView_h

#import "PCOView.h"

@interface LogoPickerSearchBarView : PCOView

@property (nonatomic, copy) void(^searchUpdateHandler)(NSString *searchString, BOOL complete);

@end

#endif
