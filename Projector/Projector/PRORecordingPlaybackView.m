//
//  PRORecordingPlaybackView.m
//  Projector
//
//  Created by Peter Fokos on 7/2/15.
//

#import "PRORecordingPlaybackView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PRORecordingPlaybackView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (id)initWithPlayer:(AVPlayer *)player {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [(AVPlayerLayer *)[self layer] setPlayer:player];
    }
    return self;
}

- (void)replacePlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}


@end
