/*!
 * PlanViewGridCollectionViewLayout.h
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#ifndef PlanViewGridCollectionViewLayout_h
#define PlanViewGridCollectionViewLayout_h

#import <UIKit/UIKit.h>

@protocol PlanViewGridCollectionViewLayoutDelegate;

@interface PlanViewGridCollectionViewLayout : UICollectionViewLayout

- (void)selectionChanged;

- (void)invalidateLayoutCache;

@end


@protocol PlanViewGridCollectionViewLayoutDelegate <UICollectionViewDelegate>

- (NSIndexPath *)planLayoutCurrentIndexPath:(UICollectionViewLayout *)layout;
- (NSIndexPath *)planLayoutUpNextIndexPath:(UICollectionViewLayout *)layout;

- (BOOL)itemAtIndexPathConnectsToPrevious:(NSIndexPath *)indexPath;

- (void)gridSizeSettingDidChange;

@optional

- (BOOL)hasLowMemoryWarning;

@end

@interface PlanViewGridCollectionSelectionChangeInvalidationContext : UICollectionViewLayoutInvalidationContext

@end

PCO_EXTERN_STRING PlanViewGridSelectedDecoration;
PCO_EXTERN_STRING PlanViewGridUpNextDecoration;
PCO_EXTERN_STRING PlanViewGridConnectToPreviousDecoration;
PCO_EXTERN_STRING PlanViewGridUpNextPlayDecoration;

UIKIT_EXTERN CGFloat const PlanViewGridPadding;

#endif
