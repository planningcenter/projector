/*!
 * LESLyricsAlignmentHorizontalController.m
 *
 *
 * Created by Skylar Schipper on 6/16/14
 */

#import "LESLyricsTextMarginsEditorController.h"
#import "LayoutEditorSidebarBaseTableViewCell.h"

@interface LESLyricsTextMarginsEditorController ()

@end

@implementation LESLyricsTextMarginsEditorController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Margins", nil);
    
    [LayoutEditorSidebarBaseTableViewCell configureCell:self.topCell];
    [LayoutEditorSidebarBaseTableViewCell configureCell:self.bottomCell];
    [LayoutEditorSidebarBaseTableViewCell configureCell:self.leftCell];
    [LayoutEditorSidebarBaseTableViewCell configureCell:self.rightCell];
    
    self.topCell.textLabel.text = NSLocalizedString(@"Top", nil);
    self.bottomCell.textLabel.text = NSLocalizedString(@"Bottom", nil);
    self.leftCell.textLabel.text = NSLocalizedString(@"Left", nil);
    self.rightCell.textLabel.text = NSLocalizedString(@"Right", nil);
    
    welf();
    self.topCell.valueChangeHandler = ^(LayoutEditorStepperCell *cell, NSNumber *value) {
        welf.textLayout.marginTop = value;
        [welf.rootController updateUserInterfaceUpdateForObjectChange:welf];
    };
    self.bottomCell.valueChangeHandler = ^(LayoutEditorStepperCell *cell, NSNumber *value) {
        welf.textLayout.marginBottom = value;
        [welf.rootController updateUserInterfaceUpdateForObjectChange:welf];
    };
    self.leftCell.valueChangeHandler = ^(LayoutEditorStepperCell *cell, NSNumber *value) {
        welf.textLayout.marginLeft = value;
        [welf.rootController updateUserInterfaceUpdateForObjectChange:welf];
    };
    self.rightCell.valueChangeHandler = ^(LayoutEditorStepperCell *cell, NSNumber *value) {
        welf.textLayout.marginRight = value;
        [welf.rootController updateUserInterfaceUpdateForObjectChange:welf];
    };
}

- (void)updateUserInterfaceForObjectChanges {
    [super updateUserInterfaceForObjectChanges];
    
    self.topCell.value = self.textLayout.marginTop;
    self.bottomCell.value = self.textLayout.marginBottom;
    self.leftCell.value = self.textLayout.marginLeft;
    self.rightCell.value = self.textLayout.marginRight;
}

@end
