//
//  CreateSessionTableViewHeaderView.h
//  Projector
//
//  Created by Peter Fokos on 6/19/14.
//

#import <UIKit/UIKit.h>

@class ConnectToSessionTableViewHeaderView;

@interface CreateSessionTableViewHeaderView : PCOView

@property (weak, nonatomic) PCOLabel *statusLabel;
@property (weak, nonatomic) PCOLabel *infoLabel;
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) PCOButton *startButton;
@property (weak, nonatomic) PCOButton *infoButton;
@property (weak, nonatomic) ConnectToSessionTableViewHeaderView *titleView;
@property (weak, nonatomic) UIView *bottomStroke;
@property (strong, nonatomic) UIColor *statusColor;

+ (CGFloat)heightForViewWithInfoShowing:(BOOL)showInfo;

@end
