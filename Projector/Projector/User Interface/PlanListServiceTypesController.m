/*!
 * PlanListServiceTypesController.m
 *
 *
 * Created by Skylar Schipper on 3/19/14
 */

#import "PlanListServiceTypesController.h"
#import "PCOScheduleItem.h"
#import "PCOServiceType.h"
#import "PCOServiceTypeFolder.h"
#import "PlanListPlansTableViewController.h"
#import "PROPlanContainerViewController.h"
#import "PROPlanListDetailsCell.h"
#import "PCODispatchGroup.h"
#import "PROUIOptimization.h"

static NSString * const PlanListServiceTypesControllerFolderCellIdentifier = @"PlanListServiceTypesControllerFolderCellIdentifier";
static NSString * const PlanListServiceTypesControllerServiceTypeCellIdentifier = @"PlanListServiceTypesControllerServiceTypeCellIdentifier";
static NSString * const PlanListServiceTypesControllerScheduleCellIdentifier = @"PlanListServiceTypesControllerScheduleCellIdentifier";

typedef NS_ENUM(NSInteger, PlanListTableViewSections) {
    PlanListTableViewSectionSchedule = 0,
    PlanListTableViewSectionFolders  = 1,
    PlanListTableViewSectionTypes    = 2,
    PlanListTableViewSection_Count   = 3
};

@interface PlanListServiceTypesController ()

@property (nonatomic, strong) NSArray *myScheduleItems;
@property (nonatomic, strong) NSArray *folders;
@property (nonatomic, strong) NSArray *serviceTypes;

@end

@implementation PlanListServiceTypesController

- (void)initializeDefaults {
    [super initializeDefaults];
    self.showMySchedule = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:PCOCurrentUserScheduleUpdatedNotification object:nil];
}

- (void)loadView {
    [super loadView];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    
    
    UIRefreshControl *control = [[UIRefreshControl alloc] initWithFrame:CGRectZero];
    [control addTarget:self action:@selector(pullToRefreshAction:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[PROPlanListDetailsCell class] forCellReuseIdentifier:PlanListServiceTypesControllerFolderCellIdentifier];
    [tableView registerClass:[PROPlanListDetailsCell class] forCellReuseIdentifier:PlanListServiceTypesControllerServiceTypeCellIdentifier];
    [tableView registerClass:[PROPlanListDetailsCell class] forCellReuseIdentifier:PlanListServiceTypesControllerScheduleCellIdentifier];
}

#pragma mark -
#pragma mark - Pull to refresh action
- (void)pullToRefreshAction:(UIRefreshControl *)control {
    [PCOEventLogger logEvent:@"My Schedule - Pull to refresh"];
    PCODispatchGroup *group = [PCODispatchGroup create];
    
    [group enter];
    [[[PCOCoreDataManager sharedManager] peopleController] updateMyScheduleDataCompletion:^(PCOUserData *userData) {
        [group leave];
    }];
    
    [group enter];
    [[[PCOCoreDataManager sharedManager] plansController] updateOrganizationCompletion:^(BOOL success) {
        [group leave];
    }];
    
    [group wait:^{
        [control endRefreshing];
    }];
}

#pragma mark -
#pragma mark - Lazy loaders
- (NSArray *)myScheduleItems {
    if (!_myScheduleItems) {
        _myScheduleItems = [[PCOUserData current] orderedScheduledItemsInCurrentOrganization];
    }
    return _myScheduleItems;
}
- (NSArray *)folders {
    if (!_folders) {
        if (self.parentID) {
            _folders = [[[PCOCoreDataManager sharedManager] plansController] serviceTypeFoldersWithParentId:self.parentID];
        } else {
            _folders = [[[PCOCoreDataManager sharedManager] plansController] serviceTypeFolders];
        }
    }
    return _folders;
}
- (NSArray *)serviceTypes {
    if (!_serviceTypes) {
        if (self.parentID) {
            _serviceTypes = [[[PCOCoreDataManager sharedManager] plansController] serviceTypesWithParentId:self.parentID];
        } else {
            _serviceTypes = [[[PCOCoreDataManager sharedManager] plansController] serviceTypes];
        }
    }
    return _serviceTypes;
}

#pragma mark -
#pragma mark - Table View
- (void)reloadTableView {
    _myScheduleItems = nil;
    _folders = nil;
    _serviceTypes = nil;
    [super reloadTableView];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return PlanListTableViewSection_Count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == PlanListTableViewSectionSchedule && [self shouldShowMySchedule]) {
        return self.myScheduleItems.count;
    }
    if (section == PlanListTableViewSectionFolders) {
        return self.folders.count;
    }
    if (section == PlanListTableViewSectionTypes) {
        return self.serviceTypes.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOTableViewCell *cell = nil;
    
    if (indexPath.section == PlanListTableViewSectionSchedule) {
        cell = [tableView dequeueReusableCellWithIdentifier:PlanListServiceTypesControllerScheduleCellIdentifier forIndexPath:indexPath];
        PCOScheduleItem *item = self.myScheduleItems[indexPath.row];
        cell.textLabel.text = [item shortDates];
        cell.detailTextLabel.text = item.serviceTypeName;
    }
    if (indexPath.section == PlanListTableViewSectionFolders) {
        cell = [tableView dequeueReusableCellWithIdentifier:PlanListServiceTypesControllerFolderCellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        static UIImage *image;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            image = [UIImage imageNamed:@"sidebar_folder"];
        });
        
        cell.imageView.image = image;
        
        PCOServiceTypeFolder *folder = self.folders[indexPath.row];
        cell.textLabel.text = [folder localizedDescription];
        
    }
    if (indexPath.section == PlanListTableViewSectionTypes) {
        cell = [tableView dequeueReusableCellWithIdentifier:PlanListServiceTypesControllerServiceTypeCellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        PCOServiceType *type = self.serviceTypes[indexPath.row];
        cell.textLabel.text = [type localizedDescription];
    }
    
    return (cell) ?: [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
}

#pragma mark -
#pragma mark - Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (indexPath.section == PlanListTableViewSectionFolders) {
        PCOServiceTypeFolder *folder = self.folders[indexPath.row];
        typeof(self) next = [[[self class] alloc] initWithNibName:nil bundle:nil];
        next.showMySchedule = NO;
        next.parentID = folder.remoteId;
        [self.navigationController pushViewController:next animated:YES];
        return;
    }
    if (indexPath.section == PlanListTableViewSectionSchedule) {
        PCOScheduleItem *scheduleItem = self.myScheduleItems[indexPath.row];
        PCOPlan *plan = [PCOPlan findOrCreateByPrimaryKeyValue:scheduleItem.remoteId];
        if (plan && [PROPlanContainerViewController displayPlan:plan]) {
            [[PROUIOptimization sharedOptimizer] loadingAFreshPlan];
            [[[PROAppDelegate delegate] rootViewController] hideMenuAnimated:YES completion:^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            }];
        }
        return;
    }
    if (indexPath.section == PlanListTableViewSectionTypes) {
        PCOServiceType *type = self.serviceTypes[indexPath.row];
        
        PlanListPlansTableViewController *plans = [[PlanListPlansTableViewController alloc] initWithNibName:nil bundle:nil];
        plans.serviceType = type;
        
        [self.navigationController pushViewController:plans animated:YES];
        return;
    }
}

#pragma mark -
#pragma mark - Headers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == PlanListTableViewSectionSchedule) {
        return NSLocalizedString(@"MY SCHEDULE", nil);
    }
    if (section == PlanListTableViewSectionFolders) {
        return NSLocalizedString(@"PLANS", nil);
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == PlanListTableViewSectionSchedule && [self shouldShowMySchedule]) {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
    if (section == PlanListTableViewSectionFolders) {
        return [super tableView:tableView heightForHeaderInSection:section];;
    }
    return 0.0;
}

@end
