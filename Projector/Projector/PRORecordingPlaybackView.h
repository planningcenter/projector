//
//  PRORecordingPlaybackView.h
//  Projector
//
//  Created by Peter Fokos on 7/2/15.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface PRORecordingPlaybackView : UIView

- (instancetype)initWithPlayer:(AVPlayer *)player;
- (AVPlayer*)player;
- (void)replacePlayer:(AVPlayer *)player;

@end
