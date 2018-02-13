//
//  PROSidebarTableViewController.m
//  
//
//  Created by Skylar Schipper on 4/9/14.
//
//

#import "PROSidebarTableViewController.h"
#import "PROSidebarTableHeaderView.h"

@implementation PROSidebarTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.backgroundColor = [UIColor sidebarBackgroundColor];
    self.tableView.separatorColor = [UIColor sidebarCellSeparatorColor];
    self.tableView.tintColor = [UIColor sidebarCellTintColor];
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0);
    
    if ([[self.navigationController viewControllers] firstObject] == self) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title.length == 0) {
        return 0.0;
    }
    return 40.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PROSidebarTableHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:PROSidebarTableHeaderViewIdentifier];
    if (!view) {
        view = [[PROSidebarTableHeaderView alloc] initWithReuseIdentifier:PROSidebarTableHeaderViewIdentifier];
        view.contentView.backgroundColor = [UIColor sidebarBackgroundColor];
    }
    
    view.titleLabel.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    
    return view;
}

@end
