/*!
 * PlanViewGridViewController.m
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#import "PlanViewGridViewController.h"
#import "PROPlanContainerViewController.h"
#import "PROContainerViewControllerEventListener.h"
#import "PlanOutputViewController.h"
#import "FilesListTableViewController.h"

// Grid
#import "PlanViewGridCollectionViewLayout.h"
#import "PlanViewGridSectionHeader.h"
#import "PlanViewGridSectionHeaderItemHeader.h"
#import "PlanViewGridItemCell.h"
#import "PCOSlide.h"

#import "PROSlideManager.h"
#import "ProjectorMusicPlayer.h"

#import "PRONavigationController.h"
#import "PlanItemSettingsViewController.h"
#import "PlanItemEditingController.h"
#import "LoopingPlaylistManager.h"

#import "EditArrangementSequenceViewController.h"
#import "CustomSlidesListViewController.h"

// Data
#import "PROBlackItem.h"
#import "PROLogoDisplayItem.h"
#import "PROEndOfPlanItem.h"

#import "PlanItemEditingController.h"
#import "PlanEditingController.h"

#import "PROUIOptimization.h"

#define PULL_TO_REFRESH_DRAG_PERCENT    0.35
#define PULL_TO_REFRESH_DRAG_POINTS     120
#define PULL_TO_REFRESH_REVEAL_PERCENT  0.25

static NSString *const kPlanViewGridSectionHeaderIdentifier = @"kPlanViewGridSectionHeaderIdentifier";
static NSString *const kPlanViewGridSectionHeaderItemHeaderIdentifier = @"kPlanViewGridSectionHeaderItemHeaderIdentifier";
static NSString *const kPlanViewGridCellIdentifier = @"kPlanViewGridCellIdentifier";

@interface PlanViewGridViewController () <PlanViewGridCollectionViewLayoutDelegate, PlanGridHelperDelegate, ProjectorP2P_SessionManagerDelegate> {
   
}

@property (nonatomic, strong) NSHashTable *sectionHeaderViews;

@property (nonatomic, strong) NSLayoutConstraint *gridYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *gridHeightConstraint;
@property (nonatomic, strong) NSArray *lowMemoryConstraints;

@property (nonatomic, weak) UIView *activityView;
@property (nonatomic, weak) UIImageView *activityIndicator;

@property (nonatomic) BOOL lowMemoryWarning;
@property (nonatomic) BOOL planRefreshing;

@end

@implementation PlanViewGridViewController

- (void)loadView {
    [super loadView];
    [[PCOLiveController sharedController] addDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlanItemLooping_StateChanged_Notification:) name:PlanItemLooping_StateChanged_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlanItemLooping_PlaylistChanged_Notification:) name:PlanItemLooping_PlaylistChanged_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlanItemLooping_TimeForNextSlide_Notification:) name:PlanItemLooping_TimeForNextSlide_Notification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aspectRatioDidChange:) name:kProjectorDefaultAspectRatioSetting object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildCellCache) name:PROSlideManagerDidFlushCacheNotification object:nil];
    self.collectionView.hidden = NO;
    [[ProjectorP2P_SessionManager sharedManager] addDelegate:self];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)planUpdated {
    
}

- (void)pro_setContainer:(PROPlanContainerViewController *)container {
    _container = container;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // need to reload the entire grid but not display the entire grid
    self.lowMemoryWarning = YES;
    [self startCollectionViewReload];
}

// MARK: - Helper
- (PlanGridHelper *)helper {
    if (!_helper) {
        _helper = [[PlanGridHelper alloc] init];
        _helper.delegate = self;
    }
    return _helper;
}

- (void)aspectRatioDidChange:(NSNotification *)notif {
    [self.collectionView.collectionViewLayout invalidateLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadCollectionView];
    });
}

#pragma mark -
#pragma mark - PlanViewGridCollectionViewLayoutDelegate

- (void)installConstraintsForCollectionView:(UICollectionView *)collectionView onView:(UIView *)view {
    
    if (self.lowMemoryWarning) {
        [super installConstraintsForCollectionView:collectionView onView:view];
        return;
    }
    [view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:collectionView offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
    self.gridHeightConstraint = [NSLayoutConstraint height:collectionView.contentSize.height forView:collectionView];
    self.gridYConstraint = [NSLayoutConstraint constraintWithItem:collectionView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:view
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:-self.collectionView.contentSize.height];
    [view addConstraints:@[self.gridHeightConstraint, self.gridYConstraint]];
}

- (void)adjustGridHeight {
    CGFloat height = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
//    NSLog(@"View Frame: %@", NSStringFromCGRect(self.view.frame));
//    NSLog(@"TableView Frame: %@", NSStringFromCGRect(self.collectionView.frame));
//    NSLog(@"TableView ContentSize: %@", NSStringFromCGSize(self.collectionView.collectionViewLayout.collectionViewContentSize));
//    NSLog(@"TableView Content Insets: %@", NSStringFromUIEdgeInsets(self.collectionView.contentInset));
    
    if (_gridHeightConstraint && _gridYConstraint) {
        [self.collectionView.superview removeConstraints:@[self.gridHeightConstraint, self.gridYConstraint]];
        _gridHeightConstraint = nil;
        _gridYConstraint = nil;
    }

    if (_lowMemoryConstraints) {
        [self.collectionView.superview removeConstraints:self.lowMemoryConstraints];
        _lowMemoryConstraints = nil;
    }

    if (self.lowMemoryWarning) {
        self.lowMemoryConstraints = [NSLayoutConstraint pco_offsetViewEdgesInSuperview:self.collectionView offset:0.0 edges:UIRectEdgeAll];
        [self.collectionView.superview addConstraints:self.lowMemoryConstraints];
    }
    else {
        
        self.gridHeightConstraint = [NSLayoutConstraint height:(height *2) forView:self.collectionView];
        
        self.gridYConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.collectionView.superview
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:-height];
        
        [self.collectionView.superview addConstraints:@[self.gridHeightConstraint, self.gridYConstraint]];
        UIEdgeInsets insets = UIEdgeInsetsMake(height, 0, height - self.view.frame.size.height, 0);
        self.collectionView.contentInset = insets;
        self.collectionView.scrollIndicatorInsets = insets;

//        NSLog(@"contentOffset: %@", NSStringFromCGPoint(self.collectionView.contentOffset));
//        NSLog(@"contentSize: %@", NSStringFromCGSize(self.collectionView.collectionViewLayout.collectionViewContentSize));
//        NSLog(@"Frame: %@", NSStringFromCGRect(self.view.frame));
        
        CGPoint startPoint = CGPointMake(0, -height);
//        NSLog(@"startPoint: %@",  NSStringFromCGPoint(startPoint));
        if (!self.helper.currentIndexPath && CGPointEqualToPoint(self.collectionView.contentOffset, CGPointZero)) {
            self.collectionView.contentOffset = startPoint;
        }
        
        if (self.collectionView.contentOffset.y < startPoint.y) {
            self.collectionView.contentOffset = startPoint;
        }
    }
}

- (BOOL)hasLowMemoryWarning {
    return self.lowMemoryWarning;
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
    PROSlide *slide = [[PROSlideManager sharedManager] slideForIndexPath:indexPath];
    return [slide doesContinueFromPrevious];
}
- (void)updateSectionStateForHeader:(PlanViewGridSectionHeader *)header {
    if (![header isKindOfClass:[PlanViewGridSectionHeader class]]) {
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
#pragma mark - Pull to Refresh

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isDecelerating] || self.activityView.hidden == NO) {
        CGFloat draggedOffset = self.collectionView.contentOffset.y;
        CGFloat startingPoint = 0.0;
        if (!self.lowMemoryWarning) {
            startingPoint = self.collectionView.contentSize.height;
        }
        if (self.planRefreshing) {
            return;
        }
        if (draggedOffset < 0.0) {
            if (fabs(draggedOffset) - startingPoint > PULL_TO_REFRESH_DRAG_POINTS && [scrollView isDecelerating]) {
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

#pragma mark -
#pragma mark - Lazy Loaders
- (NSHashTable *)sectionHeaderViews {
    if (!_sectionHeaderViews) {
        _sectionHeaderViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _sectionHeaderViews;
}

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

#pragma mark -
#pragma mark - Action Methods

- (void)activityCancelAction:(UITapGestureRecognizer *)tap {
    [[PROUIOptimization sharedOptimizer] finishedFullUIReload];
    if (!self.lowMemoryWarning ) {
        [self.activityView setHidden:YES];
    }
}


#pragma mark -
#pragma mark - Collection View Setup
- (UICollectionViewLayout *)newDefaultCollectionViewLayout {
    return [[PlanViewGridCollectionViewLayout alloc] init];
}
- (void)finishCollectionViewConfig:(UICollectionView *)collectionView {
    collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    collectionView.alwaysBounceVertical = YES;
    collectionView.backgroundColor = [UIColor planGridBackgroundColor];
    
}
- (void)registerCellClassesForCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[PlanViewGridSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kPlanViewGridSectionHeaderIdentifier];
    [collectionView registerClass:[PlanViewGridSectionHeaderItemHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kPlanViewGridSectionHeaderItemHeaderIdentifier];
    [collectionView registerClass:[PlanViewGridItemCell class] forCellWithReuseIdentifier:kPlanViewGridCellIdentifier];
}

- (void)gridSizeSettingDidChange {
    if (self.lowMemoryWarning) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.helper.currentIndexPath) {
            [self adjustGridHeight];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self scrollToIndexPath:self.helper.currentIndexPath animated:NO];
            });
        }
        else {
            [self adjustGridHeight];
        }
    });
}

#pragma mark -
#pragma mark - Data

- (void)startCollectionViewReload {
    if ([[PROUIOptimization sharedOptimizer] shouldGridReload] && [self.helper numberOfSections] > 0) {
        [[PROUIOptimization sharedOptimizer] startedFullUIReload];
        if (!self.lowMemoryWarning && self.helper.plan) {
            [self.view bringSubviewToFront:self.activityView];
            [self startActivityIndicatorAnimation];
            [self.activityView setHidden:NO];
            [self.activityView setAlpha:1.0];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadCollectionView];
        });
    }
}

- (void)reloadCollectionView {
    [super reloadCollectionView];
    
    if ([self.collectionView.collectionViewLayout respondsToSelector:@selector(invalidateLayoutCache)]) {
        [((PlanViewGridCollectionViewLayout *)self.collectionView.collectionViewLayout) invalidateLayoutCache];
        [((PlanViewGridCollectionViewLayout *)self.collectionView.collectionViewLayout) prepareLayout];
    }
    [self adjustGridHeight];
}

#pragma mark -
#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger count = [self.helper numberOfSections];
    OptiEventLog(@"numberOfSectionsInCollectionView: %d", count);
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = [self.helper numberOfItemsInSection:section];
    OptiEventLog(@"numberOfItemsInSection: %d, count: %d",section , count);
    [[PROUIOptimization sharedOptimizer] setNumberOfRows:count inSection:section];
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OptiEventLog(@"cellForItemAtIndexPath: %@", indexPath);
    if ([[PROUIOptimization sharedOptimizer] isLastCellAtIndexPath:indexPath]) {
        if ([[PROUIOptimization sharedOptimizer] isFullUIReloading]) {
            [[PROUIOptimization sharedOptimizer] finishedFullUIReload];
            if ([[PROUIOptimization sharedOptimizer] wasFreshPlan]) {
                [self.collectionView.collectionViewLayout invalidateLayout];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *topOfGrid = [self.helper firstValidIndexPathForPlan];
                    if (topOfGrid) {
                        [self scrollToIndexPath:topOfGrid animated:NO];
                    }
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

    PlanViewGridItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPlanViewGridCellIdentifier forIndexPath:indexPath];
    
    if ([self.helper isLiveIndexPath:indexPath]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor blackColor];
        cell.thumbnailView = view;
        return cell;
    }
    
    PROSlide *slide = [[PROSlideManager sharedManager] slideForIndexPath:indexPath];
    
    cell.thumbnailView = (UIView *)[slide thumbnailView];
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PlanViewGridSectionHeader *header = nil;
    
    if ([self.helper isLiveIndexPath:indexPath]) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kPlanViewGridSectionHeaderItemHeaderIdentifier forIndexPath:indexPath];
        
        if ([header.view respondsToSelector:@selector(setTitle:)]) {
            [header.view setTitle:NSLocalizedString(@"End of Plan", nil)];
        }
    } else {
        PCOItem *item = [self.helper itemForIndexPath:indexPath];
        
        if ([item isTypeHeader]) {
            header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kPlanViewGridSectionHeaderItemHeaderIdentifier forIndexPath:indexPath];
        } else {
            header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kPlanViewGridSectionHeaderIdentifier forIndexPath:indexPath];
            
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.helper updateSelectedIndexPathsForSelection:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath == self.helper.currentIndexPath) {
        [self scrollToIndexPath:indexPath animated:YES];
    }
}

- (void)playSlideAtIndex:(NSInteger)slideIndex withPlanItemIndex:(NSInteger)planItemIndex andScrubPosition:(float)scrubPosition shouldPause:(BOOL)shouldPause {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:slideIndex inSection:planItemIndex];
    if ([self.helper isSlideIndexPath:indexPath] && [self.helper isValidIndexPath:indexPath]) {
        if (self.helper.currentIndexPath == nil || self.helper.currentIndexPath.section != indexPath.section || self.helper.currentIndexPath.row != indexPath.row) {
            [self.helper updateNextIndexPathPath:indexPath];
            [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
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
    [self startCollectionViewReload];
}

- (void)planItemSettingsButtonAction:(id)sender {
    PCOButton *button = (PCOButton *)sender;
    PCOItem *item = [self.helper itemForIndexPath:[NSIndexPath indexPathForRow:0 inSection:button.tag]];

    PlanItemSettingsViewController *settings = [[PlanItemSettingsViewController alloc] initWithStyle:UITableViewStylePlain];
    settings.selectedItem = item;
    settings.plan = self.helper.plan;
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:settings];
    navigation.modalPresentationStyle = UIModalPresentationPopover;
    navigation.popoverPresentationController.sourceView = button;
    navigation.popoverPresentationController.sourceRect = button.bounds;
    
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
        navigation.view.layer.borderWidth = 1;
        navigation.view.layer.borderColor = [HEX(0x585863) CGColor];
        navigation.view.layer.cornerRadius = 7;
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navigation animated:YES completion:nil];
    } else {
        [[PlanItemEditingController sharedController] warnIfNotCustomSlideEditorForPlan:self.helper.plan];
        CustomSlidesListViewController *customSlidesViewController = [[CustomSlidesListViewController alloc] initWithNibName:nil bundle:nil];
        customSlidesViewController.selectedItem = item;
        customSlidesViewController.plan = self.helper.plan;
        PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:customSlidesViewController];
        navigation.view.layer.borderWidth = 1;
        navigation.view.layer.borderColor = [HEX(0x585863) CGColor];
        navigation.view.layer.cornerRadius = 7;
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navigation animated:YES completion:nil];
    }
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
#pragma mark - ProjectorP2P_SessionManagerDelegate Methods

- (void)refreshPlan {
    [self.container updatePlanWithCompletion:^{
        [self shouldReloadGridInterface];
    }];
}

// MARK: - Plan Grid Helper
- (void)shouldReloadGridInterface {
    [self startCollectionViewReload];
}

- (void)shouldReloadGridInterfaceForSection:(NSInteger)section {
    OptiEventLog(@"Wants to reload section: %li", (long)section);
//    if ([[PROUIOptimization sharedOptimizer] shouldGridReloadSection]) {
//        OptiEventLog(@"Allowed to reload section: %li", (long)section);
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
//        [self adjustGridHeight];
//    }
    [self startCollectionViewReload];
}

- (void)shouldFastRefreshGridInterface {
    [self startCollectionViewReload];
}
- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if ([self.helper isValidIndexPath:indexPath]) {
        if (self.lowMemoryWarning) {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:animated];
        }
        else {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            CGPoint cellPoint = cell.frame.origin;
            CGFloat cellHeight = cell.frame.size.height;
//            NSLog(@"cellPoint: %@", NSStringFromCGPoint(cellPoint));
//            NSLog(@"View Frame: %@", NSStringFromCGRect(self.view.frame));
//            NSLog(@"collectionView Frame: %@", NSStringFromCGRect(self.collectionView.frame));
//            NSLog(@"collectionView ContentSize: %@", NSStringFromCGSize(self.collectionView.contentSize));
//            NSLog(@"collectionView Content Insets: %@", NSStringFromUIEdgeInsets(self.collectionView.contentInset));
//            NSLog(@"collectionView Content Offset: %@", NSStringFromCGPoint(self.collectionView.contentOffset));
            cellPoint.x = 0;
            cellPoint.y = -((self.collectionView.contentSize.height - cellPoint.y) + (self.view.frame.size.height / 2) - (cellHeight / 2));
//            NSLog(@"Final cellPoint: %@", NSStringFromCGPoint(cellPoint));
            if (fabs(cellPoint.y) < self.view.frame.size.height) {
                cellPoint.y = -self.view.frame.size.height;
            }
            else if (fabs(cellPoint.y) > self.collectionView.contentSize.height) {
                cellPoint.y = -self.collectionView.contentSize.height;
            }
            if (fabs(cellPoint.y) <= self.collectionView.contentSize.height) {
                [self.collectionView setContentOffset:cellPoint animated:animated];
            }
        }
    }
}
- (NSArray *)allEventListeners {
    return [self.container eventListeners];
}
- (NSInteger)numberOfSections {
    return [self.collectionView numberOfSections];
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self.collectionView numberOfItemsInSection:section];
}
- (void)updateCurrentNextIndexPaths {
    PlanViewGridCollectionViewLayout *layout = (PlanViewGridCollectionViewLayout *)self.collectionView.collectionViewLayout;
    if ([layout respondsToSelector:@selector(selectionChanged)]) {
        [layout selectionChanged];
    }
    for (PlanViewGridSectionHeader *header in [self.sectionHeaderViews allObjects]) {
        [self updateSectionStateForHeader:header];
    }
}
- (PROLogo *)currentLogo {
    return [self.container.outputController currentLogo];
}

@end
