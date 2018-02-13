//
//  PlanItemBackgroundChooserViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/8/14.
//

#import <MCTFileDownloader/MCTFileDownloader.h>

#import "PlanItemBackgroundChooserViewController.h"
#import "MediaChooserViewController.h"
#import "PCOAttachment.h"
#import "PCOPlanItemMedia.h"
#import "PCOMedia.h"
#import "PROSlideManager.h"
#import "PlanItemSettingsViewController.h"
#import "MediaSelectedTableviewCell.h"
#import "MediaItemImageProvider.h"
#import "PlanItemEditingController.h"
#import "PROAddBarButtonItem.h"
#import "PCOTopTabViewController.h"
#import "PCOCustomSlide.h"
#import "PCOAttachment+ProjectorAdditions.h"

typedef NS_ENUM(NSInteger, BackgroundChooserSections) {
    BackgroundChooserSectionBlackScreen         = 0,
    BackgroundChooserSectionAttachments         = 1,
    BackgroundChooserSectionMediaAttachments    = 2,
};


@interface PlanItemBackgroundChooserViewController () <PCOTopTabViewControllerDelegate, MCTFDDownloaderObserver>

@property (nonatomic, strong) NSSet *itemAttachments;
@property (nonatomic, strong) NSSet *itemMediaAttachments;

@end

@implementation PlanItemBackgroundChooserViewController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Media", nil);
    [self addBackButtonWithString:NSLocalizedString(@"Settings", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self prepareViewControllerForNavigationItem:self.navigationItem];
    self.tableView.backgroundColor = [UIColor captializedTextHeaderBackgroundColor];
    self.tableView.separatorColor = [UIColor mediaTableViewSeparatorColor];
    _itemAttachments = nil;
    _itemMediaAttachments = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PROSlideManagerDidFinishPlanGenerationNotification:) name:PROSlideManagerDidFinishPlanGenerationNotification object:nil];
    [self reloadTableView];
    
    [[PRODownloader sharedDownloader] addObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[PRODownloader sharedDownloader] removeObserver:self];
}

- (void)prepareViewControllerForNavigationItem:(UINavigationItem *)navigationItem {
    if (navigationItem) {
        navigationItem.rightBarButtonItem = [[PROAddBarButtonItem alloc] initWithTarget:self action:@selector(addButtonAction:)];
    }
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [self.tableView registerClass:[MediaSelectedTableviewCell class] forCellReuseIdentifier:kMediaSelectedTableviewCellIdentifier];
}

- (void)setPicker:(PlanItemBackgroundPickerManager *)picker {
    _picker = picker;
    _itemAttachments = nil;
    _itemMediaAttachments = nil;
    [self reloadTableView];
}

- (NSArray *)sortedItemAttachments {
    NSSortDescriptor * indexSort = [NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES];
    
    return [self.itemAttachments sortedArrayUsingDescriptors:@[indexSort]];
}

- (NSArray *)sortedItemMediaAttachments {
    NSSortDescriptor * indexSort = [NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES];
    
    return [self.itemMediaAttachments sortedArrayUsingDescriptors:@[indexSort]];
}

- (void)PROSlideManagerDidFinishPlanGenerationNotification:(NSNotification *)notif {
    [self reloadTableView];
}

#pragma mark -
#pragma mark - Lazy Loaders

- (NSSet *)itemAttachments {
    if (!_itemAttachments) {
        NSMutableSet *set = [NSMutableSet set];
        for (PCOAttachment *attachment in self.picker.item.attachments) {
            if ([attachment isProjectorAttachment]) {
                [set addObject:attachment];
            }
        }
        [set removeObjectsFromArray:[self.itemMediaAttachments allObjects]];
        _itemAttachments = [set copy];
    }
    return _itemAttachments;
}

- (NSSet *)itemMediaAttachments {
    if (!_itemMediaAttachments) {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        
        for (PCOPlanItemMedia *planItemMedia in [self.picker.item orderedPlanItemMedias]) {
            PCOMedia *media = planItemMedia.media;
            for (PCOAttachment *attachment in [media orderedAttachments]) {
                if ([attachment isProjectorAttachment]) {
                    [set addObject:attachment];
                }
            }
        }
        _itemMediaAttachments = [NSSet setWithSet:set];
    }
    return _itemMediaAttachments;
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    switch (section) {
        case BackgroundChooserSectionAttachments:
            count = [self.itemAttachments count];
            break;
        case BackgroundChooserSectionMediaAttachments:
            count = [self.itemMediaAttachments count];
            break;
        case BackgroundChooserSectionBlackScreen:
            count = 1;
            break;
        default:
            break;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MediaSelectedTableviewCell heightForCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
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
    MediaSelectedTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMediaSelectedTableviewCellIdentifier];
    cell.cellAccessoryType = MediaSelectedAccessoryTypeCheckmark;
    if (indexPath.section != BackgroundChooserSectionBlackScreen) {
        [cell.swipeLeft addTarget:self action:@selector(showDeleteCell:)];
        [cell.swipeRight addTarget:self action:@selector(hideDeleteCell:)];
        cell.deleteButton.tag = indexPath.row;
        [cell.deleteButton addTarget:self action:@selector(deleteSequenceAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    NSString *selectedAttachmentId = self.picker.item.slideBackgroundAttachmentId;
    if (self.picker.slide) {
        selectedAttachmentId = self.picker.slide.backgroundAttachmentId;
    }
    switch (indexPath.section) {
        case BackgroundChooserSectionAttachments: {
            PCOAttachment *attachment = [[self sortedItemAttachments] objectAtIndex:indexPath.row];
            cell.titleLabel.text = attachment.filename;
            cell.showCheckmark = ([selectedAttachmentId isEqualToString:attachment.attachmentId]);
            cell.mediaImage.image = [[PROSlideManager sharedManager] thumbnailForMediaAttachment:attachment];
            break;
        }
        case BackgroundChooserSectionMediaAttachments: {
            PCOAttachment *attachment = [[self sortedItemMediaAttachments] objectAtIndex:indexPath.row];
            cell.titleLabel.text = attachment.filename;
            cell.showCheckmark = ([selectedAttachmentId isEqualToString:attachment.attachmentId]);
            cell.mediaImage.image = [[PROSlideManager sharedManager] thumbnailForMediaAttachment:attachment];
            break;
        }
        case BackgroundChooserSectionBlackScreen: {
            if (self.picker.slide) {
                cell.titleLabel.text = NSLocalizedString(@"Item Background", nil);
                cell.mediaImage.image = [[PROSlideManager sharedManager] thumbnailForMediaAttachment:self.picker.item.slideBackgroundAttachment];
                cell.mediaImage.layer.borderColor = [[UIColor projectorOrangeColor] CGColor];
            } else {
                cell.titleLabel.text = NSLocalizedString(@"None", nil);
            }
            cell.showCheckmark = (selectedAttachmentId == nil);
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PCOAttachment *attachment = nil;
    
    switch (indexPath.section) {
        case BackgroundChooserSectionAttachments:
            attachment = [[self sortedItemAttachments] objectAtIndex:indexPath.row];
            break;
            
        case BackgroundChooserSectionMediaAttachments:
            attachment = [[self sortedItemMediaAttachments] objectAtIndex:indexPath.row];
            break;
            
        case BackgroundChooserSectionBlackScreen:
            attachment = nil;
            break;
        default:
            break;
    }
    
    [self.picker selectAttachment:attachment];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - Actions

- (void)deleteSequenceAction:(PCOButton *)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];

    PCOAttachment * attachment = nil;
    
    if (indexPath.section == BackgroundChooserSectionAttachments) {
        attachment = [[self sortedItemAttachments] objectAtIndex:indexPath.row];
    } else if (indexPath.section == BackgroundChooserSectionMediaAttachments) {
        attachment = [[self sortedItemMediaAttachments] objectAtIndex:indexPath.row];
    }
    
    
    // find media that has the same mediaId as the attachment being deleted
    for (PCOPlanItemMedia *planItemMedia in [self.picker.item orderedPlanItemMedias]) {
        PCOMedia *media = planItemMedia.media;
        if ([media.remoteId isEqualToNumber:attachment.linkedObjectId]) {
            for (PCOAttachment *att in [self.picker.item orderedAttachments]) {
                if ([att.linkedObjectId isEqualToNumber:media.remoteId]) {
                    if (att == self.picker.item.slideBackgroundAttachment) {
                        self.picker.item.slideBackgroundAttachment = nil;
                        self.picker.item.slideBackgroundAttachmentId = nil;
                        [[PROSlideManager sharedManager] emptyCacheOfItem:self.picker.item];
                        [[NSNotificationCenter defaultCenter] postNotificationName:PlanItemBackgroundChangedNotification object:self.picker.item.objectID];
                    }
                    [self.picker.item removeAttachmentsObject:att];
                }
            }
            
            [[[PCOCoreDataManager sharedManager] itemsController] removeMedia:media fromItem:self.picker.item completion:^(NSError *error) {
                if (error) {
                    MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't remove media", nil) message:[error localizedDescription] cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
                    [alertView show];
                } else {
                    _itemAttachments = nil;
                    _itemMediaAttachments = nil;
                    [PCOEventLogger logEvent:@"Media Deleted from Plan Item"];
                    [self.tableView reloadData];
                }
            }];
            return;
        }
    }
    
    // see if this was the selected background
    [self.picker.item removeAttachmentsObject:attachment];
    [self.tableView reloadData];
}

- (void)showDeleteCell:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    MediaSelectedTableviewCell *cell = (MediaSelectedTableviewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell.deleteVisible) {
        [cell toggleDeleteAnimated:YES];
    }
}

- (void)hideDeleteCell:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    MediaSelectedTableviewCell *cell = (MediaSelectedTableviewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.deleteVisible) {
        [cell toggleDeleteAnimated:YES];
    }
}

- (void)addButtonAction:(id)sender {
    [[PlanItemEditingController sharedController] warnIfNotEditorForPlan:self.picker.plan];
    MediaChooserViewController *controller = [[MediaChooserViewController alloc] initWithNibName:nil bundle:nil];
    controller.preferredContentSize = [self preferredContentSize];
    controller.picker = self.picker;
    [self.navigationController pushViewController:controller animated:YES];
}

// MARK: - Download Observer
- (void)downloader:(PRODownloader *)downloader beganDownload:(PRODownload *)download {
    
}
- (void)downloader:(PRODownloader *)downloader finishedDownload:(PRODownload *)download {
    
}
- (void)downloader:(PRODownloader *)downloader updateDownloadProgress:(PRODownload *)download {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = [download localizedDescription];
        if (name) {
            for (MediaSelectedTableviewCell *cell in [self.tableView visibleCells]) {
                if ([cell.titleLabel.text isEqualToString:name]) {
                    cell.progressFraction = [download progress];
                }
            }
        }
    });
}

@end


