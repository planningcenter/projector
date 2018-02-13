//
//  LoopingPlaylistChooserViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/8/14.
//

#import "LoopingPlaylistChooserViewController.h"
#import "ProjectorMusicPlayer.h"
#import "LoopingPlaylistManager.h"
#import "MediaPlaylistTableviewCell.h"

@interface LoopingPlaylistChooserViewController ()

@end

@implementation LoopingPlaylistChooserViewController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Playlists", nil);
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [self.tableView registerClass:[MediaPlaylistTableviewCell class] forCellReuseIdentifier:kMediaPlaylistTableviewCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.backgroundColor = [UIColor captializedTextHeaderBackgroundColor];
    self.tableView.separatorColor = [UIColor mediaTableViewSeparatorColor];
    [self reloadTableView];
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[[ProjectorMusicPlayer sharedPlayer] getAllPlaylists] count] + 1;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MediaPlaylistTableviewCell heightForCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaPlaylistTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMediaPlaylistTableviewCellIdentifier];
    cell.cellAccessoryType = MediaPlaylistAccessoryTypeCheckmark;
    
    NSNumber *persistentID = [NSNumber numberWithUnsignedLongLong:0];
    
    if (indexPath.row == 0)
    {
        cell.titleLabel.text = @"No Playlist";
        cell.subTitleLabel.text = nil;
    }
    else {
        NSArray *allPlaylists = [[ProjectorMusicPlayer sharedPlayer] getAllPlaylists];
        MPMediaPlaylist *playlist = [allPlaylists objectAtIndex:indexPath.row-1];
        persistentID = [playlist valueForProperty: MPMediaPlaylistPropertyPersistentID];
        
        cell.titleLabel.text = [[allPlaylists objectAtIndex:indexPath.row-1] valueForProperty:MPMediaPlaylistPropertyName];
        NSString *songsString = [NSString stringWithFormat:@"%lu items", (unsigned long)[[[allPlaylists objectAtIndex:indexPath.row-1] items] count]];
        cell.subTitleLabel.text = songsString;
        
        MPMediaItem *representativeItem = [[allPlaylists objectAtIndex:indexPath.row-1] representativeItem];
        MPMediaItemArtwork *artwork = [representativeItem valueForProperty: MPMediaItemPropertyArtwork];
        UIImage *artworkImage = [artwork imageWithSize: cell.imageView.bounds.size];
        cell.mediaImage.image = artworkImage;
    }

    cell.showCheckmark = NO;
    if ([[[LoopingPlaylistManager sharedPlaylistManager] getLoopingPlaylistIDForItem:self.selectedItem] isEqualToNumber:persistentID])
    {
        cell.showCheckmark = YES;
    }
    
    return cell;
}

#pragma mark -
#pragma mark - Actions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNumber *persistentID = [NSNumber numberWithUnsignedLongLong:0];
    
    if (indexPath.row > 0) {
        NSArray *allPlaylists = [[ProjectorMusicPlayer sharedPlayer] getAllPlaylists];
        MPMediaPlaylist *playlist = [allPlaylists objectAtIndex:indexPath.row-1];
        persistentID = [playlist valueForProperty: MPMediaPlaylistPropertyPersistentID];
        if (![self validatePlaylist:playlist]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Oops", nil) message:NSLocalizedString(@"Projector doesn't have access to this playlist.  Please try another.", nil) preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }

    if (![[[LoopingPlaylistManager sharedPlaylistManager] getLoopingPlaylistIDForItem:self.selectedItem] isEqualToNumber:persistentID])
    {
        [[LoopingPlaylistManager sharedPlaylistManager] saveLoopingPlaylistID:persistentID forItem:self.selectedItem];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PlanItemLooping_PlaylistChanged_Notification object:self.selectedItem];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)validatePlaylist:(MPMediaPlaylist *)playlist {
    BOOL __block hasFile = NO;
    [playlist.items enumerateObjectsUsingBlock:^(MPMediaItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // This playlist has audio we can play
        if (obj.assetURL) {
            if (stop != NULL) {
                *stop = YES;
            }
            hasFile = YES;
        }
    }];
    return hasFile;
}

@end


