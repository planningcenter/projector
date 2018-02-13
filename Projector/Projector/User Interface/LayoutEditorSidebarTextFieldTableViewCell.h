//
//  LayoutEditorSidebarTextFieldTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 12/19/14.
//

#import "LayoutEditorSidebarBaseTableViewCell.h"

@interface LayoutEditorSidebarTextFieldTableViewCell : LayoutEditorSidebarBaseTableViewCell

@property (nonatomic, weak) PCOTextField *textField;
@property (nonatomic, copy) void(^textFieldStringChangeHandler)(NSString *);

@end
