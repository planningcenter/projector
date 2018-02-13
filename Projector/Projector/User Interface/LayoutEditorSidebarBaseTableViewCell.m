/*!
 * LayoutEditorSidebarBaseTableViewCell.m
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#import "LayoutEditorSidebarBaseTableViewCell.h"

@interface LayoutEditorSidebarBaseTableViewCell ()

@end

@implementation LayoutEditorSidebarBaseTableViewCell

/**
 *  This is here because... well, I don't know.
 *
 *  But it makes the cells look right so...
 *
 *  - S
 */
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self updateColors];
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.clipsToBounds = YES;
    
    [self updateColors];
}

- (void)updateColors {
    [[self class] configureCell:self];
}
+ (void)configureCell:(UITableViewCell *)cell {
    cell.backgroundColor = pco_kit_GRAY(25.0);
    cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    cell.backgroundView.backgroundColor = cell.backgroundColor;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.font = [UIFont defaultFontOfSize_14];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    for (UILabel *label in cell.contentView.subviews) {
        if ([label respondsToSelector:@selector(setFont:)]) {
            label.font = [UIFont defaultFontOfSize:label.font.pointSize];
        }
        if ([label respondsToSelector:@selector(setTextColor:)]) {
            label.textColor = [UIColor whiteColor];
        }
    }
}

@end
