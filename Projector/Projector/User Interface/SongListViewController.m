//
//  SongListViewController.m
//  Projector
//
//  Created by Peter Fokos on 11/14/14.
//

#import "SongListViewController.h"
#import "PCOTableViewCell.h"
#import "CapitalizedTableviewHeaderView.h"
#import "LogoPickerSearchBarView.h"
#import "ArrangementPickerViewController.h"
#import "KeyPickerViewController.h"
#import "PlanEditingController.h"
#import "CommonNavButton.h"

@interface SongListViewController () {
}

@property (nonatomic, assign) LogoPickerSearchBarView *searchBar;
@property (nonatomic, weak) PCOSong *currentlySelectedSong;
@property (nonatomic, strong) NSArray *viewContraints;
@property (nonatomic, strong) NSArray *linkedViewContraints;
@property (nonatomic, weak) UIView *linkedView;
@property (nonatomic, weak) UIView *seperatorView;
@property (nonatomic, weak) PCOLabel *linkLabel;
@property (nonatomic, weak) PCOButton *unlinkButton;

@end

@implementation SongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Choose Song", nil);
    self.view.backgroundColor = [UIColor sequenceTableViewSeparatorColor];
    
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Edit", nil)
                                                                                                                color:[UIColor sequenceTableViewBorderColor]
                                                                                                               action:@selector(cancelButtonAction:)
                                                                                                            backArrow:YES]];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;

    if ([[[PCOCoreDataManager sharedManager] songsController] shouldUpdateSongsList]) {
        [self updateSongsList];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songListUpdated:) name:PCOSongsUpdatedNotification object:nil];
    [self.view updateConstraintsIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout
#pragma mark -

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (self.viewContraints) {
        [self.view removeConstraints:self.viewContraints];
    }
    if (self.linkedViewContraints) {
        [self.linkedView removeConstraints:self.linkedViewContraints];
    }
    
    CGFloat linkedViewHeight = 0;
    if (_currentlySelectedSong) {
        linkedViewHeight = 60;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{@"linked_view_height": @(linkedViewHeight)};
    
    NSDictionary *views = @{
                            @"table": self.tableView,
                            @"linked_view": self.linkedView,
                            @"search_view": self.searchBar,
                            @"seperator": self.seperatorView,
                            @"link_label": self.linkLabel,
                            @"unlink_button": self.unlinkButton,
                            };
    
    for (NSString *format in @[
                               @"H:|[table]|",
                               @"H:|[linked_view]|",
                               @"H:|[search_view]|",
                               @"V:|-1-[search_view(==50)][linked_view(==linked_view_height)]-1-[table]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    
    [self.view addConstraints:array];
    self.viewContraints = [NSArray arrayWithArray:array];
    [self.view updateConstraintsIfNeeded];
    
    [array removeAllObjects];
    
    for (NSString *format in @[
                               @"H:|[seperator]|",
                               @"V:|[seperator(==1)]",
                               
                               @"H:|-15-[link_label]-9-[unlink_button(==120)]-15-|",
                               @"V:|[link_label]|",
                               @"V:[unlink_button(==30)]",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }

    [array addObject:[NSLayoutConstraint pco_centerVertical:self.unlinkButton inView:self.linkedView]];
    
    [self.linkedView addConstraints:array];
    self.linkedViewContraints = [NSArray arrayWithArray:array];
    [self.linkedView updateConstraintsIfNeeded];
}
#pragma mark -
#pragma mark - Helper Methods

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector backArrow:(BOOL)backArrow {
    CGRect frame = [CommonNavButton frameWithText:text backArrow:backArrow];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    if (backArrow) {
        [button showBackArrow];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)updateSongsList {
    [[[PCOCoreDataManager sharedManager] songsController] updateSongs];
}

- (void)songListUpdated:(NSNotification *)notif
{
    
    _fetchController = nil;
    
    if (self.selectedItem.songId) {
        self.currentlySelectedSong = [[[PCOCoreDataManager sharedManager] songsController] songWithId:self.selectedItem.songId];
    } else {
        self.currentlySelectedSong = nil;
    }
    
    [self.tableView reloadData];
    
    [[PCOCoreDataManager sharedManager] save:NULL];
    
}

- (void)refreshSearchResults {
    _fetchController = nil;
    [self.tableView reloadData];
}

- (void)presentArrangementForSong:(PCOSong *)song {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PCOSongUpdated object:nil];
    [[[PCOCoreDataManager sharedManager] songsController] updateSong:song];
    
    NSArray *arrangements = [song orderedArrangements];
    
    if ([arrangements count] > 0) {
        [self.selectedItem setSelectedSong:song];
        if ([arrangements count] == 1) {
            PCOArrangement *arr = [arrangements objectAtIndex:0];
            [self.selectedItem setSelectedArrangement:arr];
            
            if ([[arr orderedKeys] count] > 1) {
                KeyPickerViewController *picker = [[KeyPickerViewController alloc] initWithNibName:nil bundle:nil];
                picker.selectedItem = self.selectedItem;
                [self.navigationController pushViewController:picker animated:YES];
                
            } else {
                if ([[arr orderedKeys] count] > 0) {
                    PCOKey *key = [[arr orderedKeys] objectAtIndex:0];
                    [self.selectedItem setSelectedKey:key];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            ArrangementPickerViewController *songDetails = [[ArrangementPickerViewController alloc] initWithNibName:nil bundle:nil];
            songDetails.selectedItem = self.selectedItem;
            songDetails.song = song;
            [self.navigationController pushViewController:songDetails animated:YES];
        }
    }
}

#pragma mark - TableView data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[[self fetchController] sections] objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self fetchController] sectionIndexTitles];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCOTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = HEX(0x25252a);
    cell.textLabel.font = [UIFont defaultFontOfSize_14];
    cell.textLabel.textColor = HEX(0xc8cee0);
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor blackColor];
    cell.selectedBackgroundView = selectedView;
    
    PCOSong *song = nil;
    song = [[[[[self fetchController] sections] objectAtIndex:indexPath.section] objects] objectAtIndex:indexPath.row];
    
    
    cell.textLabel.text = song.name;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[[self fetchController] sections] objectAtIndex:section] numberOfObjects];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchController] sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView numberOfSections] == 1) {
        return 0;
    }
    return [CapitalizedTableviewHeaderView heightForView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CapitalizedTableviewHeaderView *view = [[CapitalizedTableviewHeaderView alloc] init];
    [view capitalizedTitle:[self tableView:tableView titleForHeaderInSection:section]];
    return view;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOSong *song = [[[[[self fetchController] sections] objectAtIndex:indexPath.section] objects] objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [[[PCOCoreDataManager sharedManager] songsController] updateSong:song completion:^(PCOSong * song) {
        [self presentArrangementForSong:song];
    }];
}

#pragma mark -
#pragma mark - Fetch Controller
- (NSFetchedResultsController *)fetchController
{
    if (_fetchController) return _fetchController;
    
    NSAssert([[NSThread currentThread] isMainThread], @"-fetchController may only be called on main thread");
    
    NSFetchRequest * request = [PCOSong fetchRequest];
    [request setFetchBatchSize:25];
    
    if ([self.searchString length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchString];
        [request setPredicate:predicate];
    }
    
    NSSortDescriptor * nameSort = [[NSSortDescriptor alloc] initWithKey:@"sortName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:nameSort]];
    
    _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[PCOCoreDataManager sharedManager] managedObjectContext] sectionNameKeyPath:@"sortIndexKey" cacheName:nil];
    _fetchController.delegate = self;
    
    
    NSError * fetchErr = nil;
    
    if (![_fetchController performFetch:&fetchErr]) {
        PCOLogError(@"error fetching songs: %@", fetchErr);
    }
    
    return _fetchController;
}

#pragma mark -
#pragma mark - Lazy Loaders

- (PCOTableView *)tableView {
    if (!_tableView) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor sequenceTableCellBackgroundColor];
        table.separatorColor = [UIColor sequenceTableViewSeparatorColor];
        table.sectionIndexBackgroundColor = [UIColor clearColor];
        table.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        table.sectionIndexColor = HEX(0xc8cee0);
        _tableView = table;
        [table registerClass:[PCOTableViewCell class] forCellReuseIdentifier:@"PCOTableViewCell"];
        
        [self.view addSubview:table];
    }
    return _tableView;
}

- (LogoPickerSearchBarView *)searchBar {
    if (!_searchBar) {
        LogoPickerSearchBarView *view = [LogoPickerSearchBarView newAutoLayoutView];
        view.backgroundColor = HEX(0x2c2c31);
        
        welf();
        view.searchUpdateHandler = ^(NSString *s, BOOL f) {
            welf.searchString = s;
            [welf refreshSearchResults];
        };
        
        _searchBar = view;
        [self.view addSubview:view];
    }
    return _searchBar;
}

- (UIView *)linkedView {
    if (!_linkedView) {
        UIView *view = [UIView newAutoLayoutView];
        view.clipsToBounds = YES;
        view.backgroundColor = HEX(0x25252a);
        [self.view addSubview:view];
        _linkedView = view;
    }
    return _linkedView;
}

- (UIView *)seperatorView {
    if (!_seperatorView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor projectorOrangeColor];
        [self.linkedView addSubview:view];
        _seperatorView = view;
    }
    return _seperatorView;
}

- (PCOLabel *)linkLabel {
    if (!_linkLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = HEX(0xdedfe4);
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor clearColor];
        [self.linkedView addSubview:label];
        _linkLabel = label;
    }
    return _linkLabel;
}

- (PCOButton *)unlinkButton {
    if (!_unlinkButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view addTarget:self action:@selector(unlinkSongAction:) forControlEvents:UIControlEventTouchUpInside];
        [view setBackgroundColor:HEX(0xdf4343) forState:UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"unlink-icon"] forState:UIControlStateNormal];
        [view setTitle:NSLocalizedString(@"Unlink", nil) forState:UIControlStateNormal];
        view.titleLabel.font = [UIFont defaultFontOfSize_14];
        view.titleLabel.textColor = HEX(0xdedfe4);
        view.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
        view.layer.cornerRadius = 3.0;
        _unlinkButton = view;
        [self.linkedView addSubview:view];
    }
    return _unlinkButton;
}

#pragma mark -
#pragma mark - Setters

- (void)setSelectedItem:(PCOItem *)selectedItem {
    _selectedItem = selectedItem;
    self.currentlySelectedSong = selectedItem.song;
}

- (void)setCurrentlySelectedSong:(PCOSong *)currentlySelectedSong {
    _currentlySelectedSong = currentlySelectedSong;
    self.linkLabel.text = @"";
    if (currentlySelectedSong) {
        self.linkLabel.text = currentlySelectedSong.name;
    }
}

#pragma mark -
#pragma mark - Action Methods

- (void)unlinkSongAction:(id)sender {
    [[PlanEditingController sharedController] unlinkSongFromItem:self.selectedItem inPlan:self.plan];
    self.currentlySelectedSong = nil;
    [self.tableView reloadData];
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)cancelButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
