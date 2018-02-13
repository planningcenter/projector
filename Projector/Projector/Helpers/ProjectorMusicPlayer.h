//
//  MusicPlayer.h
//  Projector
//
//  Created by Peter Fokos on 4/25/12.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol MusicPlayerDelegate


@end

@interface ProjectorMusicPlayer : NSObject

@property (nonatomic, strong) id<MusicPlayerDelegate> delegate;

- (NSArray *)getAllPlaylists;
- (void)startPlaylist:(NSNumber *)playlistID;
- (void)stopPlaylist;

// global class methods
+ (ProjectorMusicPlayer *)sharedPlayer;

@end
