/*!
 * PlanViewMobileGridViewCollectionViewCell.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/4/14
 */

#ifndef Projector_PlanViewMobileGridViewCollectionViewCell_h
#define Projector_PlanViewMobileGridViewCollectionViewCell_h

#import "PCOCollectionViewCell.h"

@class PROSlide;

@interface PlanViewMobileGridViewCollectionViewCell : PCOCollectionViewCell

@property (nonatomic, strong) PROSlide *slide;

@end

PCO_EXTERN_STRING PlanViewMobileGridViewCollectionViewCellIdentifier;

PCO_EXTERN CGFloat const PlanViewMobileGridViewCollectionViewCellBottomBarHeight;

#endif
