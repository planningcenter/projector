//
//  AvailableSessionTableViewCell.h
//  Projector
//
//  Created by Peter Fokos on 6/19/14.
//

#import "PCOTableViewCell.h"
#import "ProjectorP2P_SessionManager.h"

@interface AvailableSessionTableViewCell : PCOTableViewCell

@property (nonatomic) BOOL connected;
@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) PCOButton *cloudButton;
@property (weak, nonatomic) PCOButton *mirrorButton;
@property (weak, nonatomic) PCOButton *confidenceButton;
@property (weak, nonatomic) PCOButton *noLyricsButton;
@property (weak, nonatomic) UILabel *mirrorLabel;
@property (weak, nonatomic) UILabel *confidenceLabel;
@property (weak, nonatomic) UILabel *noLyricsLabel;
@property (weak, nonatomic) UIView *midStroke;
@property (nonatomic) P2PClientMode clientMode;

+ (CGFloat)heightForCellConnected:(BOOL)connected;

@end
