/*!
 * PlanViewMobileGridTableViewController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/2/14
 */

#import "PlanViewMobileGridTableViewController.h"
#import "PROSlideManager.h"
#import "PlanViewMobileGridTableViewCell.h"
#import "PlanViewGridSectionHeaderItemHeader.h"
#import "PlanItemSettingsViewController.h"
#import "PRONavigationController.h"
#import "PlanItemEditingController.h"
#import "EditArrangementSequenceViewController.h"
#import "CustomSlidesListViewController.h"
#import "PlanViewMobileGridViewCollectionViewCell.h"
#import "PROPlanContainerViewController.h"
#import "LoopingPlaylistManager.h"
#import "ProjectorMusicPlayer.h"
#import "PROLogoDisplayItem.h"
#import "PROUIOptimization.h"
#import "ProjectorP2P_SessionManager.h"

#define PULL_TO_REFRESH_DRAG_PERCENT    0.25
#define PULL_TO_REFRESH_DRAG_POINTS     80
#define PULL_TO_REFRESH_REVEAL_PERCENT  0.10

static NSString *const kPlanViewGridSectionHeaderMobileIdentifier = @"kPlanViewGridSectionHeaderMobileIdentifier";
static NSString *const kPlanViewGridSectionHeaderMobileItemHeaderIdentifier = @"kPlanViewGridSectionHeaderMobileItemHeaderIdentifier";

@interface PlanViewMobileGridTableViewController () <PlanViewMobileGridTableViewCellDelegate, ProjectorP2P_SessionManagerDelegate> {

}

@property (nonatomic, strong, readwrite) PlanGridHelper *helper;
@property (nonatomic, strong) NSHashTable *sectionHeaderViews;
@property (nonatomic, strong) NSLayoutConstraint *tableYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *tableHeightConstraint;
@property (nonatomic, strong) NSArray *lowMemoryConstraints;

@property (nonatomic, weak) UIView *activityView;
@property (nonatomic, weak) UIImageView *activityIndicator;

@property (nonatomic) BOOL lowMemoryWarning;
@property (nonatomic) BOOL planRefreshing;

@end

@implementation PlanViewMobileGridTableViewController

-(void)gridSizeSettingDidChange {
    if (self.lowMemoryWarning) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.helper.currentIndexPath) {
            [self adjustTableHeight];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToIndexPath:self.helper.currentIndexPath animated:NO];
            });
        }
        else {
            [self adjustTableHeight];
        }
    });
}

- (void)loadView {
    [super loadView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlanItemLooping_StateChanged_Notification:) name:PlanItemLooping_StateChanged_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlanItemLooping_PlaylistChanged_Notification:) name:PlanItemLooping_PlaylistChanged_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlanItemLooping_TimeForNextSlide_Notification:) name:PlanItemLooping_TimeForNextSlide_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTableViewReload) name:kProjectorGrideSizeSetting object:nil];
    [[PCOLiveController sharedController] addDelegate:self];
    [[ProjectorP2P_SessionManager sharedManager] addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // need to reload the entire table but not display the entire grid
    self.lowMemoryWarning = YES;
    [self startTableViewReload];
}

- (void)pro_setContainer:(PROPlanContainerViewController *)container {
    _container = container;
}

// MARK: - Setup
- (void)finishTableViewSetup:(PCOTableView *)tableView {
    tableView.backgroundColor = [UIColor mobileGridViewBackgroundColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 56.0)];
}
- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[PlanViewMobileGridTableViewCell class] forCellReuseIdentifier:PlanViewMobileGridTableViewCellIdentifier];
    
    [tableView registerClass:[PlanViewGridSectionHeaderMobileItemHeader class] forHeaderFooterViewReuseIdentifier:kPlanViewGridSectionHeaderMobileItemHeaderIdentifier];
    [tableView registerClass:[PlanViewGridSectionMobileHeader class] forHeaderFooterViewReuseIdentifier:kPlanViewGridSectionHeaderMobileIdentifier];
}

// MARK: - Helper
- (PlanGridHelper *)helper {
    if (!_helper) {
        _helper = [[PlanGridHelper alloc] init];
        _helper.delegate = self;
    }
    return _helper;
}
- (NSHashTable *)sectionHeaderViews {
    if (!_sectionHeaderViews) {
        _sectionHeaderViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _sectionHeaderViews;
}

- (void)installConstraintsForTableView:(UITableView *)tableView onView:(UIView *)view {
    if (self.lowMemoryWarning) {
        [super installConstraintsForTableView:tableView onView:view];
        return;
    }
    [view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:tableView offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
    self.tableHeightConstraint = [NSLayoutConstraint height:tableView.contentSize.height forView:tableView];
    self.tableYConstraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.tableView.superview
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:-self.tableView.contentSize.height];
    [view addConstraints:@[self.tableHeightConstraint, self.tableYConstraint]];
}

- (void)adjustTableHeight {
//    NSLog(@"View Frame: %@", NSStringFromCGRect(self.view.frame));
//    NSLog(@"TableView Frame: %@", NSStringFromCGRect(self.tableView.frame));
//    NSLog(@"TableView ContentSize: %@", NSStringFromCGSize(self.tableView.contentSize));
//    NSLog(@"TableView Content Insets: %@", NSStringFromUIEdgeInsets(self.tableView.contentInset));

    if (_tableHeightConstraint && _tableYConstraint) {
        [self.tableView.superview removeConstraints:@[self.tableHeightConstraint, self.tableYConstraint]];
        _tableHeightConstraint = nil;
        _tableYConstraint = nil;
    }

    if (_lowMemoryConstraints) {
        [self.tableView.superview removeConstraints:self.lowMemoryConstraints];
        _lowMemoryConstraints = nil;
    }

    if (self.lowMemoryWarning) {
        self.lowMemoryConstraints = [NSLayoutConstraint offsetViewEdgesInSuperview:self.tableView offset:0.0 edges:UIRectEdgeAll];
        [self.tableView.superview addConstraints:self.lowMemoryConstraints];
    }
    else {
        
        self.tableHeightConstraint = [NSLayoutConstraint height:(self.tableView.contentSize.height *2) forView:self.tableView];
        
        self.tableYConstraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.tableView.superview
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:-self.tableView.contentSize.height];
        
        [self.tableView.superview addConstraints:@[self.tableHeightConstraint, self.tableYConstraint]];
        UIEdgeInsets insets = UIEdgeInsetsMake(self.tableView.contentSize.height, 0, self.tableView.contentSize.height - self.view.frame.size.height, 0);
        self.tableView.contentInset = insets;
        CGPoint startPoint = CGPointMake(0, -self.tableView.contentSize.height);

        if (!self.helper.currentIndexPath && CGPointEqualToPoint(self.tableView.contentOffset, CGPointZero)) {
            self.tableView.contentOffset = startPoint;
        }
        
        if (self.tableView.contentOffset.y < startPoint.y) {
            self.tableView.contentOffset = startPoint;
        }

    }
}

// MARK: - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [self.helper numberOfItems];
    if ([self.helper isLiveCurrentlyEnabled]) {
        count += PlanGridHelperLiveSectionCount;
    }
    return count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if ([self.helper isLiveIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]]) {
        count = PlanGridHelperLiveSectionCount;
    }
    else if ([self.helper numberOfItemsInSection:section] > 0) {
        count = 1;
    }
    [[PROUIOptimization sharedOptimizer] setNumberOfRows:count inSection:section];
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[PROUIOptimization sharedOptimizer] isLastSection:indexPath.section]) {
        if ([[PROUIOptimization sharedOptimizer] isFullUIReloading]) {
            [[PROUIOptimization sharedOptimizer] finishedFullUIReload];
            if ([[PROUIOptimization sharedOptimizer] wasFreshPlan]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *topOfGrid = [self.helper firstValidIndexPathForPlan];
                    [self scrollToIndexPath:topOfGrid animated:NO];
                    if (!self.lowMemoryWarning ) {
                        [self.activityView setHidden:YES];
                    }
                });
            }
            else {
                if (!self.lowMemoryWarning ) {
                    [self.activityView setHidden:YES];
                }
            }
        }
    }
    
    PlanViewMobileGridTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlanViewMobileGridTableViewCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([[ProjectorSettings userSettings] gridSize]) {
        case ProjectorGridSizeNormal:
            return 100.0;
            break;
        case ProjectorGridSizeLarge:
            return 150.0;
            break;
        case ProjectorGridSizeSmall:
            return 80.0;
            break;
        default:
            break;
    }
    return 100.0;
}

- (void)startTableViewReload {
    if ([[PROUIOptimization sharedOptimizer] shouldGridReload] && [self numberOfSectionsInTableView:self.tableView] > 0) {
        [[PROUIOptimization sharedOptimizer] startedFullUIReload];
        if (!self.lowMemoryWarning && self.helper.plan) {
            [self.view bringSubviewToFront:self.activityView];
            [self startActivityIndicatorAnimation];
            [self.activityView setHidden:NO];
            [self.activityView setAlpha:1.0];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadTableView];
        });
    }
}


- (void)reloadTableView {
    [super reloadTableView];
    [self adjustTableHeight];
}

// MARK: - Table View Headers
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.helper isLiveIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]]) {
        return NSLocalizedString(@"End of Plan", nil);
    }
    return [[self.helper itemForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]] localizedDescriptionWithKey:NO];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlanViewGridSectionMobileHeader *header = nil;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    
    if (![self.helper isValidIndexPath:indexPath]) {
        return header;
    }
    
    if ([self.helper isLiveIndexPath:indexPath]) {
        header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kPlanViewGridSectionHeaderMobileItemHeaderIdentifier];
        
        if ([header.view respondsToSelector:@selector(setTitle:)]) {
            [header.view setTitle:[self tableView:self.tableView titleForHeaderInSection:indexPath.section]];
        }
    } else {
        PCOItem *item = [self.helper itemForIndexPath:indexPath];
        
        if ([item isTypeHeader]) {
            header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kPlanViewGridSectionHeaderMobileItemHeaderIdentifier];
        } else {
            header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kPlanViewGridSectionHeaderMobileIdentifier];
            
            [header.view.settingsButton addTarget:self action:@selector(planItemSettingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            header.view.settingsButton.tag = indexPath.section;
            
            [header.view.lyricsButton addTarget:self action:@selector(editArrangementSequenceAction:) forControlEvents:UIControlEventTouchUpInside];
            header.view.lyricsButton.tag = indexPath.section;
            
            header.view.loopingIcon.hidden = ![item.looping boolValue];
        }
        
        if ([header.view respondsToSelector:@selector(setTitle:)]) {
            [header.view setTitle:[item localizedDescriptionWithKey:NO]];
        }
    }
    header.view.section = indexPath.section;
    
    [self updateSectionStateForHeader:header];
    
    [self.sectionHeaderViews addObject:header];
    
    return header;
}

// MARK: - Button Actions
- (void)planItemSettingsButtonAction:(id)sender {
    PCOButton *button = (PCOButton *)sender;
    PCOItem *item = [self.helper itemForIndexPath:[NSIndexPath indexPathForRow:0 inSection:button.tag]];
    
    PlanItemSettingsViewController *settings = [[PlanItemSettingsViewController alloc] initWithStyle:UITableViewStylePlain];
    settings.selectedItem = item;
    settings.plan = self.helper.plan;
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:settings];
    navigation.modalPresentationStyle = UIModalPresentationFullScreen;
    
    settings.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(planItemSettingsDoneButtonAction:)];
    
    [self presentViewController:navigation animated:YES completion:nil];
}
- (void)editArrangementSequenceAction:(id)sender {
    PCOButton *button = (PCOButton *)sender;
    PCOItem *item = [self.helper itemForIndexPath:[NSIndexPath indexPathForRow:0 inSection:button.tag]];
    
    if ([item isTypeSong]) {
        [[PlanItemEditingController sharedController] warnIfNotArrangementSequenceEditorForPlan:self.helper.plan];
        EditArrangementSequenceViewController *arrSeqViewController = [[EditArrangementSequenceViewController alloc] initWithNibName:nil bundle:nil];
        arrSeqViewController.selectedItem = item;
        arrSeqViewController.plan = self.helper.plan;
        PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:arrSeqViewController];
        [self presentViewController:navigation animated:YES completion:nil];
    } else {
        [[PlanItemEditingController sharedController] warnIfNotCustomSlideEditorForPlan:self.helper.plan];
        CustomSlidesListViewController *customSlidesViewController = [[CustomSlidesListViewController alloc] initWithNibName:nil bundle:nil];
        customSlidesViewController.selectedItem = item;
        customSlidesViewController.plan = self.helper.plan;
        PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:customSlidesViewController];
        [self presentViewController:navigation animated:YES completion:nil];
    }
}
- (void)planItemSettingsDoneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - Header Management
- (void)updateSectionStateForHeader:(PlanViewGridSectionMobileHeader *)header {
    if (![header isKindOfClass:[PlanViewGridSectionMobileHeader class]]) {
        return;
    }
    header.view.state = PlanViewGridSectionStateOff;
    if (self.helper.nextIndexPath && self.helper.nextIndexPath.section == (NSInteger)header.view.section) {
        header.view.state = PlanViewGridSectionStateNext;
    }
    if (self.helper.currentIndexPath && self.helper.currentIndexPath.section == (NSInteger)header.view.section) {
        header.view.state = PlanViewGridSectionStateCurrent;
    }
}
#pragma mark -
#pragma mark - ProjectorP2P_SessionManagerDelegate Methods

- (void)refreshPlan {
    [self.container updatePlanWithCompletion:^{
        [self shouldReloadGridInterface];
    }];
}

// MARK: - PlanGridHelperDelegate
- (NSInteger)numberOfSections {
    NSInteger count = [self.helper numberOfItems];
    if ([self.helper isLiveCurrentlyEnabled]) {
        count += PlanGridHelperLiveSectionCount;
    }
    return count;
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if ([self.helper isLiveIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]]) {
        return PlanGridHelperLiveSectionCount;
    }
    PlanViewMobileGridTableViewCell *cell = (PlanViewMobileGridTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if (![cell isKindOfClass:[PlanViewMobileGridTableViewCell class]]) {
        return [self numberOfItemsInSection:section cell:nil];
    }
    return [cell.collectionView numberOfItemsInSection:0];
}
- (NSArray *)allEventListeners {
    if ([self.parentViewController respondsToSelector:@selector(eventListeners)]) {
        return [(PROPlanContainerViewController *)self.parentViewController eventListeners];
    }
    return nil;
}
- (void)shouldReloadGridInterface {
    [self startTableViewReload];
}

- (void)shouldReloadGridInterfaceForSection:(NSInteger)section {
    [self startTableViewReload];
}

- (void)shouldFastRefreshGridInterface {
    [self startTableViewReload];
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    NSIndexPath *tableIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
    
    if (![self.helper isValidIndexPath:tableIndexPath]) {
        return;
    }
    
    if (self.lowMemoryWarning) {

        [self.tableView scrollToRowAtIndexPath:tableIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
    }
    else {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:tableIndexPath];
        CGPoint cellPoint = cell.frame.origin;
        CGFloat cellHeight = cell.frame.size.height;
//            NSLog(@"cellPoint: %@", NSStringFromCGPoint(cellPoint));
//            NSLog(@"View Frame: %@", NSStringFromCGRect(self.view.frame));
//            NSLog(@"collectionView Frame: %@", NSStringFromCGRect(self.collectionView.frame));
//            NSLog(@"collectionView ContentSize: %@", NSStringFromCGSize(self.collectionView.contentSize));
//            NSLog(@"collectionView Content Insets: %@", NSStringFromUIEdgeInsets(self.collectionView.contentInset));
//            NSLog(@"collectionView Content Offset: %@", NSStringFromCGPoint(self.collectionView.contentOffset));
        cellPoint.x = 0;
        cellPoint.y = -((self.tableView.contentSize.height - cellPoint.y) + (self.view.frame.size.height / 2) - (cellHeight / 2));
        //            NSLog(@"Final cellPoint: %@", NSStringFromCGPoint(cellPoint));
        if (fabs(cellPoint.y) < self.view.frame.size.height) {
            cellPoint.y = -self.view.frame.size.height;
        }
        else if (fabs(cellPoint.y) > self.tableView.contentSize.height) {
            cellPoint.y = -self.tableView.contentSize.height;
        }
        if (fabs(cellPoint.y) <= self.tableView.contentSize.height) {
            [self.tableView setContentOffset:cellPoint animated:animated];
        }
    }
    
    PlanViewMobileGridTableViewCell *cell = (PlanViewMobileGridTableViewCell *)[self.tableView cellForRowAtIndexPath:tableIndexPath];
    if (![cell isKindOfClass:[PlanViewMobileGridTableViewCell class]]) {
        return;
    }
    NSIndexPath *collectionIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    if (collectionIndexPath.row < [self numberOfItemsInSection:indexPath.section]) {
        [cell.collectionView scrollToItemAtIndexPath:collectionIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    }
}
- (void)updateCurrentNextIndexPaths {
    for (PlanViewMobileGridTableViewCell *cell in self.tableView.visibleCells) {
        if ([cell isKindOfClass:[PlanViewMobileGridTableViewCell class]]) {
            PlanViewMobileGridTableViewCellCollectionViewLayout *layout = (PlanViewMobileGridTableViewCellCollectionViewLayout *)cell.collectionView.collectionViewLayout;
            if ([layout respondsToSelector:@selector(selectionChanged)]) {
                [layout selectionChanged];
            }
        }
    }
    for (PlanViewGridSectionMobileHeader *header in [self.sectionHeaderViews allObjects]) {
        [self updateSectionStateForHeader:header];
    }
}
- (PROLogo *)currentLogo {
    return nil;
}

// MARK: - Cell Delegate
- (NSInteger)numberOfItemsInSection:(NSInteger)section cell:(PlanViewMobileGridTableViewCell *)cell {
    if ([self.helper isLiveIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]]) {
        return PlanGridHelperLiveSectionCount;
    }
    return [self.helper numberOfItemsInSection:section];
}
- (UICollectionViewCell *)cell:(PlanViewMobileGridTableViewCell *)tableCell collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath planIndexPath:(NSIndexPath *)planIndexPath {
    PlanViewMobileGridViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PlanViewMobileGridViewCollectionViewCellIdentifier forIndexPath:indexPath];
    if ([self.helper isLiveIndexPath:planIndexPath]) {
        cell.slide = [[PROSlide alloc] init];
        return cell;
    }

    cell.slide = [[PROSlideManager sharedManager] slideForIndexPath:planIndexPath];
    
    return cell;
}
- (void)cell:(PlanViewMobileGridTableViewCell *)cell finalizeCollectionViewSetup:(UICollectionView *)collectionView {
    [collectionView registerClass:[PlanViewMobileGridViewCollectionViewCell class] forCellWithReuseIdentifier:PlanViewMobileGridViewCollectionViewCellIdentifier];
}
- (NSIndexPath *)indexPathForCell:(PlanViewMobileGridTableViewCell *)cell {
    return [self.tableView indexPathForCell:cell];
}
- (void)cell:(PlanViewMobileGridTableViewCell *)cell didSelectIndexPath:(NSIndexPath *)indexPath {
    [self.helper updateSelectedIndexPathsForSelection:indexPath];
    if (indexPath == self.helper.currentIndexPath) {
        [self scrollToIndexPath:indexPath animated:YES];
    }
}
- (NSIndexPath *)planLayoutCurrentIndexPath:(PlanViewGridCollectionViewLayout *)layout {
    return self.helper.currentIndexPath;
}
- (NSIndexPath *)planLayoutUpNextIndexPath:(PlanViewGridCollectionViewLayout *)layout {
    return self.helper.nextIndexPath;
}
- (BOOL)itemAtIndexPathConnectsToPrevious:(NSIndexPath *)indexPath {
    if ([self.helper isLiveIndexPath:indexPath]) {
        return NO;
    }
    return [[[PROSlideManager sharedManager] slideForIndexPath:indexPath] doesContinueFromPrevious];
}

// MARK: - Looping Playlist Methods
- (void)PlanItemLooping_StateChanged_Notification:(NSNotification *)notif {
    PCOItem *planItem = notif.object;
    [self shouldReloadGridInterfaceForSection:[[self.helper.plan orderedItems] indexOfObject:planItem]];
    if ([self.helper isSlideIndexPath:self.helper.currentIndexPath]) {
        PCOItem *currentPlanItem = [self.helper itemForIndexPath:self.helper.currentIndexPath];
        if ( currentPlanItem == planItem) {
            NSNumber *playlistID = [[LoopingPlaylistManager sharedPlaylistManager] getLoopingPlaylistIDForItem:planItem];
            if ([planItem.looping boolValue]) {
                [[LoopingPlaylistManager sharedPlaylistManager] startLoopingTimerForItem:planItem];
                [[ProjectorMusicPlayer sharedPlayer] startPlaylist:playlistID];
            } else if (playlistID) {
                [[ProjectorMusicPlayer sharedPlayer] stopPlaylist];
            }
        }
    }
}
- (void)PlanItemLooping_TimeForNextSlide_Notification:(NSNotification *)notif {
    PCOItem *planItem = notif.object;
    if ([self.helper isSlideIndexPath:self.helper.currentIndexPath]) {
        PCOItem *currentPlanItem = [self.helper itemForIndexPath:self.helper.currentIndexPath];
        if (currentPlanItem == planItem && [planItem.looping boolValue]) {
            NSInteger numberOfSlides = [[[PROSlideManager sharedManager] slideItemForSection:self.helper.currentIndexPath.section] count];
            if (numberOfSlides > 1) {
                NSInteger section = self.helper.currentIndexPath.section;
                NSInteger newRow = self.helper.currentIndexPath.row + 1;
                if (newRow == numberOfSlides) {
                    newRow = 0;
                }
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newRow inSection:section];
                [self.helper updateCurrentIndexPath:newIndexPath];
                [self.helper updateNextIndexPath];
            }
        }
    }
}

- (void)PlanItemLooping_PlaylistChanged_Notification:(NSNotification *)notif {
    if ([self.helper isSlideIndexPath:self.helper.currentIndexPath]) {
        PCOItem *currentItem = [self.helper itemForIndexPath:self.helper.currentIndexPath];
        PCOItem *changedItem = notif.object;
        if (currentItem == changedItem) {
            NSNumber *playlistID = [[LoopingPlaylistManager sharedPlaylistManager] getLoopingPlaylistIDForItem:changedItem];
            if (playlistID && [playlistID intValue] != 0 && [[LoopingPlaylistManager sharedPlaylistManager] getLoopingStateForItem:changedItem]) {
                [[ProjectorMusicPlayer sharedPlayer] startPlaylist:playlistID];
            } else {
                [self stopMusicForItem:changedItem];
            }
        }
    }
}

- (void)stopMusicForItem:(PCOItem *)anItem {
    [[ProjectorMusicPlayer sharedPlayer] stopPlaylist];
}

- (void)configuePlaylistForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath && indexPath.section != PROLogoDisplayItemSectionIndex) {
        PCOItem *currentItem = [self.helper itemForIndexPath:self.helper.currentIndexPath];
        NSNumber *playlistID = [[LoopingPlaylistManager sharedPlaylistManager] getLoopingPlaylistIDForItem:currentItem];
        if (playlistID && [playlistID intValue] != 0 && [[LoopingPlaylistManager sharedPlaylistManager] getLoopingStateForItem:currentItem]) {
            [[ProjectorMusicPlayer sharedPlayer] startPlaylist:playlistID];
        } else {
            [[ProjectorMusicPlayer sharedPlayer] stopPlaylist];
        }
    }
}

#pragma mark -
#pragma mark - PCOLiveControllerDelegate Methods

- (void)scrollToPlanItemId:(NSNumber *)planItemId {
    for (PCOItem *item in [self.helper.plan orderedItems]) {
        if ([planItemId isEqualToNumber:item.remoteId]) {
            NSInteger index = [[self.helper.plan orderedItems] indexOfObject:item];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
            if ([self.helper isValidIndexPath:indexPath]) {
                [self scrollToIndexPath:indexPath animated:YES];
            }
            break;
        }
    }
}

- (void)statusDidUpdate:(PCOLiveStatus *)status {
    [self startTableViewReload];
}

#pragma mark -
#pragma mark - Lazy Loaders

- (UIImageView *)activityIndicator {
    if (!_activityIndicator) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"loader_0000"];
        view.image = image;
        [self.activityView addSubview:view];
        [self.activityView addConstraints:[NSLayoutConstraint center:view inView:self.activityView]];
        _activityIndicator = view;
    }
    return _activityIndicator;
}

- (UIView *)activityView {
    if (!_activityView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = RGBA(41, 41, 47, 0.7);
        [self.view addSubview:view];
        [self.view addConstraints:[NSLayoutConstraint fitView:view inView:self.view insets:UIEdgeInsetsMake(0, 0, 0, 0)]];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activityCancelAction:)];
        tapGesture.numberOfTapsRequired = 2;
        tapGesture.numberOfTouchesRequired = 2;
        [view addGestureRecognizer:tapGesture];
        _activityView = view;
    }
    return _activityView;
}

- (void)activityCancelAction:(UITapGestureRecognizer *)tap {
    [[PROUIOptimization sharedOptimizer] finishedFullUIReload];
    if (!self.lowMemoryWarning ) {
        [self.activityView setHidden:YES];
    }
}
#pragma mark -
#pragma mark - Pull to Refresh

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isDecelerating] || self.activityView.hidden == NO) {
        //    NSLog(@"scrollViewDidScroll Content Offset: %@", NSStringFromCGPoint(self.collectionView.contentOffset));
        CGFloat draggedOffset = self.tableView.contentOffset.y;
        CGFloat startingPoint = 0.0;
        if (!self.lowMemoryWarning) {
            startingPoint = self.tableView.contentSize.height;
        }
        if (self.planRefreshing) {
            return;
        }
        if (draggedOffset < 0.0) {
            if (fabs(draggedOffset) - startingPoint > PULL_TO_REFRESH_DRAG_POINTS && [scrollView isDecelerating]) { //self.view.frame.size.height * PULL_TO_REFRESH_DRAG_PERCENT) {
                [self.container updatePlanWithCompletion:^{
                    
                }];
            }
            else {
                CGFloat newAlpha = (fabs(draggedOffset) - startingPoint) / PULL_TO_REFRESH_DRAG_POINTS;
                if (newAlpha > 1.0) {
                    newAlpha = 1.0;
                    [self startActivityIndicatorAnimation];
                }
                if (newAlpha > PULL_TO_REFRESH_REVEAL_PERCENT) {
                    newAlpha = (newAlpha - PULL_TO_REFRESH_REVEAL_PERCENT) / (1.0 - PULL_TO_REFRESH_REVEAL_PERCENT);
                    self.activityView.alpha = newAlpha;
                    if (newAlpha > 0.0) {
                        if (newAlpha < 1.0) {
                            [self stopActivityIndicatorAnimation];
                        }
                        self.activityView.hidden = NO;
                    }
                }
                else {
                    self.activityView.hidden = YES;
                }
            }
        }
    }
}

- (void)willBeginRefresh {
    [PCOEventLogger logEvent:@"Grid View - Pull to refresh"];
    self.planRefreshing = YES;
    [self.view bringSubviewToFront:self.activityView];
    [self startActivityIndicatorAnimation];
    [self.activityView setHidden:NO];
    [self.activityView setAlpha:1.0];
}

- (void)didEndRefresh {
    if (self.lowMemoryWarning) {
        [self.activityView setHidden:YES];
    }
    self.planRefreshing = NO;
}

- (void)startActivityIndicatorAnimation {
    [self.activityIndicator setImage:[UIImage animatedImageNamed:@"loader_000" duration:1.6]];
}

- (void)stopActivityIndicatorAnimation {
    self.activityIndicator.image = [UIImage imageNamed:@"loader_0000"];
}

@end
