/*!
 * PlanListBaseViewController.m
 *
 *
 * Created by Skylar Schipper on 3/17/14
 */

#import "PlanListBaseViewController.h"

@interface PlanListBaseViewController ()

@end

@implementation PlanListBaseViewController

- (BOOL)tableViewShouldBeginRefresh:(UITableView *)tableView {
    return NO;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.refreshDelegate = self;
}

@end
