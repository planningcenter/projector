//
//  PROSidebarDetailsCell.m
//  
//
//  Created by Skylar Schipper on 4/9/14.
//
//

#import "PROSidebarDetailsCell.h"
#import "PCOSlidingActionCell.h"

@implementation PROSidebarDetailsCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    [[self class] configureCell:self];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    
    if ([self respondsToSelector:@selector(titleLabel)]) {
        UILabel *label = [self performSelector:@selector(titleLabel) withObject:nil];
        label.text = nil;
    }
    if ([self respondsToSelector:@selector(subTitleLabel)]) {
        UILabel *label = [self performSelector:@selector(subTitleLabel) withObject:nil];
        label.text = nil;
    }
}

+ (void)configureCell:(UITableViewCell *)cell {
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    
    cell.backgroundColor = [UIColor sidebarCellBackgroundColor];
    cell.contentView.backgroundColor = [UIColor sidebarCellBackgroundColor];
    
    cell.tintColor = [UIColor sidebarCellTintColor];
    
    cell.textLabel.textColor = [UIColor sidebarTextColor];
    cell.textLabel.font = [UIFont defaultFontOfSize_16];
    cell.detailTextLabel.font = [UIFont defaultFontOfSize_14];
    cell.detailTextLabel.textColor = [UIColor sidebarDetailsTextColor];
    
    if ([cell respondsToSelector:@selector(titleLabel)]) {
        UILabel *label = [cell performSelector:@selector(titleLabel) withObject:nil];
        label.textColor = cell.textLabel.textColor;
        label.font = cell.textLabel.font;
    }
    if ([cell respondsToSelector:@selector(subTitleLabel)]) {
        UILabel *label = [cell performSelector:@selector(subTitleLabel) withObject:nil];
        label.textColor = cell.detailTextLabel.textColor;
        label.font = cell.detailTextLabel.font;
    }
}

@end
