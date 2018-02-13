/*!
 * LayoutPickerTableViewController.m
 *
 *
 * Created by Skylar Schipper on 5/13/14
 */

#import "LayoutPickerTableViewController.h"
#import "PlanOutputViewController.h"
#import "LayoutTableViewHeaderView.h"
#import "LayoutPickerSlidingTableViewCell.h"

#import "LayoutEditorInterfaceContainerController.h"
#import "LayoutEditorMobileContainerController.h"

#import "PCOServiceType.h"
#import "PCOSlideLayout.h"

#import "PROFeatureFlags.h"

#import "PROSlideManager.h"

#import "PROAddBarButtonItem.h"

typedef NS_ENUM(NSInteger, LayoutPickerTableViewSection) {
    LayoutPickerTableViewSectionCustomLayouts  = 0,
    LayoutPickerTableViewSectionDefaultLayouts = 1,
    LayoutPickerTableViewSection_Count         = 2
};

static NSString *const LayoutPickerSlidingTableViewCellIdentifier = @"LayoutPickerSlidingTableViewCellIdentifier";


@interface LayoutPickerTableViewController () <PCOTableViewPullToRefreshDelegate, LayoutPickerSlidingTableViewCellDelegate>


@end


@implementation LayoutPickerTableViewController

- (void)loadView {
    [super loadView];
    
    self.tableView.backgroundColor = [UIColor projectorBlackColor];
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.refreshDelegate = self;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
    
    self.title = NSLocalizedString(@"Layouts", nil);
    
    if (!self.serviceType.attachmentTypesEnabled) { // Need a way to determine if service type has been updated from network.  attachmentTypesEnabled will be nil if it hasn't been
        [[[PCOCoreDataManager sharedManager] plansController] updateServiceType:self.serviceType completion:^(BOOL success) {
            if (success) {
                [self.tableView beginRefreshing];
            }
        }];
    }
    
    if ([[PCOUserData current] hasPermissionLevel:PCOPermissionLevelEditor]) {
        self.navigationItem.rightBarButtonItem = [[PROAddBarButtonItem alloc] initWithTarget:self action:@selector(addLayoutButtonAction:)];
    }
    
    if ([[PROAppDelegate delegate] isPad]  && !self.navigationController.popoverPresentationController) {
        self.navigationController.view.layer.borderColor = [[UIColor sessionsHeaderTextColor] CGColor];
        self.navigationController.view.layer.borderWidth = 1.0;
        self.navigationController.view.layer.cornerRadius = 6.0;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutsUpdatedNotification:) name:PCOLayoutsUpdatedForServiceTypeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[[PCOCoreDataManager sharedManager] layoutsController] createDefaultLayoutsIfNeededInContext:[[PCOCoreDataManager sharedManager] managedObjectContext]];
    
    self.navigationController.navigationBar.barTintColor = HEX(0x1f1f23);
    self.navigationController.popoverPresentationController.backgroundColor = HEX(0x1f1f23);
    
    [self reloadTableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    for (LayoutPickerSlidingTableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell respondsToSelector:@selector(prepareForDismiss)]) {
            [cell prepareForDismiss];
        }
    }
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[LayoutPickerSlidingTableViewCell class] forCellReuseIdentifier:LayoutPickerSlidingTableViewCellIdentifier];
}

- (void)reloadTableView {
    _defaultLayouts = nil;
    _customLayouts = nil;
    [super reloadTableView];
}

- (void)tableViewShouldBeginRefresh:(PCOTableView *)tableView {
    [[[PCOCoreDataManager sharedManager] layoutsController] getLayoutsForServiceTypeID:self.serviceType.remoteId completion:^(NSError *error) {
        [tableView endRefreshing];
    }];
}

- (void)addLayoutButtonAction:(id)sender {
    PCOSlideLayout *layout = [PCOSlideLayout object];
    
    layout.name = NSLocalizedString(@"New Custom Layout", nil);
    layout.allowsEditing = @YES;
    layout.layoutDescription = [NSString stringWithFormat:NSLocalizedString(@"A new custom layout for %@", nil),[self.serviceType localizedDescription]];
    layout.serviceTypeId = self.serviceType.remoteId;
    layout.backgroundColor = [UIColor blackColor];
    layout.layoutId = @(NSIntegerMax);
    
    layout.lyricTextLayout = [PCOSlideTextLayout object];
    layout.lyricTextLayout.fontSize = @55.0;
    
    layout.songInfoLayout = [PCOSlideTextLayout object];
    layout.songInfoLayout.fontSize = @14;
    layout.songInfoLayout.verticalAlignment = kPCOSlideTextVerticalAlignmentBottom;
    layout.songInfoLayout.textAlignment = kPCOSlideTextAlignmentLeft;
    layout.songInfoLayout.showOnAllSlides = @NO;
    layout.songInfoLayout.showOnlyOnLastSlide = @YES;
    
    layout.titleTextLayout = [PCOSlideTextLayout object];
    layout.titleTextLayout.showOnAllSlides = @NO;
    
    NSError *error = nil;
    if (![[PCOCoreDataManager sharedManager] save:&error]) {
        PCOError(error);
    }
    
    [self presentLayoutEditorForLayout:layout];
}

- (void)doneButtonAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Layouts Updated
- (void)layoutsUpdatedNotification:(NSNotification *)notif {
    [self reloadTableView];
}

#pragma mark -
#pragma mark - Data Loaders
- (NSArray *)defaultLayouts {
    if (!_defaultLayouts) {
        _defaultLayouts = [[[PCOCoreDataManager sharedManager] layoutsController] defaultLayouts];
    }
    return _defaultLayouts;
}
- (NSArray *)customLayouts {
    if (!_customLayouts) {
        _customLayouts = [[[[PCOCoreDataManager sharedManager] layoutsController] orderedLayoutsForServiceTypeID:self.serviceType.remoteId]  sortedArrayUsingComparator:^NSComparisonResult(PCOSlideLayout *obj1, PCOSlideLayout *obj2) {
            if (obj1.name.length > 0 && obj2.name.length > 0) {
                return [obj1.name caseInsensitiveCompare:obj2.name];
            }
            return NSOrderedSame;
        }];
    }
    return _customLayouts;
}

- (PCOSlideLayout *)layoutForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LayoutPickerTableViewSectionCustomLayouts) {
        return self.customLayouts[indexPath.row];
    }
    if (indexPath.section == LayoutPickerTableViewSectionDefaultLayouts) {
        return self.defaultLayouts[indexPath.row];
    }
    return nil;
}

#pragma mark -
#pragma mark - Actions
- (void)dismissButtonAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Table View Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return LayoutPickerTableViewSection_Count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == LayoutPickerTableViewSectionCustomLayouts) {
        return self.customLayouts.count;
    }
    if (section == LayoutPickerTableViewSectionDefaultLayouts) {
        return self.defaultLayouts.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LayoutPickerSlidingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LayoutPickerSlidingTableViewCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    cell.enabled = (indexPath.section == LayoutPickerTableViewSectionCustomLayouts);
    
    PCOSlideLayout *layout = [self layoutForIndexPath:indexPath];
    cell.titleLabel.text = [layout localizedDescription];
    cell.layout = layout;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59.0;
}

#pragma mark -
#pragma mark - Table View Section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == LayoutPickerTableViewSectionCustomLayouts && [self.serviceType localizedDescription]) {
        return [NSString stringWithFormat:NSLocalizedString(@"Layouts for %@", nil),[self.serviceType localizedDescription]];
    }
    if (section == LayoutPickerTableViewSectionDefaultLayouts) {
        return NSLocalizedString(@"Default Layouts", nil);
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LayoutTableViewHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeaderView"];
    if (!view) {
        view = [[LayoutTableViewHeaderView alloc] initWithReuseIdentifier:@"HeaderView"];
    }
    return view;
}

#pragma mark -
#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LayoutPickerSlidingTableViewCell *cell = (LayoutPickerSlidingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[LayoutPickerSlidingTableViewCell class]]) {
        if ([cell isOpened]) {
            [cell hideButtonsAnimated:YES completion:nil];
        } else {
            [cell showButtonsAnimated:YES completion:nil];
            [self slidingDidBegin:cell];
        }
    }
}

- (void)presentLayoutEditorForLayout:(PCOSlideLayout *)layout {
    if (!layout) {
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LayoutEditorStoryboard" bundle:[NSBundle mainBundle]];
    if ([[PROAppDelegate delegate] isPad]) {
        LayoutEditorInterfaceContainerController *controller = [storyboard instantiateInitialViewController];
        controller.layout = layout;
        
        UIViewController *presenting = self.presentingViewController;
        
        if ([presenting respondsToSelector:@selector(contentViewController)]) {
            UIViewController *content = [presenting performSelector:@selector(contentViewController) withObject:nil];
            if ([content isKindOfClass:[UINavigationController class]]) {
                UIViewController *top = [content performSelector:@selector(topViewController) withObject:nil];
                if ([top isKindOfClass:[PROPlanContainerViewController class]]) {
                    PROPlanContainerViewController *container = (PROPlanContainerViewController *)top;
                    container.showLayoutPickerOnPresent = YES;
                }
            }
        }
        
        [presenting dismissViewControllerAnimated:YES completion:^{
            [presenting presentViewController:controller animated:YES completion:nil];
        }];
    }
    else {
        LayoutEditorMobileContainerController *controller = [storyboard instantiateViewControllerWithIdentifier:@"mobile"];
        controller.layout = layout;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark -
#pragma mark - Slide Delete
- (void)editLayoutButtonAction:(LayoutPickerSlidingTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    PCOSlideLayout *layout = [self layoutForIndexPath:indexPath];
    if (indexPath.section == LayoutPickerTableViewSectionCustomLayouts) {
        [PCOEventLogger logEvent:@"Layout Picker - Edit Layout"];
        [self presentLayoutEditorForLayout:layout];
    }
    if (indexPath.section == LayoutPickerTableViewSectionDefaultLayouts) {
        [PCOEventLogger logEvent:@"Layout Picker - Copy and Edit Layout"];
        PCOSlideLayout *copyLayout = [layout copyLayoutIntoContext:layout.managedObjectContext];
        copyLayout.remoteId = nil;
        copyLayout.serviceTypeId = self.serviceType.remoteId;
        [self presentLayoutEditorForLayout:copyLayout];
    }
}
- (void)deleteLayoutButtonAction:(LayoutPickerSlidingTableViewCell *)cell {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath.section == LayoutPickerTableViewSectionCustomLayouts) {
        MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Layout", nil) message:NSLocalizedString(@"Do you want to delete this layout? Any item using it, even in other plans, will revert to the default 4-line layout.", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil)];
        
        [alert addActionWithTitle:NSLocalizedString(@"Delete", nil) handler:^(MCTAlertViewAction *action) {
            [PCOEventLogger logEvent:@"Layout Picker - Delete Layout"];
            PCOSlideLayout *layout = [self layoutForIndexPath:indexPath];
            
            [layout deleteEntity];
            
            if (![layout isNew]) {
                [[[PCOCoreDataManager sharedManager] layoutsController] deleteLayout:layout completion:^(NSError *error) {
                    if (error) {
                        [self.tableView beginRefreshing];
                        PCOError(error);
                        [MCTAlertView showError:error];
                        return;
                    }
                    
                    for (PCOItem *item in [[[[PROSlideManager sharedManager] plan] items] allObjects]) {
                        if ([item.selectedSlideLayoutId isEqualToNumber:layout.remoteId]) {
                            item.selectedSlideLayout = [[[PCOCoreDataManager sharedManager] layoutsController] defaultLayout];
                            item.selectedSlideLayoutId = item.selectedSlideLayout.remoteId;
                            [[PROSlideManager sharedManager] emptyCacheOfItem:item];
                        }
                    }
                
                    [[PCOCoreDataManager sharedManager] save:NULL];
                }];
            }
            
            [self reloadTableView];
        }];
        
        [alert show];
    }
}
- (void)applyLayoutButtonAction:(LayoutPickerSlidingTableViewCell *)cell {
    MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Change Layout", nil) message:NSLocalizedString(@"Apply this layout to all slides in this plan?", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil)];
    
    [alert addActionWithTitle:NSLocalizedString(@"Apply", nil) handler:^(MCTAlertViewAction *action) {
        [PCOEventLogger logEvent:@"Layout Picker - Apply Layout to all slides"];
        [self applyLayoutForCell:cell];
    }];
    
    [alert show];
}
- (void)applyLayoutForCell:(LayoutPickerSlidingTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    
    PCOSlideLayout *layout = [self layoutForIndexPath:indexPath];
    if (!layout) {
        return;
    }
    
    for (PCOItem *item in [[[[PROSlideManager sharedManager] plan] items] allObjects]) {
        item.selectedSlideLayoutId = layout.remoteId;
        item.selectedSlideLayout = layout;
    }
    
    [[[PCOCoreDataManager sharedManager] itemsController] saveSelectedLayout:layout.remoteId planID:[[[PROSlideManager sharedManager] plan] remoteId] completion:^(NSError *error) {
        PCOError(error);
        if (error) {
            [MCTAlertView showError:error];
        }
    }];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [[PROSlideManager sharedManager] emptyCache];
        [PCOEventLogger logEvent:@"Changed Global Layout"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LayoutPickerDidPickNewLayoutNotification object:nil];
    }];
}

- (void)slidingDidBegin:(LayoutPickerSlidingTableViewCell *)cell {
    for (LayoutPickerSlidingTableViewCell *visible in [self.tableView visibleCells]) {
        if (visible != cell) {
            if ([visible isOpened]) {
                [visible hideButtonsAnimated:YES completion:nil];
            }
        }
    }
}

@end

_PCO_EXTERN_STRING LayoutPickerDidPickNewLayoutNotification = @"LayoutPickerDidPickNewLayoutNotification";
