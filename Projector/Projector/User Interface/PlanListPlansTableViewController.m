/*!
 * PlanListPlansTableViewController.m
 *
 *
 * Created by Skylar Schipper on 3/19/14
 */

#import "PlanListPlansTableViewController.h"
#import "PCOServiceType.h"
#import "PROPlanContainerViewController.h"
#import "PROPlanListDetailsCell.h"
#import "PROUIOptimization.h"

static NSString * const PlanListServiceTypesControllerScheduleCellIdentifier = @"PlanListServiceTypesControllerScheduleCellIdentifier";

@interface PlanListPlansTableViewController ()

@property (nonatomic, strong) NSArray *plans;

@end

@implementation PlanListPlansTableViewController

- (void)loadView {
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceTypePlansUpdated:) name:PCOServiceTypePlansUpdated object:nil];
    
    [self beginRefreshingTableViewAnimated:NO];
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[PROPlanListDetailsCell class] forCellReuseIdentifier:PlanListServiceTypesControllerScheduleCellIdentifier];
}

#pragma mark -
#pragma mark - Notifs
- (void)serviceTypePlansUpdated:(NSNotification *)notif {
    [self endRefreshingTableViewAnimated:YES];
}

- (void)reloadTableView {
    _plans = nil;
    [super reloadTableView];
}

- (NSArray *)plans {
    if (!_plans) {
        _plans = [[[PCOCoreDataManager sharedManager] plansController] plansForServiceTypeWithId:self.serviceType.remoteId];
    }
    return _plans;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.plans.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlanListServiceTypesControllerScheduleCellIdentifier forIndexPath:indexPath];
    
    PCOPlan *plan = self.plans[indexPath.row];
    
    cell.textLabel.text = plan.dates;
    cell.detailTextLabel.text = plan.planTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PCOPlan *plan = self.plans[indexPath.row];
    if (plan) {
        [[PROUIOptimization sharedOptimizer] loadingAFreshPlan];
        if ([PROPlanContainerViewController displayPlan:plan]) {
            [[[PROAppDelegate delegate] rootViewController] hideMenuAnimated:YES completion:^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            }];
        }
    }
}

#pragma mark -
#pragma mark - Pull to refresh delegate
- (BOOL)tableViewShouldBeginRefresh:(UITableView *)tableView {
    if (![PCOServer networkReachable]) {
        return NO;
    }
    if (_serviceType) {
        [[[PCOCoreDataManager sharedManager] plansController] loadPlansForServiceType:_serviceType];
        return YES;
    }
    return NO;
}


@end
