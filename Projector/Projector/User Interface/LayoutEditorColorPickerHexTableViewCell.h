//
//  LayoutEditorColorPickerHexTableViewCell.h
//  Projector
//
//  Created by Skylar Schipper on 6/23/14.
//

#import "LayoutEditorSidebarBaseTableViewCell.h"
#import "ColorPickerHexTextField.h"

@interface LayoutEditorColorPickerHexTableViewCell : LayoutEditorSidebarBaseTableViewCell

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, copy) void(^hexColorStringChangeHandler)(UIColor *);

@end
