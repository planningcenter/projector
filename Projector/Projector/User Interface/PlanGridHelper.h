/*!
 * PlanGridHelper.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/1/14
 */

#ifndef Projector_PlanGridHelper_h
#define Projector_PlanGridHelper_h

@import Foundation;

@class PRODisplayItem;
@class PROLogo;
@class PROSlide;

@protocol PlanGridHelperDelegate;
@protocol PROContainerViewControllerEventListener;

@interface PlanGridHelper : NSObject

@property (nonatomic, strong, readonly) PRODisplayItem *currentItem;
@property (nonatomic, strong, readonly) PRODisplayItem *upNextItem;

@property (nonatomic, strong, readonly) NSIndexPath *currentIndexPath;
@property (nonatomic, strong, readonly) NSIndexPath *nextIndexPath;

@property (nonatomic, assign) id<PlanGridHelperDelegate> delegate;

- (void)updateCurrentIndexPath:(NSIndexPath *)indexPath;
- (void)updateNextIndexPathPath:(NSIndexPath *)indexPath;
- (void)updateNextIndexPath;

- (void)playNextSlide;
- (void)playPreviousSlide;

// MARK: - Show Current Items
- (void)buildAndDisplayCurrentItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)buildAndDisplayUpNextItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)reloadGridInterface;

- (void)updateSelectedIndexPathsForSelection:(NSIndexPath *)indexPath;

// MARK: - Preset Screens
- (void)setCurrentToBlack;
- (void)setNextToBlack;
- (void)setNextToLogo:(PROLogo *)logo;
- (void)setCurrentToLogo:(PROLogo *)logo;
- (void)reloadCurrentWithLogo:(PROLogo *)logo;

// MARK: - Slide
- (PCOItem *)itemForIndexPath:(NSIndexPath *)indexPath;
- (PROSlide *)slideForIndexPath:(NSIndexPath *)indexPath;

// MARK: - Index Path Helpers
- (NSIndexPath *)firstValidIndexPathForPlan;
- (NSIndexPath *)nextValidIndexPathAfterIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)previousValidIndexPathBeforeIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (BOOL)isValidIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isSlideIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isBackScreenIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLogoIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLiveIndexPath:(NSIndexPath *)indexPath;

// MARK: - Live
- (BOOL)isLiveCurrentlyEnabled;
- (NSUInteger)liveSectionIndex;

// MARK: - Looping
- (void)controlLoopingForCurrentItem:(PRODisplayItem *)currentItem;

// MARK: - Plan
@property (nonatomic, weak) PCOPlan *plan;
- (void)planUpdated;

- (void)hardResetInterface;

// MARK: - Counts
- (NSInteger)numberOfItems;

@end

@protocol PlanGridHelperDelegate <NSObject>

@required
- (NSArray *)allEventListeners;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (void)shouldReloadGridInterface;
- (void)shouldReloadGridInterfaceForSection:(NSInteger)section;
- (void)shouldFastRefreshGridInterface;

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)updateCurrentNextIndexPaths;

- (PROLogo *)currentLogo;

@end

FOUNDATION_EXTERN
NSInteger const PlanGridHelperLiveSectionCount;

#endif
