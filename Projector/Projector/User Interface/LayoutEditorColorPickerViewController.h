//
//  LayoutEditorColorPickerViewController.h
//  Projector
//
//  Created by Skylar Schipper on 6/23/14.
//

#import "LayoutEditorSidebarBaseTableViewController.h"

@protocol LayoutEditorColorPickerViewControllerDelegate;

@interface LayoutEditorColorPickerViewController : LayoutEditorSidebarBaseTableViewController

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) id<LayoutEditorColorPickerViewControllerDelegate> pickerDelegate;

@property (nonatomic, assign, getter = shouldAutoContrastColor) BOOL autoContrastColor;
@property (nonatomic, assign, getter = shouldShowAutoContrastOption) BOOL showAutoContrastOption;

@end

@protocol LayoutEditorColorPickerViewControllerDelegate <NSObject>

@required
/**
 *  Called when the user selects a color
 *
 *  @param colorPicker   The color picker controller
 *  @param color         The color the use picked
 *  @param contrastColor The contrast color for the picked color, or nil if autoContrastColor is NO
 */
- (void)colorPicker:(LayoutEditorColorPickerViewController *)colorPicker didPickColor:(UIColor *)color withContrastColor:(UIColor *)contrastColor;

@end
