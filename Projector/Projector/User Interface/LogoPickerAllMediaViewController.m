/*!
 * LogoPickerAllMediaViewController.m
 *
 *
 * Created by Skylar Schipper on 7/7/14
 */

#import "LogoPickerAllMediaViewController.h"
#import "LogoPickerAllMediaMediaTypeDisplayController.h"

@interface LogoPickerAllMediaViewController () <PCOTableViewPullToRefreshDelegate>


@end

@implementation LogoPickerAllMediaViewController

- (void)loadView {
    [super loadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:PCOMediaTypesUpdatedNotification object:nil];
    
    self.tableView.refreshDelegate = self;
    
    if (self.mediaTypes.count == 0) {
        [self.tableView beginRefreshing];
    }
}

- (void)reloadTableView {
    _mediaTypes = nil;
    [super reloadTableView];
}

- (NSArray *)mediaTypes {
    if (!_mediaTypes) {
        _mediaTypes = [[[PCOCoreDataManager sharedManager] mediaController] orderedMediaTypes];
    }
    return _mediaTypes;
}

#pragma mark -
#pragma mark - Table View
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mediaTypes.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LogoPickerMediaDisplayCellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    PCOMediaType *type = self.mediaTypes[indexPath.row];
    
    cell.textLabel.text = [type localizedDescription];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PCOMediaType *type = self.mediaTypes[indexPath.row];
    
    LogoPickerAllMediaMediaTypeDisplayController *controller = [[LogoPickerAllMediaMediaTypeDisplayController alloc] initWithNibName:nil bundle:nil];
    controller.preferredContentSize = self.preferredContentSize;
    controller.mediaType = type;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark - Refresh Delegate
- (void)tableViewShouldBeginRefresh:(PCOTableView *)tableView {
    [[[PCOCoreDataManager sharedManager] mediaController] updateMediaTypesWithCompletion:^(BOOL success) {
        [tableView endRefreshing];
    }];
}

@end
