//
//  MusicPlayer.m
//  Projector
//
//  Created by Peter Fokos on 4/25/12.
//

#import "ProjectorMusicPlayer.h"
#import <AVFoundation/AVFoundation.h>

#define PRO_MAX_VOLUME 1.0
#define PRO_MIN_VOLUME 0.0

#define FADE_DURATION 0.25
#define FADE_GRANULARITY (FADE_DURATION / 20)
#define FADE_DELTA (PRO_MAX_VOLUME / (FADE_DURATION / FADE_GRANULARITY))

static ProjectorMusicPlayer * sharedMusicPlayer = nil;

@interface ProjectorMusicPlayer () {
    NSInteger playingItemIndex;
    MPMediaPlaylist *currenPlaylist;
}

@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic, strong) NSNumber *currentPlaylistId;

@end

@implementation ProjectorMusicPlayer

- (void)startPlaylist:(NSNumber *)playlistID {
    // if already playing this song then return
    if ([self isSamePlaylistId:playlistID] && [self isMusicPlaying]) return;
    
    // if same song was paused then restart it
    if ([self isSamePlaylistId:playlistID] && ![self isMusicPlaying])
    {
        [self.audioPlayer play];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSUInteger playlistIndex = [[self getAllPlaylists] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *persistentID = [obj valueForProperty: MPMediaPlaylistPropertyPersistentID];
        if (!persistentID) {
            return NO;
        }
        return [persistentID isEqualToNumber:playlistID];
    }];
    
    if (playlistIndex != NSNotFound) {
        MPMediaPlaylist *playlist = [[self getAllPlaylists] objectAtIndex:playlistIndex];
        self.currentPlaylistId = playlistID;
        currenPlaylist = playlist;
        playingItemIndex = -1;
        [self AVPlayerItemDidPlayToEndTimeNotification:nil];
    }
    else {
        NSLog(@"Could not find the playlist");
    }
}

- (void)fadeOutAudioAndStartURL:(NSURL *)assetURL {
    self.audioPlayer.volume -= FADE_DELTA;
    if (self.audioPlayer.volume < PRO_MIN_VOLUME) {
        [self.audioPlayer pause];
        self.audioPlayer.volume = PRO_MAX_VOLUME;
        if (assetURL) {
            [self startPlayingURL:assetURL];
        }
    }
    else {
        [self performSelector:@selector(fadeOutAudioAndStartURL:) withObject:assetURL afterDelay:FADE_GRANULARITY inModes:@[NSRunLoopCommonModes]];
    }
}

- (void)startPlayingURL:(NSURL *)assetURL {
    if (assetURL) {
        AVPlayerItem *playlistItem = [AVPlayerItem playerItemWithURL:assetURL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:playlistItem];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playlistItem];
        [self.audioPlayer play];
    }
}

- (void)AVPlayerItemDidPlayToEndTimeNotification:(NSNotification *) notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (currenPlaylist) {
        NSArray *songs = [currenPlaylist items];
        if ([songs count] > 0) {
            
            NSURL *assetURL = nil;
            NSInteger numberOfItems = [songs count];
            NSInteger itemsChecked = 0;
            
            while (!assetURL && itemsChecked < numberOfItems) {
                playingItemIndex++;
                if (playingItemIndex >= numberOfItems) {
                    playingItemIndex = 0;
                }
                MPMediaItem *mediaItem = [songs objectAtIndex:playingItemIndex];
                assetURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
                if (!assetURL) {
//                    NSLog(@"Missing: %@", [mediaItem valueForProperty:MPMediaItemPropertyTitle]);
                }
                else {
//                    NSLog(@"Found: %@", [mediaItem valueForProperty:MPMediaItemPropertyTitle]);
                }
                itemsChecked++;
            }
            if (assetURL) {
                if ([self isMusicPlaying]) {
                    [self fadeOutAudioAndStartURL:assetURL];
                }
                else {
                    [self startPlayingURL:assetURL];
                }

            }
            else {
                NSLog(@"ERROR could not find any assets for this playlist");
            }
        }
    }
}

- (void)stopPlaylist {
    if (self.currentPlaylistId && ![self.currentPlaylistId isEqualToNumber:@(0)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self fadeOutAudioAndStartURL:nil];
        self.currentPlaylistId = nil;
    }
}

- (BOOL)isMusicPlaying {
    if (self.audioPlayer.rate > 0.0) {
        return YES;
    }
    return NO;
}

- (BOOL)isSamePlaylistId:(NSNumber *)playlistID {
    if (_currentPlaylistId && playlistID) {
        if ([self.currentPlaylistId isEqualToNumber:playlistID]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)getAllPlaylists {
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    return [query collections];
}

- (AVPlayer *)audioPlayer {
    if (!_audioPlayer) {
        self.audioPlayer = [[AVPlayer alloc] init];
        self.audioPlayer.volume = 1.0;
    }
    return _audioPlayer;
}

#pragma mark - Setup Methods

- (id)init {
	if ((self = [super init]))
	{

	}
    return self;
}

#pragma mark - Singleton implementation


+ (ProjectorMusicPlayer *)sharedPlayer {
	@synchronized (self) {
		if (sharedMusicPlayer == nil) {
			sharedMusicPlayer = [[self alloc] init];
		}
	}
	
	return sharedMusicPlayer;
}


+ (id)allocWithZone:(NSZone *)zone {
	@synchronized (self) {
		if (sharedMusicPlayer == nil) {
			sharedMusicPlayer = [super allocWithZone:zone];
			return sharedMusicPlayer;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}




@end
