//
//  CapitalizedTableviewHeaderView.h
//  Projector
//
//  Created by Peter Fokos on 10/10/14.
//

#import <UIKit/UIKit.h>

@interface CapitalizedTableviewHeaderView : UIView

@property (weak, nonatomic) PCOLabel *titleLabel;

- (void)capitalizedTitle:(NSString *)title;
+ (CGFloat)heightForView;

@end
