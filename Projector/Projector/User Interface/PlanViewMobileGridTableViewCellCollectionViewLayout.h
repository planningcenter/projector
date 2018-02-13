/*!
 * PlanViewMobileGridTableViewCellCollectionViewLayout.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/4/14
 */

#ifndef Projector_PlanViewMobileGridTableViewCellCollectionViewLayout_h
#define Projector_PlanViewMobileGridTableViewCellCollectionViewLayout_h

@import UIKit;

#import "PlanViewGridCollectionViewLayout.h"

@interface PlanViewMobileGridTableViewCellCollectionViewLayout : UICollectionViewLayout

- (void)selectionChanged;

- (void)invalidateLayoutCache;

@end

@protocol PlanViewMobileGridTableViewCellCollectionViewLayoutDelegate <PlanViewGridCollectionViewLayoutDelegate>

- (BOOL)isPlanIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView;

@end

#endif
