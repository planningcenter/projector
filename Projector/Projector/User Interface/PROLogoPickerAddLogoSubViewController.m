/*!
 * PROLogoPickerAddLogoSubViewController.m
 *
 *
 * Created by Skylar Schipper on 6/30/14
 */

#import "PROLogoPickerAddLogoSubViewController.h"
#import "LogoPickerSearchBarView.h"

static NSString *const kPROLogoPickerAddLogoHeaderFooterIdentifier = @"kPROLogoPickerAddLogoHeaderFooterIdentifier";

@interface PROLogoPickerAddLogoSubViewController ()

@property (nonatomic, weak) LogoPickerSearchBarView *searchBarView;

@end

@implementation PROLogoPickerAddLogoSubViewController

- (void)loadView {
    [super loadView];
    [self.tableView registerClass:[LogoPickerMediaDisplayCell class] forCellReuseIdentifier:LogoPickerMediaDisplayCellIdentifier];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kPROLogoPickerAddLogoHeaderFooterIdentifier];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor mediaSelectedCellBackgroundColor];
    [self addBackButtonWithString:NSLocalizedString(@"Back", nil)];
}

- (BOOL)showSearchBar {
    return NO;
}

- (void)updateSearchString:(NSString *)searchString final:(BOOL)final {
    NSLog(@"%i - %@",final,searchString);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadTableView];
}

- (void)setPlan:(PCOPlan *)plan {
    _plan = plan;
    [self reloadTableView];
}

#pragma mark -
#pragma mark - Search
- (LogoPickerSearchBarView *)searchBarView {
    if (!_searchBarView) {
        LogoPickerSearchBarView *view = [LogoPickerSearchBarView newAutoLayoutView];
        view.backgroundColor = [UIColor mediaSelectedCellBackgroundColor];
        
        welf();
        view.searchUpdateHandler = ^(NSString *s, BOOL f) {
            [welf updateSearchString:s final:f];
        };
        
        _searchBarView = view;
        [self.view addSubview:view];
        
        CGFloat height = 44.0;
        if (![self showSearchBar]) {
            height = 0.0;
        }
        
        [self.view addConstraint:[NSLayoutConstraint height:height forView:view]];
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeTop | UIRectEdgeRight]];
    }
    return _searchBarView;
}

#pragma mark -
#pragma mark - Helpers
- (void)installConstraintsForTableView:(UITableView *)tableView onView:(UIView *)view {
    [view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:tableView offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.searchBarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}

#pragma mark -
#pragma mark - Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kPROLogoPickerAddLogoHeaderFooterIdentifier];
    view.contentView.backgroundColor = [UIColor sidebarCellBackgroundColor];
    view.textLabel.textColor = [UIColor logoPickerStrokeColor];
    view.textLabel.font = [UIFont defaultFontOfSize_14];
    
    return view;
}

@end

_PCO_EXTERN_STRING LogoPickerMediaDisplayCellIdentifier = @"LogoPickerMediaDisplayCellIdentifier";
