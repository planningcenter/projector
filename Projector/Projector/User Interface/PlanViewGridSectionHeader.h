/*!
 * PlanViewGridSectionHeader.h
 *
 *
 * Created by Skylar Schipper on 3/17/14
 */

#ifndef PlanViewGridSectionHeader_h
#define PlanViewGridSectionHeader_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PlanViewGridSectionState) {
    PlanViewGridSectionStateOff     = 0,
    PlanViewGridSectionStateNext    = 1,
    PlanViewGridSectionStateCurrent = 2
};

@interface PlanViewGridSectionHeaderView : PCOView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, weak) PCOButton *lyricsButton;
@property (nonatomic, weak) PCOButton *settingsButton;

@property (nonatomic) NSUInteger section;
@property (nonatomic) PlanViewGridSectionState state;

@property (nonatomic, weak) PCOLabel *titleLabel;

@property (nonatomic, weak) UIImageView *loopingIcon;

@end

@interface PlanViewGridSectionHeader : UICollectionReusableView

@property (nonatomic, weak) PlanViewGridSectionHeaderView *view;

+ (Class)headerViewClass;

@end
@interface PlanViewGridSectionMobileHeader : UITableViewHeaderFooterView

@property (nonatomic, weak) PlanViewGridSectionHeaderView *view;

+ (Class)headerViewClass;

@end

#endif
