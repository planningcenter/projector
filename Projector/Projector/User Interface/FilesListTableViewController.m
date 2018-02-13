/*!
 * FilesListTableViewController.m
 *
 *
 * Created by Skylar Schipper on 3/31/14
 */


#import <MCTFileDownloader/MCTFileDownloader.h>

#import "MCTDataStore.h"

#import "FilesListTableViewController.h"
#import "PROSlideManager.h"
#import "FilesListTableViewBaseCell.h"
#import "PROSidebarDetailsCell.h"
#import "FileInfoViewController.h"
#import "PRONavigationController.h"
#import "PROSlideshow.h"

typedef NS_ENUM(NSInteger, FilesListTableViewControllerSections) {
    FilesListTableViewControllerDownloadSection  = 0,
    FilesListTableViewControllerSlideshowSection = 1,
    FilesListTableViewControllerFilesSection     = 2,
    FilesListTableViewControllerSections_Count   = 3,
};

@interface FilesListTableViewController () <UIPopoverPresentationControllerDelegate, FileInfoViewControllerDelegate, MCTFDDownloaderObserver>

@property (nonatomic, strong) NSMutableArray *downloads;
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, strong) NSArray *slideshows;

@end

@implementation FilesListTableViewController

- (void)loadView {
    [super loadView];
    self.title = NSLocalizedString(@"Files", nil);
    [self.navigationController setNavigationBarHidden:YES];
    
    welf();
    [[NSNotificationCenter defaultCenter] addObserverForName:MCTDataStoreDidSaveFileNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [welf reloadTableView];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MCTDataStoreDidDeleteFileNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [welf reloadTableView];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PROSlideshowChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [welf reloadTableView];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:PROSlideshowStatusChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [welf reloadTableView];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[PRODownloader sharedDownloader] addObserver:self];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[PRODownloader sharedDownloader] removeObserver:self];
    
    [self.downloads removeAllObjects];
    [self.tableView reloadData];
}

// MARK: - Download
- (NSArray *)downloads {
    PCOAssertMainThread();
    
    if (!_downloads) {
        _downloads = [NSMutableArray array];
    }
    return _downloads;
}

// MARK: - Table View
- (void)reloadTableView {
    _files = nil;
    _slideshows = nil;
    [super reloadTableView];
}
- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[PROSidebarDetailsCell class] forCellReuseIdentifier:FilesListTableViewBaseCellIdentifier];
    [tableView registerClass:[FilesListTableViewBaseCell class] forCellReuseIdentifier:FilesListTableViewBaseCellDownloadIdentifier];
}

// MARK: - Lazy Loaders
- (NSArray *)files {
    if (!_files) {
        _files = [[MCTDataStore sharedStore] allFiles];
    }
    return _files;
}
- (NSArray *)slideshows {
    if (!_slideshows) {
        _slideshows = [PROSlideshow allSlideshows];
    }
    return _slideshows;
}

// MARK: - Cell for row
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return FilesListTableViewControllerSections_Count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == FilesListTableViewControllerDownloadSection) {
        return self.downloads.count;
    }
    if (section == FilesListTableViewControllerFilesSection) {
        return self.files.count;;
    }
    if (section == FilesListTableViewControllerSlideshowSection) {
        return self.slideshows.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == FilesListTableViewControllerDownloadSection) {
        FilesListTableViewBaseCell *bCell = [tableView dequeueReusableCellWithIdentifier:FilesListTableViewBaseCellDownloadIdentifier forIndexPath:indexPath];
        bCell.enabled = NO;
        if (![self.downloads hasObjectForIndex:indexPath.row]) {
            return bCell;
        }
        
        PRODownload *download = self.downloads[indexPath.row];
        
        [self configureDownloadCell:bCell download:download];
        
        return bCell;
    }
    
    if (indexPath.section == FilesListTableViewControllerFilesSection) {
        PROSidebarDetailsCell *bCell = [tableView dequeueReusableCellWithIdentifier:FilesListTableViewBaseCellIdentifier forIndexPath:indexPath];
        bCell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        NSDictionary *info = self.files[indexPath.row];
        
        bCell.textLabel.text = info[kMCTDataStoreName];
        
        NSNumber *fileSize = info[kMCTDataStoreFileSize];
        
        if ([fileSize isKindOfClass:[[NSNull null] class]]) {
            fileSize = @(0);
        }
        
        bCell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:[fileSize longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
        
        return bCell;
    }
    
    if (indexPath.section == FilesListTableViewControllerSlideshowSection) {
        PROSidebarDetailsCell *bCell = [tableView dequeueReusableCellWithIdentifier:FilesListTableViewBaseCellIdentifier forIndexPath:indexPath];
        PROSlideshow *slideshow = self.slideshows[indexPath.row];
        
        [self configureSlideshowCell:bCell slideshow:slideshow];
        
        return bCell;
    }
    
    return cell;
}
- (void)configureDownloadCell:(FilesListTableViewBaseCell *)cell download:(PRODownload *)download {
    cell.titleLabel.text = [download localizedDescription];
    cell.subTitleLabel.font = [UIFont defaultFontOfSize_14];
    
    if ([download isWaiting]) {
        cell.subTitleLabel.text = NSLocalizedString(@"Waiting", nil);
        cell.progress = 0.0;
    } else {
        cell.subTitleLabel.text = [download localizedProgress];
        cell.progress = [download progress];
    }
}
- (void)configureSlideshowCell:(PROSidebarDetailsCell *)cell slideshow:(PROSlideshow *)slideshow {
    cell.textLabel.text = slideshow.localizedName;
    
    if (slideshow.status == PROSlideshowStatusConverting) {
        cell.detailTextLabel.text = NSLocalizedString(@"Converting", nil);
    } else if (slideshow.status == PROSlideshowStatusReady) {
        NSString *size = [NSByteCountFormatter stringFromByteCount:[slideshow.fileSize longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%tu slides – %@", nil),[slideshow slideCount],size];
    } else if (slideshow.status == PROSlideshowStatusDownloading) {
        cell.detailTextLabel.text = NSLocalizedString(@"Downloading", nil);
    } else if (slideshow.status == PROSlideshowStatusError) {
        cell.detailTextLabel.text = NSLocalizedString(@"Error", nil);
    } else {
        cell.detailTextLabel.text = NSLocalizedString(@"Unknown", nil);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = [super tableView:tableView heightForHeaderInSection:section];
    if (section == FilesListTableViewControllerDownloadSection && [self tableView:tableView numberOfRowsInSection:section] > 0) {
        return height;
    }
    if (section == FilesListTableViewControllerFilesSection && [self tableView:tableView numberOfRowsInSection:section] > 0) {
        return height;
    }
    if (section == FilesListTableViewControllerSlideshowSection && [self tableView:tableView numberOfRowsInSection:section] > 0) {
        return height;
    }
    return 0.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == FilesListTableViewControllerDownloadSection) {
        return [NSString stringWithFormat:NSLocalizedString(@"DOWNLOADING - %tu", nil),[[PRODownloader sharedDownloader] numberOfActiveDownloads]];
    }
    if (section == FilesListTableViewControllerFilesSection) {
        return NSLocalizedString(@"MEDIA FILES", nil);
    }
    if (section == FilesListTableViewControllerSlideshowSection) {
        return NSLocalizedString(@"SLIDESHOWS", nil);
    }
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == FilesListTableViewControllerFilesSection) {
        return indexPath;
    }
    if (indexPath.section == FilesListTableViewControllerSlideshowSection) {
        return indexPath;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == FilesListTableViewControllerFilesSection) {
        NSDictionary *info = self.files[indexPath.row];
        [self presentFileInfoForCell:[tableView cellForRowAtIndexPath:indexPath] file:info slideshow:nil];
        return;
    }
    if (indexPath.section == FilesListTableViewControllerSlideshowSection) {
        PROSlideshow *show = self.slideshows[indexPath.row];
        [self presentFileInfoForCell:[tableView cellForRowAtIndexPath:indexPath] file:nil slideshow:show];
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

// MARK: - Download Delegate
- (void)downloader:(PRODownloader *)downloader beganDownload:(PRODownload *)download {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downloads addObject:download];
        [self.tableView reloadData];
    });
}
- (void)downloader:(PRODownloader *)downloader finishedDownload:(PRODownload *)download {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downloads removeObject:download];
        [self.tableView reloadData];
    });
}
- (void)downloader:(PRODownloader *)downloader updateDownloadProgress:(PRODownload *)download {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger index = [self.downloads indexOfObject:download];
        if (index == NSNotFound) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:FilesListTableViewControllerDownloadSection];
        FilesListTableViewBaseCell *cell = (FilesListTableViewBaseCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            [self configureDownloadCell:cell download:download];
        }
    });
}

// MARK: - Show File Info
- (void)presentFileInfoForCell:(UITableViewCell *)cell file:(NSDictionary *)fileInfo slideshow:(PROSlideshow *)slideshow {
    if (self.presentedViewController && [self.presentedViewController isKindOfClass:[PRONavigationController class]]) {
        PCONavigationController *nav = (PCONavigationController *)self.presentedViewController;
        if ([nav.topViewController isKindOfClass:[FileInfoViewController class]]) {
            FileInfoViewController *cont = (FileInfoViewController *)nav.topViewController;
            
            if (cont.fileInfo[kMCTDataStoreKey] && [fileInfo[kMCTDataStoreKey] isEqualToString:cont.fileInfo[kMCTDataStoreKey]]) {
                [self dismissViewControllerAnimated:YES completion:nil];
                for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
                return;
            }
            
            cont.fileInfo = fileInfo;
            cont.slideshow = slideshow;
            
            nav.popoverPresentationController.sourceView = cell;
            nav.popoverPresentationController.sourceRect = cell.bounds;
            
            return;
        }
    }
    FileInfoViewController *controller = [[FileInfoViewController alloc] initWithNibName:@"FileInfoViewController" bundle:[NSBundle mainBundle]];
    controller.delegate = self;
    
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:controller];
    
    navigation.modalPresentationStyle = UIModalPresentationPopover;
    navigation.popoverPresentationController.sourceView = cell;
    navigation.popoverPresentationController.sourceRect = cell.bounds;
    navigation.popoverPresentationController.delegate = self;
    
    controller.fileInfo = fileInfo;
    controller.slideshow = slideshow;
    
    void(^present)(void) = ^ {
        [self presentViewController:navigation animated:YES completion:nil];
    };
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            present();
        }];
    } else {
        present();
    }
}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    return YES;
}
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)fileInfoViewController:(FileInfoViewController *)controller shouldDeleteFile:(NSDictionary *)fileInfo {
    if (controller.fileInfo) {
        NSDictionary *userInfo = PCOCocoaNullToNil(fileInfo[kMCTDataStoreUserInfo]);
        if (userInfo[@"thumb"]) {
            NSURL *URL = [NSURL URLWithString:userInfo[@"thumb"]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:URL.path]) {
                [[NSFileManager defaultManager] removeItemAtPath:URL.path error:NULL];
            }
        }
        [[MCTDataStore sharedStore] deleteFileWithName:fileInfo[kMCTDataStoreName] key:fileInfo[kMCTDataStoreKey] error:NULL];
    } else if (controller.slideshow) {
        [controller.slideshow deleteSlideshow:nil];
    }
    
    [[PROSlideManager sharedManager] reloadEssentialBackgroundFiles];
    [[NSNotificationCenter defaultCenter] postNotificationName:FilesListTableViewControllerDidDeleteFileNotification object:fileInfo];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

_PCO_EXTERN_STRING FilesListTableViewControllerDidDeleteFileNotification = @"FilesListTableViewControllerDidDeleteFileNotification";
