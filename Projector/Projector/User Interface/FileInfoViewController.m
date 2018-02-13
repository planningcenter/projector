/*!
 * FileInfoViewController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/10/14
 */

#import "FileInfoViewController.h"
#import <MCTDataStore/MCTDataStore.h>
#import "NSString+FileTypeAdditions.h"
#import "PCODateFormatter.h"
#import "PROThumbnailGenerator.h"

typedef NS_ENUM(NSInteger, FileInfoItem) {
    FileInfoItemName     = 0,
    FileInfoItemLastUsed = 1,
    FileInfoItemSize     = 2,
    FileInfoItemCount    = 3
};

@interface FileInfoViewController ()

@property (nonatomic, strong) NSString *tempFilePath;

@end

@implementation FileInfoViewController

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.preferredContentSize = CGSizeMake(320.0, 345.0);
}

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"File Info", nil);
    
    self.view.backgroundColor = [UIColor navigationBarDefaultColor];
    
    self.deleteButton.backgroundColor = [UIColor projectorBlackColor];
    self.deleteButton.titleLabel.font = [UIFont defaultFontOfSize_16];
    [self.deleteButton setTitleColor:HEX(0xC74E3B) forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:HEX(0x6A291F) forState:UIControlStateHighlighted];
    
    self.tableView.backgroundColor = [UIColor navigationBarDefaultColor];
    self.tableView.separatorColor = [UIColor projectorBlackColor];
    self.tableView.layer.borderColor = [[UIColor projectorBlackColor] CGColor];
    self.tableView.layer.borderWidth = 0.5;
    self.tableView.alwaysBounceVertical = NO;
    
    self.tableView.layoutMargins = UIEdgeInsetsZero;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [UIView new];
    [PCOEventLogger logEvent:@"File Info - Show Info"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = HEX(0x1f1f23);
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                    NSFontAttributeName: [UIFont defaultFontOfSize_14]
                                                                    };
    self.navigationController.popoverPresentationController.backgroundColor = self.view.backgroundColor;
    
    [self updateFileInfo];
    [self updateSlideshow];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self clearPath];
}

- (void)updateFileInfo {
    if (_slideshow) {
        return;
    }
    NSURL *fileURL = self.fileInfo[kMCTDataStoreFileURL];
    
    [self.tableView reloadData];
    
    self.thumbnailView.image = nil;
    
    NSString *thumbKEY = PCOCocoaNullToNil(PCOCocoaNullToNil(self.fileInfo[kMCTDataStoreUserInfo])[@"thumb_key"]);
    
    if (thumbKEY) {
        if ([[MCTDataCacheController sharedCache] fileExistsForKey:thumbKEY]) {
            NSError *error = nil;
            fileURL = [[MCTDataCacheController sharedCache] fileURLForKey:thumbKEY error:&error];
            self.thumbnailView.image = [UIImage imageWithContentsOfFile:[fileURL path]];
            return;
        }
    }
    
    
    if ([[fileURL path] isImage]) {
        self.thumbnailView.image = [UIImage imageWithContentsOfFile:[fileURL path]];
    } else if ([[fileURL path] isVideo]) {
        [PROThumbnailGenerator generateVideoThumbnailForFileAtURL:fileURL completion:^(NSURL *image, NSError *err) {
            PCOError(err);
            if (!image) {
                return;
            }
            
            NSString *file = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
            NSString *path = [self.tempFilePath stringByAppendingPathComponent:file];
            if ([[NSFileManager defaultManager] copyItemAtPath:image.path toPath:path error:NULL]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.thumbnailView.image = [UIImage imageWithContentsOfFile:path];
                });
            }
        }];
    }
}
- (void)updateSlideshow {
    if (_fileInfo) {
        return;
    }
    
    [self.tableView reloadData];
    
    NSString *file = [[self.slideshow slideAtIndex:0] path];
    
    self.thumbnailView.image = [UIImage imageWithContentsOfFile:file];
}

- (void)setFileInfo:(NSDictionary *)fileInfo {
    _fileInfo = fileInfo;
    
    [self updateFileInfo];
}

- (void)setSlideshow:(PROSlideshow *)slideshow {
    _slideshow = slideshow;
    
    [self updateSlideshow];
}

// MARK: - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return FileInfoItemCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.backgroundColor = self.view.backgroundColor;
        cell.textLabel.font = [UIFont defaultFontOfSize_12];
        cell.textLabel.textColor = HEX(0xcbcbcb);
        cell.detailTextLabel.font = [UIFont defaultFontOfSize_12];
        cell.detailTextLabel.textColor = HEX(0x666670);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    switch (indexPath.row) {
        case FileInfoItemName: {
            cell.textLabel.text = NSLocalizedString(@"File Name", nil);
            cell.detailTextLabel.text = [self fileName];
            break;
        }
        case FileInfoItemLastUsed: {
            cell.textLabel.text = NSLocalizedString(@"Last Used", nil);
            cell.detailTextLabel.text = [self lastDate];
            break;
        }
        case FileInfoItemSize: {
            cell.textLabel.text = NSLocalizedString(@"File Size", nil);
            cell.detailTextLabel.text = [self fileSize];
            break;
        }
    }
    
    
    return cell;
}

- (NSString *)fileName {
    if (self.fileInfo) {
        return self.fileInfo[kMCTDataStoreName];
    }
    return self.slideshow.localizedName;
}
- (NSString *)lastDate {
    NSDate *date = nil;
    if (self.fileInfo) {
        date = self.fileInfo[kMCTDataStoreLastReadDate];
    } else if (self.slideshow) {
        date = self.slideshow.createdAt;
    }
    return [[PCODateFormatter sharedFormatter] stringFromDate:date format:@"MM/dd/YY"];
}
- (NSString *)fileSize {
    size_t size = 0;
    if (self.fileInfo) {
        NSNumber *fSize = PCOCocoaNullToNil(self.fileInfo[kMCTDataStoreFileSize]);
        size = [fSize unsignedLongValue];
    } else if (self.slideshow) {
        NSNumber *fSize = PCOCocoaNullToNil(self.slideshow.fileSize);
        size = [fSize unsignedLongValue];
    }
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

// MARK: - Delete Action
- (IBAction)deleteButtonAction:(id)sender {
    MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure?", nil) message:NSLocalizedString(@"Do you want to delete this file? If it is used in your plan, it will redownload automatically.", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil)];
    
    [alert addActionWithTitle:NSLocalizedString(@"Delete", nil) handler:^(MCTAlertViewAction *action) {
        if ([self.delegate respondsToSelector:@selector(fileInfoViewController:shouldDeleteFile:)]) {
            [PCOEventLogger logEvent:@"File Info - Delete File"];
            [self.delegate fileInfoViewController:self shouldDeleteFile:self.fileInfo];
        }
    }];
    
    [alert show];
}

// MARK: - Temp Path
- (NSString *)tempFilePath {
    if (!_tempFilePath) {
        _tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"file_view-14231"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_tempFilePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_tempFilePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    }
    return _tempFilePath;
}
- (void)clearPath {
    if (_tempFilePath) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:_tempFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_tempFilePath error:NULL];
            _tempFilePath = nil;
        }
    }
}

@end
