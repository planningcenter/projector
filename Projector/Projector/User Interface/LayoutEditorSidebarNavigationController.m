/*!
 * LayoutEditorSidebarNavigationController.m
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#import "LayoutEditorSidebarNavigationController.h"

@interface LayoutEditorSidebarNavigationController ()

@end

@implementation LayoutEditorSidebarNavigationController

+ (UIColor *)barTintColorForStyle:(PRONavigationControllerBarStyle)style {
    return [UIColor projectorBlackColor];
}
+ (UIColor *)tintColorForStyle:(PRONavigationControllerBarStyle)style {
    return [UIColor projectorOrangeColor];
}
+ (UIColor *)barTextColorForStyle:(PRONavigationControllerBarStyle)style {
    return [UIColor whiteColor];
}

@end
