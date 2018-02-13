/*!
 * MCTTooltip.h
 * MCTTooltop
 *
 *
 * Created by Skylar Schipper on 11/20/14
 */

#ifndef MCTTooltop_MCTTooltip_h
#define MCTTooltop_MCTTooltip_h

@import UIKit;

@interface MCTTooltip : UIControl

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) UIFont *infoFont;

@property (nonatomic, readonly, getter=isTooltipShowing) BOOL tooltipShowing;
- (void)showTooltipAnimated:(BOOL)flag completion:(void(^)(void))completion;
- (void)hideTooltipAnimated:(BOOL)flag completion:(void(^)(void))completion;

@property (nonatomic, assign) CGSize preferredTooltipSize;

- (void)configureMessageLabel:(void(^)(UILabel *label))block;
- (void)configurePopupView:(void(^)(UIView *view))block;

@property (nonatomic, strong) UIColor *closeIconColor;

@end

@interface MCTTooltip (SubclassingHooks)

- (void)willConfigureMessageLabel:(UILabel *)label;
- (void)willConfigurePopupView:(UIView *)view;

@end

#endif
