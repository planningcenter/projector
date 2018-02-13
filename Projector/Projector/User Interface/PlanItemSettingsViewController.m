//
//  PlanItemSettingsViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/8/14.
//

#import <MCTFileDownloader/MCTFileDownloader.h>

#import "PlanItemSettingsViewController.h"
#import "PlanItemBackgroundChooserViewController.h"
#import "PCOAttachment+ProjectorAdditions.h"
#import "PCOSlideLayout.h"
#import "LoopingPlaylistManager.h"
#import "ProjectorMusicPlayer.h"
#import "LoopingPlaylistChooserViewController.h"
#import "PlanItemLayoutChooserTableViewController.h"
#import "LoopingTimeStepperTableViewCell.h"
#import "CapitalizedTableviewHeaderView.h"
#import "PRONavigationController.h"
#import "MediaSelectedTableviewCell.h"
#import "MediaItemImageProvider.h"
#import "MediaSwitchTableViewCell.h"
#import "MediaPlaylistTableviewCell.h"
#import "PROSlideManager.h"
#import "PROSwitch.h"
#import "LayoutPreviewTableViewCell.h"
#import "PlanItemBackgroundPickerManager.h"
#import "PlanItemCustomSlidesBackgroundPicker.h"

#define DEFAULT_SECONDS 10

typedef NS_ENUM(NSInteger, PlanItemSettingsSections) {
    PlanItemSettingsSectionBackground   = 0,
    PlanItemSettingsSectionLayout       = 1,
    PlanItemSettingsSectionLooping      = 2,
};

@interface PlanItemSettingsViewController () <MCTFDDownloaderObserver>

@property (nonatomic, assign) NSInteger secondsPerSlide;

@end

@implementation PlanItemSettingsViewController

- (void)loadView {
    [super loadView];
    self.title = NSLocalizedString(@"Settings", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PRONavigationController *proNav = (PRONavigationController *)[self navigationController];
    proNav.navigationBar.barTintColor = [UIColor layoutControllerToolbarBackgroundColor];
    self.tableView.backgroundColor = [UIColor captializedTextHeaderBackgroundColor];
    self.tableView.separatorColor = [UIColor mediaTableViewSeparatorColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PROSlideManagerDidFinishPlanGenerationNotification:) name:PROSlideManagerDidFinishPlanGenerationNotification object:nil];
    [self reloadTableView];
    [self updateLoopingTime];
    
    [[PRODownloader sharedDownloader] addObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[PRODownloader sharedDownloader] removeObserver:self];
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [self.tableView registerClass:[MediaSelectedTableviewCell class] forCellReuseIdentifier:kMediaSelectedTableviewCellIdentifier];
    [self.tableView registerClass:[MediaSwitchTableViewCell class] forCellReuseIdentifier:kMediaSwitchTableviewCellIdentifier];
    [self.tableView registerClass:[LoopingTimeStepperTableViewCell class] forCellReuseIdentifier:kLoopingTimeStepperTableViewCellIdentifier];
    [self.tableView registerClass:[MediaPlaylistTableviewCell class] forCellReuseIdentifier:kMediaPlaylistTableviewCellIdentifier];
    [self.tableView registerClass:[LayoutPreviewTableViewCell class] forCellReuseIdentifier:kLayoutPreviewTableViewCellIdentifier];
}

- (void)setSelectedItem:(PCOItem *)selectedItem {
    _selectedItem = selectedItem;
    NSInteger seconds = [[LoopingPlaylistManager sharedPlaylistManager] getLoopingSecondsForItem:self.selectedItem];
    if (seconds == 0) {
        seconds = DEFAULT_SECONDS;
        [[LoopingPlaylistManager sharedPlaylistManager] saveLoopingSeconds:seconds forItem:self.selectedItem];
    }
    self.secondsPerSlide = seconds;
}

- (void)updateLoopingTime {
    if ([self.selectedItem.looping boolValue]) {
        [[LoopingPlaylistManager sharedPlaylistManager] saveLoopingSeconds:self.secondsPerSlide forItem:self.selectedItem];
        [self performSelector:@selector(updateLoopingTime) withObject:nil afterDelay:1.0];
    }
}

- (void)PROSlideManagerDidFinishPlanGenerationNotification:(NSNotification *)notif {
    [self reloadTableView];
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == PlanItemSettingsSectionLooping) {
        if ([self.selectedItem.looping boolValue]) {
            return 3;
        }
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    switch (indexPath.section) {
        case PlanItemSettingsSectionBackground:
            height = [MediaSelectedTableviewCell heightForCell];
            break;
            
        case PlanItemSettingsSectionLayout:
            height = [MediaSelectedTableviewCell heightForCell];
            break;
            
        case PlanItemSettingsSectionLooping:
        {
            switch (indexPath.row) {
                case 0:
                    height = [MediaSwitchTableViewCell heightForCell];
                    break;
                    
                case 1:
                    height = 50;
                    break;
                case 2:
                    height = 65;
                    break;
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [CapitalizedTableviewHeaderView heightForView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    PCOTableViewCell *cell = [[PCOTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = @"";
    cell.backgroundColor = [UIColor redColor];

    switch (indexPath.section) {
        case PlanItemSettingsSectionBackground:
        {
            MediaSelectedTableviewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kMediaSelectedTableviewCellIdentifier];

            PCOAttachment *attachment = [self.selectedItem currentSelectedSlideBackgroundAttachment];
            if (attachment) {
                aCell.titleLabel.text = [attachment displayFilename];
            } else {
                aCell.titleLabel.text = NSLocalizedString(@"None", nil);
            }
            
            aCell.mediaImage.image = [[PROSlideManager sharedManager] thumbnailForMediaAttachment:attachment];

            cell = aCell;
            break;
        }
        case PlanItemSettingsSectionLayout:
        {
            PCOSlideLayout * selectedLayout = nil;
            
            selectedLayout = self.selectedItem.selectedSlideLayout;
            
            if (self.selectedItem.selectedSlideLayoutId)
            {
                PCOSlideLayout * aLayout = [PCOSlideLayout findFirstByAttribute:@"layoutId" withValue:self.selectedItem.selectedSlideLayoutId inContext:[self.selectedItem managedObjectContext]];
                if (aLayout)
                {
                    selectedLayout = aLayout;
                }
            }
            
            if (selectedLayout == nil) {
                
                selectedLayout = [[[PCOCoreDataManager sharedManager] layoutsController] defaultLayout];
            }
            LayoutPreviewTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kLayoutPreviewTableViewCellIdentifier];

            aCell.titleLabel.text = [selectedLayout name];
            aCell.subTitleLabel.text = [selectedLayout layoutDescription];
            aCell.layout = selectedLayout;
            cell = aCell;
            break;
        }
        case PlanItemSettingsSectionLooping:
        {
            switch (indexPath.row) {
                case 0:
                {
                    MediaSwitchTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kMediaSwitchTableviewCellIdentifier];
                    aCell.titleLabel.text = NSLocalizedString(@"Looping", nil);
                    aCell.mediaSwitch.on = [self.selectedItem.looping boolValue];
                    [aCell.mediaSwitch addTarget:self action:@selector(mediaSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                    cell = aCell;
                   break;
                }
                case 1:
                {
                    LoopingTimeStepperTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kLoopingTimeStepperTableViewCellIdentifier];
                    NSString *secondString = NSLocalizedString(@"Seconds Each", nil);
                    if (self.secondsPerSlide == 1) {
                        secondString = NSLocalizedString(@"Second Each", nil);
                    }
                    aCell.titleLabel.text = [NSString stringWithFormat:@"%td %@", self.secondsPerSlide, secondString];
                    aCell.stepperControl.value = self.secondsPerSlide;
                    [aCell.stepperControl addTarget:self action:@selector(timeStepperValueDidChange:) forControlEvents:UIControlEventValueChanged];
                    cell = aCell;
                    break;
                }
                case 2:
                {
                    MediaPlaylistTableviewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kMediaPlaylistTableviewCellIdentifier];

                    aCell.titleLabel.text = @"No playlist";
                    NSNumber *playlistID = [[LoopingPlaylistManager sharedPlaylistManager] getLoopingPlaylistIDForItem:self.selectedItem];
                    UIImage *artworkImage = nil;
                    
                    if (playlistID && [playlistID intValue] != 0)
                    {
                        for ( MPMediaPlaylist *playlist in [[ProjectorMusicPlayer sharedPlayer] getAllPlaylists] )
                        {
                            NSNumber *persistentID = [playlist valueForProperty:MPMediaPlaylistPropertyPersistentID];
                            
                            if ([persistentID isEqualToNumber:playlistID]) {
                                
                                aCell.titleLabel.text = [playlist valueForProperty:MPMediaPlaylistPropertyName];
                                NSString *songsString = [NSString stringWithFormat:@"%lu items", (unsigned long)[[playlist items] count]];
                                aCell.subTitleLabel.text = songsString;
                                
                                MPMediaItem *representativeItem = [playlist representativeItem];
                                MPMediaItemArtwork *artwork = [representativeItem valueForProperty: MPMediaItemPropertyArtwork];
                                artworkImage = [artwork imageWithSize:CGSizeMake(200, 200)];
                                aCell.mediaImage.image = artworkImage;
                                break;
                            }
                        }
                    }
                    else {
                        aCell.titleLabel.text = @"No Playlist";
                        aCell.subTitleLabel.text = @"";
                        aCell.mediaImage.image = nil;
                    }
                    [aCell setNeedsUpdateConstraints];

                    cell = aCell;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.plan loadServiceTypeIfNeeded];

    switch (indexPath.section) {
        case PlanItemSettingsSectionBackground: {
            PlanItemBackgroundPickerManager *picker = [[PlanItemBackgroundPickerManager alloc] init];
            picker.plan = self.plan;
            picker.item = self.selectedItem;
            if ([self.selectedItem isTypeSong]) {
                PlanItemBackgroundChooserViewController *viewController = [[PlanItemBackgroundChooserViewController alloc] initWithStyle:UITableViewStylePlain];
                viewController.picker = picker;
                [self.navigationController pushViewController:viewController animated:YES];
            } else {
                PlanItemCustomSlidesBackgroundPicker *controller = [[PlanItemCustomSlidesBackgroundPicker alloc] initWithStyle:UITableViewStylePlain];
                controller.picker = picker;
                [self.navigationController pushViewController:controller animated:YES];
            }
            break;
        }
        case PlanItemSettingsSectionLayout: {
            PlanItemLayoutChooserTableViewController *viewController = [[PlanItemLayoutChooserTableViewController alloc] initWithNibName:nil bundle:nil];
            viewController.serviceType = self.plan.serviceType;
            viewController.selectedItem = self.selectedItem;
            viewController.plan = self.plan;
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case PlanItemSettingsSectionLooping: {
            if (indexPath.row == 2) {
                LoopingPlaylistChooserViewController *viewController = [[LoopingPlaylistChooserViewController alloc] initWithNibName:nil bundle:nil];
                viewController.selectedItem = self.selectedItem;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark - Actions

- (void)timeStepperValueDidChange:(UIStepper*)stepper {
    if (stepper.value < 1) {
        stepper.value = 1;
    }
    else if (stepper.value > 999) {
        stepper.value = 999;
    }
    self.secondsPerSlide = stepper.value;
    [self.tableView reloadData];
}

- (void)mediaSwitchValueChanged:(PROSwitch *)mediaSwitch {
    [[LoopingPlaylistManager sharedPlaylistManager] saveLoopingState:mediaSwitch.on forItem:self.selectedItem];
    if (mediaSwitch.on) {
        [self updateLoopingTime];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)downloader:(PRODownloader *)downloader beganDownload:(PRODownload *)download {
    
}
- (void)downloader:(PRODownloader *)downloader finishedDownload:(PRODownload *)download {
    
}
- (void)downloader:(PRODownloader *)downloader updateDownloadProgress:(PRODownload *)download {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = [download localizedDescription];
        if (!name) {
            return;
        }
        for (UITableViewCell *cell in [self.tableView visibleCells]) {
            if ([cell isKindOfClass:[MediaSelectedTableviewCell class]]) {
                MediaSelectedTableviewCell *mCell = (MediaSelectedTableviewCell *)cell;
                if ([mCell.titleLabel.text isEqualToString:name]) {
                    mCell.progressFraction = [download progress];
                }
                
            }
        }
    });
}

#pragma mark -
#pragma mark - Headers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case PlanItemSettingsSectionBackground:
            return NSLocalizedString(@"Selected Background", nil);

        case PlanItemSettingsSectionLayout:
            return NSLocalizedString(@"Selected Layout", nil);

        case PlanItemSettingsSectionLooping:
            return NSLocalizedString(@"Slide Looping", nil);

        default:
            break;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CapitalizedTableviewHeaderView *view = [[CapitalizedTableviewHeaderView alloc] init];
    [view capitalizedTitle:[self tableView:tableView titleForHeaderInSection:section]];
    return view;
}

@end


