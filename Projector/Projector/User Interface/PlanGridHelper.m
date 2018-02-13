/*!
 * PlanGridHelper.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/1/14
 */

#import "PlanGridHelper.h"

#import "PROLogoDisplayItem.h"
#import "PROSlideManager.h"
#import "PROContainerViewControllerEventListener.h"
#import "PROEndOfPlanItem.h"
#import "PROBlackItem.h"
#import "ProjectorP2P_SessionManager.h"
#import "PCOLiveController.h"
#import "LoopingPlaylistManager.h"
#import "ProjectorMusicPlayer.h"
#import "PlanItemEditingController.h"
#import "FilesListTableViewController.h"
#import "PlanEditingController.h"
#import "PROSlideshow.h"
#import "PCOAttachment.h"
#import "PROUIOptimization.h"
#import "NSString+FileTypeAdditions.h"
#import "PCOCustomSlide.h"
#import "PCOPlanItemMedia.h"
#import "PCOMedia.h"

@interface PlanGridHelper ()

@property (nonatomic, strong) NSCache *itemCache;

@property (nonatomic, strong) PROBlackItem *blackItem;
@property (nonatomic, strong) PROLogoDisplayItem *logoItem;
@property (nonatomic, strong) PROEndOfPlanItem *endOfPlanItem;

@property (nonatomic, strong) NSArray *items;


@property (nonatomic, strong, readwrite) NSIndexPath *currentIndexPath;
@property (nonatomic, strong, readwrite) NSIndexPath *nextIndexPath;

@end

@implementation PlanGridHelper

// MARK: - Lifecycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDisplays:) name:P2PClientCreatedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDisplays:) name:P2PLostPeerNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDisplays:) name:P2PFoundPeerNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionConnectionChangedNotification:) name:P2PSessionConnectedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionConnectionChangedNotification:) name:P2PSessionDisconnectedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDisplays:) name:P2PSessionClientCouldNotConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDisplays:) name:P2PSessionStateChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDisplays:) name:P2P_CLIENT_MODE_CHANGED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGridInterface) name:FilesListTableViewControllerDidDeleteFileNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fastReloadGridInterface) name:PROSlideManagerDidFlushCacheNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGridSectionInterface:) name:PROSlideManagerDidFlushCacheSectionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGridAndDisplaysForItem:) name:PlanItemBackgroundChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGridAndDisplaysForItem:) name:PlanItemLayoutChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(powerPointStateDidChangeNotification:) name:PROSlideshowStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arrangementSequenceChangesNotification:) name:ArrangementSequenceChangesNotification object:nil];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - PPT Notifications
- (void)powerPointStateDidChangeNotification:(NSNotification *)notif {
    PCOAssertMainThread();
    
    self.items = nil;

    PROSlideshow *ppt = notif.object;
    if (![ppt isKindOfClass:[PROSlideshow class]]) {
        return;
    }
    
    if (ppt.status == PROSlideshowStatusDownloading) {
        [self.delegate shouldFastRefreshGridInterface];
    }
    if (ppt.status == PROSlideshowStatusReady) {
        PROSlideshow *slideShow = (PROSlideshow *)[notif object];
        NSArray *itemIndexes = [[PROSlideManager sharedManager] pptSectionsUsingAttachmentId:slideShow.attachmentID];
        for (NSNumber *index in itemIndexes) {
            [self.delegate shouldReloadGridInterfaceForSection:[index integerValue]];
        }
    }
}

// MARK: - Arrangement Sequence Change Notification
- (void)arrangementSequenceChangesNotification:(NSNotification *)notif {
    PCOItem *item = [notif object];
    [self reloadGridInterfaceForItem:item];
    [self performSafe:@selector(userInterfaceWillRefresh) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener userInterfaceWillRefresh];
    }];
}

// MARK: - Play Next/Previous
- (void)playNextSlide {
    NSIndexPath *indexPath = nil;
    
    if (!self.currentIndexPath) {
        if (self.nextIndexPath) {
            indexPath = self.nextIndexPath;
        } else {
            indexPath = [self nextValidIndexPathAfterIndexPath:nil];
        }
    } else {
        if (!self.nextIndexPath) {
            if ([[[PCOLiveController sharedController] liveStatus] isEndOfServiceNext]) {
                return;
            }
            [self setCurrentToBlack];
            return;
        }
        indexPath = self.nextIndexPath;
    }
    
    if ([self isValidIndexPath:indexPath]) {
        if ([self isLiveIndexPath:indexPath]) {
            self.currentIndexPath = indexPath;
            if ([[[PCOLiveController sharedController] liveStatus] isEndOfServiceNext]) {
                self.nextIndexPath = nil;
            } else {
                self.nextIndexPath = [self firstValidIndexPathForPlan];
            }
            [[PCOLiveController sharedController] liveNextAtPlanItemIndex:indexPath.section];
        } else {
            self.currentIndexPath = indexPath;
            self.nextIndexPath = [self nextValidIndexPathAfterIndexPath:indexPath];
            [[PCOLiveController sharedController] startLiveItemAtPlanItemIndex:indexPath.section];
        }
        [self updateUIForSelectionChange];
        [self.delegate scrollToIndexPath:indexPath animated:YES];
    } else if ([self isLogoIndexPath:indexPath]) {
        [self setCurrentToLogo:[self.delegate currentLogo]];
    } else {
        self.nextIndexPath = [self firstValidIndexPathForPlan];
    }
}

- (void)playPreviousSlide {
    NSIndexPath *indexPath = nil;
    NSInteger newSection = 0;
    NSInteger newRow = 0;
    
    if ([self isSlideIndexPath:self.currentIndexPath]) {
        newSection = self.currentIndexPath.section;
        newRow = self.currentIndexPath.row - 1;
        while (newRow < 0) {
            newSection--;
            if (newSection < 0) {
                // here is where we are at the beginning of the plan
                // if live is on and there are no previous services then we should go to a black screen for the selected
                if ([self isLiveCurrentlyEnabled] && [[PCOLiveController sharedController] hasPreviousServiceTime]) {
                    // need to do a previous api call here
                    [[PCOLiveController sharedController] livePrevious];
                    // set the currentIP to the End of Plan cell and nextIP to the very first cell
                    newSection = [self.delegate numberOfSections] - 1;
                    newRow = [self numberOfItemsInSection:newSection] - 1;
                    indexPath = [NSIndexPath indexPathForRow:newRow inSection:newSection];
                    self.currentIndexPath = indexPath;
                    self.nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.delegate scrollToIndexPath:indexPath animated:YES];
                    return;
                } else {
                    self.currentIndexPath = nil;
                    self.nextIndexPath = [self firstValidIndexPathForPlan];
                    if ([self isLiveCurrentlyEnabled]) {
                        [[PCOLiveController sharedController] livePrevious];
                    }
                    return;
                }
                
            } else {
                newRow = [self numberOfItemsInSection:newSection] - 1;
            }
        }
        
        indexPath = [NSIndexPath indexPathForRow:newRow inSection:newSection];
        
        if ([self isValidIndexPath:indexPath]) {
            NSIndexPath *upNext = [self.currentIndexPath copy];
            
            if ([self isLiveIndexPath:self.currentIndexPath]) {
                // we are on the End of Plan slide and asking to go back to previous plan
                [[PCOLiveController sharedController] livePrevious];
            }
            else {
                [[PCOLiveController sharedController] startLiveItemAtPlanItemIndex:indexPath.section];
            }
            self.currentIndexPath = indexPath;
            self.nextIndexPath = upNext;
            [self.delegate scrollToIndexPath:indexPath animated:YES];
            
        }
    }
}

// MARK: - Preset Screens
- (void)setCurrentToBlack {
    [PCOEventLogger logEvent:@"Play Black Screen"];
    NSIndexPath *current = [self.currentIndexPath copy];
    self.currentIndexPath = nil;
    
    NSIndexPath *next = current;
    if ([self isSlideIndexPath:current] && ![self isLiveIndexPath:next]) {
        next = [self nextValidIndexPathAfterIndexPath:current];
    }
    self.nextIndexPath = (next) ?: current;
}
- (void)setNextToBlack {
    self.nextIndexPath = nil;
}
- (void)reloadCurrentWithLogo:(PROLogo *)logo {
    if (logo && ![logo.fileName isEqualToString:self.logoItem.logo.fileName]) {
        [PCOEventLogger logEvent:@"Play Logo Screen"];
        self.logoItem = [[PROLogoDisplayItem alloc] initWithLogo:logo];
        self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:PROLogoDisplayItemSectionIndex];
    }
}
- (void)setCurrentToLogo:(PROLogo *)logo {
    [PCOEventLogger logEvent:@"Play Logo Screen"];
    if (logo) {
        self.logoItem = [[PROLogoDisplayItem alloc] initWithLogo:logo];
    } else {
        self.logoItem = nil;
    }
    NSIndexPath *current = [self.currentIndexPath copy];
    self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:PROLogoDisplayItemSectionIndex];
    NSIndexPath *next = current;
    if ([self isSlideIndexPath:current]) {
        next = [self nextValidIndexPathAfterIndexPath:current];
    }
    self.nextIndexPath = (next) ?: current;
}
- (void)setNextToLogo:(PROLogo *)logo {
    if (logo) {
        self.logoItem = [[PROLogoDisplayItem alloc] initWithLogo:logo];
    } else {
        self.logoItem = nil;
    }
    self.nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:PROLogoDisplayItemSectionIndex];
}

- (void)updateCurrentIndexPath:(NSIndexPath *)indexPath {
    self.currentIndexPath = indexPath;
}
- (void)updateNextIndexPathPath:(NSIndexPath *)indexPath {
    self.nextIndexPath = indexPath;
}

// MARK: - Show Current
- (void)buildAndDisplayCurrentItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        [self updateCurrentDisplayItemWithItem:self.blackItem];
        return;
    }
    if (indexPath.section == PROLogoDisplayItemSectionIndex) {
        [self updateCurrentDisplayItemWithItem:(self.logoItem) ?: self.blackItem];
        return;
    }
    if ([self isLiveIndexPath:indexPath]) {
        [self updateCurrentDisplayItemWithItem:self.endOfPlanItem];
        return;
    }
    
    PROSlide *slide = [[PROSlideManager sharedManager] slideForIndexPath:indexPath];
    NSString *cacheKey = [self _displayItemCacheKeyForIndexPath:indexPath];
    PRODisplayItem *item = [self.itemCache objectForKey:cacheKey compute:^id(id key) {
        return [self newDisplayItemForIndexPath:indexPath];
    }];
    
    item.confidenceText = nil;
    if ([[ProjectorP2P_SessionManager sharedManager] isConnectedClient] && [[ProjectorP2P_SessionManager sharedManager] clientMode] == P2PClientModeConfidence) {
        NSIndexPath *nextSlideIndexPath = [self nextValidIndexPathAfterIndexPath:indexPath];
        if (nextSlideIndexPath && (nextSlideIndexPath.section == indexPath.section)) {
            PROSlide *nextSlide = [[PROSlideManager sharedManager] slideForIndexPath:nextSlideIndexPath];
            NSArray *array = [nextSlide.text componentsSeparatedByString:@"\n"];
            if ([array count] > 0) {
                item.confidenceText = [self buildConfidenceString:[array firstObject]];
            }
        }
    }
    
    item.indexPath = indexPath;
    
    [item configureForSlide:slide];
    
    [self updateCurrentDisplayItemWithItem:item];
}
- (void)updateCurrentDisplayItemWithItem:(PRODisplayItem *)item {
    [self performSafe:@selector(currentItemWillChange:) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener currentItemWillChange:listener];
    }];
    _currentItem = item;
    [self performSafe:@selector(currentItemDidChange:) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener currentItemDidChange:item];
    }];
}
- (void)buildAndDisplayUpNextItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        [self updateUpNextDisplayItemWithItem:self.blackItem];
        return;
    }
    if (indexPath.section == PROLogoDisplayItemSectionIndex) {
        [self updateUpNextDisplayItemWithItem:(self.logoItem) ?: self.blackItem];
        return;
    }
    if ([self isLiveIndexPath:indexPath]) {
        [self updateUpNextDisplayItemWithItem:self.endOfPlanItem];
        return;
    }
    
    PROSlide *slide = [[PROSlideManager sharedManager] slideForIndexPath:indexPath];
    NSString *cacheKey = [self _displayItemCacheKeyForIndexPath:indexPath];
    PRODisplayItem *item = [self.itemCache objectForKey:cacheKey compute:^id(id key) {
        return [self newDisplayItemForIndexPath:indexPath];
    }];
    
    item.confidenceText = nil;
    
    if ([[ProjectorP2P_SessionManager sharedManager] isConnectedClient] && [[ProjectorP2P_SessionManager sharedManager] clientMode] == P2PClientModeConfidence) {
        NSIndexPath *nextSlideIndexPath = [self nextValidIndexPathAfterIndexPath:indexPath];
        if (nextSlideIndexPath) {
            PROSlide *nextSlide = [[PROSlideManager sharedManager] slideForIndexPath:nextSlideIndexPath];
            NSArray *array = [nextSlide.text componentsSeparatedByString:@"\n"];
            if ([array count] > 0) {
                item.confidenceText = [self buildConfidenceString:[array firstObject]];
            }
        }
    }
    
    item.indexPath = indexPath;
    [item configureForSlide:slide];
    
    item.background.staticBackgroundImage = nil;
    
    [self updateUpNextDisplayItemWithItem:item];
}

- (void)updateUpNextDisplayItemWithItem:(PRODisplayItem *)item {
    [self performSafe:@selector(upNextItemWillChange:) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener upNextItemWillChange:listener];
    }];
    _upNextItem = item;
    [self performSafe:@selector(upNextItemDidChange:) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener upNextItemDidChange:item];
    }];
}

- (void)updateUIForSelectionChange {
    [self.delegate updateCurrentNextIndexPaths];
    [self performSafe:@selector(userInterfaceWillRefresh) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener userInterfaceWillRefresh];
    }];
}

- (void)updateSelectedIndexPathsForSelection:(NSIndexPath *)indexPath {
    if (!indexPath) {
        self.nextIndexPath = nil;
        self.currentIndexPath  = nil;
        return;
    }
    
    if ([self.currentIndexPath isEqual:indexPath]) {
        return;
    }
    
    if ([self.nextIndexPath isEqual:indexPath]) {
        self.currentIndexPath = indexPath;
        [self updateNextIndexPath];
        if ([self isLiveCurrentlyEnabled]) {
            if ([[PCOLiveController sharedController] isLiveStatusEnded]) {
                if ([self isLiveIndexPath:indexPath]) {
                    self.nextIndexPath = [self firstValidIndexPathForPlan];
                }
                else {
                    // We are at the end of the plan so we need to do a previous to set a new cell
                    [[PCOLiveController sharedController] livePreviousWithSuccessCompletion:^{
                        [[PCOLiveController sharedController] startLiveItemAtPlanItemIndex:self.currentIndexPath.section];
                    } errorCompletion:^(NSError *error) {
                        
                    }];
                }
            } else {
                if ([self isLiveIndexPath:indexPath]) {
                    NSInteger lastPlanItemIndex = [self.items count] - 1;
                    [[PCOLiveController sharedController] moveLiveToEndOfServiceFromPlanItemIndex:lastPlanItemIndex];
                    if (![[PCOLiveController sharedController] hasNextServiceTime]) {
                        self.nextIndexPath = nil;
                    } else {
                        self.nextIndexPath = [self firstValidIndexPathForPlan];
                    }
                    
                } else {
                    [[PCOLiveController sharedController] startLiveItemAtPlanItemIndex:self.currentIndexPath.section];
                }
            }
        }
        return;
    }
    
    self.nextIndexPath = indexPath;
}
- (void)updateNextIndexPath {
    self.nextIndexPath = [self nextValidIndexPathAfterIndexPath:self.currentIndexPath];
}

// MARK: - Setters
- (void)setNextIndexPath:(NSIndexPath *)nextIndexPath {
    [self performSafe:@selector(nextUpIndexPathWillChange:) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener nextUpIndexPathWillChange:nextIndexPath];
    }];
    _nextIndexPath = nextIndexPath;
    [self buildAndDisplayUpNextItemAtIndexPath:nextIndexPath];
    [self updateUIForSelectionChange];
    [self performSafe:@selector(nextUpIndexPathDidChange:) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener nextUpIndexPathDidChange:nextIndexPath];
    }];
}
- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath {
    [self performSafe:@selector(currentPlayingIndexPathWillChange:) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener currentPlayingIndexPathWillChange:currentIndexPath];
    }];
    _currentIndexPath = currentIndexPath;
    [self buildAndDisplayCurrentItemAtIndexPath:currentIndexPath];
    [self updateUIForSelectionChange];
    [self configuePlaylistForIndexPath:currentIndexPath];
    [self performSafe:@selector(currentPlayingIndexPathDidChange:) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener currentPlayingIndexPathDidChange:currentIndexPath];
    }];
}
- (void)setPlan:(PCOPlan *)plan {
    _plan = plan;
    _items = nil;
    [[LoopingPlaylistManager sharedPlaylistManager] setPlan:plan];
}

// MARK: - Plan
- (void)planUpdated {
    
}

// MARK: - Music
- (void)configuePlaylistForIndexPath:(NSIndexPath *)indexPath {
    if ([self isLogoIndexPath:indexPath]) {
        [[ProjectorMusicPlayer sharedPlayer] stopPlaylist];
        return;
    }
    if (![self isValidIndexPath:indexPath]) {
        return;
    }
    if ([self isSlideIndexPath:indexPath] && ![self isLiveIndexPath:indexPath]) {
        PCOItem *item = self.items[indexPath.section];
        NSNumber *playlistID = [[LoopingPlaylistManager sharedPlaylistManager] getLoopingPlaylistIDForItem:item];
        if (playlistID && [playlistID intValue] != 0 && [[LoopingPlaylistManager sharedPlaylistManager] getLoopingStateForItem:item]) {
            [[ProjectorMusicPlayer sharedPlayer] startPlaylist:playlistID];
        }
        else {
            [[ProjectorMusicPlayer sharedPlayer] stopPlaylist];
        }
    }
    else if (indexPath == nil || indexPath.section == PROLogoDisplayItemSectionIndex) {
        [[ProjectorMusicPlayer sharedPlayer] stopPlaylist];
    }
}

// MARK: - Item Cache
- (NSString *)_displayItemCacheKeyForIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"%@_%li_%li",self.plan.remoteId,(long)indexPath.section,(long)indexPath.row];
}
- (NSCache *)itemCache {
    if (!_itemCache) {
        _itemCache = [[NSCache alloc] init];
    }
    return _itemCache;
}
- (PRODisplayItem *)newDisplayItemForIndexPath:(NSIndexPath *)indexPath {
    PRODisplayItem *item = [[PRODisplayItem alloc] init];
    item.indexPath = indexPath;
    
    return item;
}

- (PCOItem *)itemForIndexPath:(NSIndexPath *)indexPath {
    return self.items[indexPath.section];
}

// MARK: - Lazy Loaders
- (PROBlackItem *)blackItem {
    if (!_blackItem) {
        _blackItem = [[PROBlackItem alloc] init];
    }
    return _blackItem;
}
- (PROEndOfPlanItem *)endOfPlanItem {
    if (!_endOfPlanItem) {
        _endOfPlanItem = [[PROEndOfPlanItem alloc] init];
    }
    return _endOfPlanItem;
}

- (NSArray *)items {
    if (!_items) {
        _itemCache = nil;
        _items = [self.plan orderedItems];
    }
    return _items;
}

// MARK: - Helper
- (void)performSafe:(SEL)checkSelector forListners:(void(^)(id<PROContainerViewControllerEventListener> listener))perform {
    for (id<PROContainerViewControllerEventListener>listner in [self.delegate allEventListeners]) {
        if (checkSelector == NULL) {
            perform(listner);
        } else if ([listner respondsToSelector:checkSelector]) {
            perform(listner);
        }
    }
}

- (void)reloadGridInterface {
    [self reloadGridInterfaceForItem:nil];
}

- (void)reloadGridInterfaceForAttachmentID:(NSNotification *)notif {
    self.items = nil;
    NSManagedObjectID *attachmentID = [notif object];
    OptiEventLog(@"reloadGridInterfaceForAttachmentID: %@", attachmentID);
    PCOAttachment *attachment = [[PCOCoreDataManager sharedManager] objectWithID:attachmentID];
    NSArray *itemIndexes = [[PROSlideManager sharedManager] sectionsUsingAttachmentId:attachment.attachmentId];
    for (NSNumber *index in itemIndexes) {
        [self.delegate shouldReloadGridInterfaceForSection:[index integerValue]];
    }
    
}

- (void)reloadGridInterfaceForItem:(PCOItem *)item {
    self.items = nil;
    if (item) {
        [[PROSlideManager sharedManager] emptyCacheOfItem:item];
    }
    else {
        [[PROSlideManager sharedManager] emptyCache];
    }
    
    [self performSafe:@selector(userInterfaceWillRefresh) forListners:^(id<PROContainerViewControllerEventListener> listener) {
        [listener userInterfaceWillRefresh];
    }];
    
    // We have to do these crazy checks;  If a user is playing the last item in the plan, deletes that item and pulls to refresh the app crashes
    if (self.currentIndexPath && ![self.items hasObjectForIndex:self.currentIndexPath.section] && self.currentIndexPath.section != PROLogoDisplayItemSectionIndex) {
        self.currentIndexPath = nil;
    } else {
        [self buildAndDisplayCurrentItemAtIndexPath:self.currentIndexPath];
    }
    if (self.nextIndexPath && ![self.items hasObjectForIndex:self.nextIndexPath.section] && self.nextIndexPath.section != PROLogoDisplayItemSectionIndex) {
        self.nextIndexPath = nil;
    } else {
        [self buildAndDisplayUpNextItemAtIndexPath:self.nextIndexPath];
    }
    
    if (item) {
        [self.delegate shouldReloadGridInterfaceForSection:[[self.plan orderedItems] indexOfObject:item]];
    }
    else {
        [self.delegate shouldReloadGridInterface];
    }
}

- (void)fastReloadGridInterface {
    self.items = nil;
    [self.delegate shouldFastRefreshGridInterface];
}
- (void)reloadGridSectionInterface:(NSNotification *)notif {
    self.items = nil;
    NSInteger section = [[notif.userInfo objectForKey:@"section"] integerValue];
    [self.delegate shouldReloadGridInterfaceForSection:section];
}
- (void)hardResetInterface {
    self.items = nil;
    _currentIndexPath = nil;
    _nextIndexPath = nil;
    [self reloadGridInterface];
    
    [self buildAndDisplayCurrentItemAtIndexPath:nil];
    [self buildAndDisplayCurrentItemAtIndexPath:nil];
}

- (NSString *)buildConfidenceString:(NSString *)lyric {
    if (lyric && ![lyric isEqualToString:@""]) {
        return [NSString stringWithFormat:@"------\n%@", lyric];
    }
    return nil;
}

// MARK: - Counts
- (NSInteger)numberOfSections {
    NSInteger count = [self numberOfItems];
    if ([self isLiveCurrentlyEnabled]) {
        count += 1;
    }
    return count;
}

- (NSInteger)numberOfItems {
    return self.items.count;
}

// MARK: - Notification handlers
- (void)refreshGridAndDisplaysForItem:(NSNotification *)notif {
    self.items = nil;
    NSManagedObjectID *objectId = [notif object];
    PCOItem *changedItem = [[PCOCoreDataManager sharedManager] objectWithID:objectId];
    
    if ([self.items containsObject:changedItem]) {
        NSInteger section = [self.items indexOfObject:changedItem];
        [self.delegate shouldReloadGridInterfaceForSection:section];
        
        if (self.currentIndexPath.section == section) {
            [self buildAndDisplayCurrentItemAtIndexPath:self.currentIndexPath];
        }
        if (self.nextIndexPath.section == section) {
            [self buildAndDisplayUpNextItemAtIndexPath:self.nextIndexPath];
        }
    }
}

- (void)P2PSessionConnectionChangedNotification :(NSNotification *)notif {
    self.items = nil;
    [self buildAndDisplayCurrentItemAtIndexPath:self.currentIndexPath];
    [self buildAndDisplayUpNextItemAtIndexPath:self.nextIndexPath];
    [self.delegate shouldReloadGridInterface];
}

- (void)refreshDisplays:(NSNotification *)notif {
    [self buildAndDisplayCurrentItemAtIndexPath:self.currentIndexPath];
    [self buildAndDisplayUpNextItemAtIndexPath:self.nextIndexPath];
}
- (void)applicationDidEnterBackground:(NSNotification *)notif {
    [self setCurrentToBlack];
}

// MARK: - Slide
- (PROSlide *)slideForIndexPath:(NSIndexPath *)indexPath {
    return [[PROSlideManager sharedManager] slideForIndexPath:indexPath];
}


// MARK: - Index Path Helpers

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    NSInteger count = [[[PROSlideManager sharedManager] slideItemForSection:section] count];
    if (count == 0 && [self isLiveCurrentlyEnabled] && section == (NSInteger)[self liveSectionIndex]) {
        return 1;
    }
    if (count == 0 && section < (NSInteger)[self.items count]) {
        PCOItem *item = [self.items objectAtIndex:section];
        if (![item isTypeHeader]) {
            NSInteger nextSection = section + 1;
            
            if (nextSection < (NSInteger)[self.items count]) {
                PCOItem *nextItem = [self.items objectAtIndex:nextSection];
                if ([nextItem isTypeHeader]) {
                    nextSection += 1;
                }
            }

            if (nextSection < (NSInteger)[self.items count]) {
                if ([[[PROSlideManager sharedManager] slideItemForSection:nextSection] count] > 0 || [self isLiveCurrentlyEnabled]) {
                    count = 1;
                }
            }
            else {
                count = 1;
            }
        }
    }
    return count;
}

- (NSIndexPath *)firstValidIndexPathForPlan {
    for (NSInteger section = 0; section < [self.delegate numberOfSections]; section++) {
        if ([self numberOfItemsInSection:section] > 0) {
            return [NSIndexPath indexPathForRow:0 inSection:section];
        }
    }
    return nil;
}
- (NSIndexPath *)nextValidIndexPathAfterIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    
    if ([self isLiveIndexPath:indexPath]) {
            return nil;
    }
    
    PCOItem *planItem = [self itemForIndexPath:indexPath];
    if (![planItem.looping boolValue]) {
        if ([self numberOfItemsInSection:indexPath.section] > indexPath.row + 1) {
            return [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        }
    }
    NSInteger nextSection = indexPath.section + 1;
    while (nextSection < [self.delegate numberOfSections]) {
        if ([self numberOfItemsInSection:nextSection] > 0) {
            return [NSIndexPath indexPathForRow:0 inSection:nextSection];
        }
        nextSection++;
    }
    
    return nil;
}

- (NSIndexPath *)previousValidIndexPathBeforeIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    NSIndexPath *newIndex = nil;
    NSInteger newSection = 0;
    NSInteger newRow = 0;
    
    if ([self isSlideIndexPath:indexPath]) {
        newSection = indexPath.section;
        newRow = indexPath.row - 1;
        while (newRow < 0) {
            newSection--;
            if (newSection < 0) {
                return newIndex;
            }
            else {
                newRow = [self numberOfItemsInSection:newSection] - 1;
            }
        }
        newIndex = [NSIndexPath indexPathForRow:newRow inSection:newSection];
    }
    if ([self isValidIndexPath:newIndex]) {
        return newIndex;
    }
    
    return nil;
}

- (BOOL)isValidIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= [self.delegate numberOfSections]) {
        return NO;
    }
    if (indexPath.row >= [self numberOfItemsInSection:indexPath.section]) {
        return NO;
    }
    return YES;
}
- (BOOL)isSlideIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return NO;
    }
    if (indexPath.section == PROLogoDisplayItemSectionIndex) {
        return NO;
    }
    return YES;
}
- (BOOL)isBackScreenIndexPath:(NSIndexPath *)indexPath {
    return (indexPath == nil);
}
- (BOOL)isLogoIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return NO;
    }
    if (indexPath.section != PROLogoDisplayItemSectionIndex) {
        return NO;
    }
    return YES;
}
- (BOOL)isLiveIndexPath:(NSIndexPath *)indexPath {
    if ([self isLiveCurrentlyEnabled] && indexPath.section == (NSInteger)[self liveSectionIndex]) {
        return YES;
    }
    return NO;
}

// MARK: - Live
- (BOOL)isLiveCurrentlyEnabled {
    if ([[ProjectorP2P_SessionManager sharedManager] isConnectedClient] || [[ProjectorP2P_SessionManager sharedManager] isServer]) {
        return [[PCOLiveController sharedController] isLiveActive];
    }
    return NO;
}
- (NSUInteger)liveSectionIndex {
    return self.items.count;
}

// MARK: - Looping

- (void)controlLoopingForCurrentItem:(PRODisplayItem *)currentItem {
    if ([self isSlideIndexPath:currentItem.indexPath]) {
        if (currentItem.indexPath.section < (NSInteger)[[self.plan orderedItems] count]) {
            PCOItem *planItem = [[self.plan orderedItems] objectAtIndex:currentItem.indexPath.section];
            [[LoopingPlaylistManager sharedPlaylistManager] setCurrentlyPlayingItem:planItem];
            NSArray *items = [self.plan orderedItems];
            if (![[P2P_SessionManager sharedManager] isConnectedClient] && items.count > 0 && (NSInteger)items.count > currentItem.indexPath.section) {
                NSArray *customSlides = [planItem orderedCustomSlides];
                
                PROSlide *slide = [[PROSlideManager sharedManager] slideForIndexPath:currentItem.indexPath];
                NSInteger orderPosition = slide.orderPosition;
                
                if ([customSlides count] > 0) {
                    PCOCustomSlide *slide = [[customSlides filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"order == %@",@(orderPosition)]] lastObject];
                    if ([slide.selectedBackgroundAttachment.linkedObjectType isEqualToString:@"Media"]) {
                        NSNumber *linkedObjectId = slide.selectedBackgroundAttachment.linkedObjectId;
                        if (linkedObjectId) {
                            PCOPlanItemMedia *media = [[[planItem orderedPlanItemMedias] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"media.remoteId == %@", linkedObjectId]] lastObject];
                            if (media && ([media.media.type isEqualToString:@"Video"] || [media.media.type isEqualToString:@"Countdown"])) {
                                return;
                            }
                            else {
                                [[LoopingPlaylistManager sharedPlaylistManager] startLoopingTimerForItem:planItem];
                            }
                        }
                    }
                }
                [[LoopingPlaylistManager sharedPlaylistManager] startLoopingTimerForItem:planItem];
            }
        }
    }
}

@end

NSInteger const PlanGridHelperLiveSectionCount = 1;
