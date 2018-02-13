/*!
 * PlanViewMobileGridTableViewCell.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/3/14
 */

#ifndef Projector_PlanViewMobileGridTableViewCell_h
#define Projector_PlanViewMobileGridTableViewCell_h

#import "PCOTableViewCell.h"
#import "PlanViewMobileGridTableViewCellCollectionViewLayout.h"

@protocol PlanViewMobileGridTableViewCellDelegate;

@interface PlanViewMobileGridTableViewCell : PCOTableViewCell

@property (nonatomic, assign) id<PlanViewMobileGridTableViewCellDelegate> delegate;

@property (nonatomic, weak) UICollectionView *collectionView;

@end



@protocol PlanViewMobileGridTableViewCellDelegate <PlanViewGridCollectionViewLayoutDelegate>

- (NSIndexPath *)indexPathForCell:(PlanViewMobileGridTableViewCell *)cell;

- (NSInteger)numberOfItemsInSection:(NSInteger)section cell:(PlanViewMobileGridTableViewCell *)cell;

- (UICollectionViewCell *)cell:(PlanViewMobileGridTableViewCell *)cell collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath planIndexPath:(NSIndexPath *)planIndexPath;

- (void)cell:(PlanViewMobileGridTableViewCell *)cell finalizeCollectionViewSetup:(UICollectionView *)collectionView;

- (void)cell:(PlanViewMobileGridTableViewCell *)cell didSelectIndexPath:(NSIndexPath *)indexPath;

@end

PCO_EXTERN_STRING PlanViewMobileGridTableViewCellIdentifier;

#endif
