/*!
 * LogoPickerMutipleAttachmentsPickerViewController.m
 *
 *
 * Created by Skylar Schipper on 7/10/14
 */

#import "LogoPickerMutipleAttachmentsPickerViewController.h"
#import "PCOAttachment.h"
#import "MediaSelectedTableviewCell.h"
#import "PROSlideManager.h"
#import "MediaItemImageProvider.h"

@interface LogoPickerMutipleAttachmentsPickerViewController ()

@end

@implementation LogoPickerMutipleAttachmentsPickerViewController

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [super registerCellsForTableView:tableView];
    
    [self.tableView registerClass:[MediaSelectedTableviewCell class] forCellReuseIdentifier:kMediaSelectedTableviewCellIdentifier];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MediaSelectedTableviewCell heightForCell];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.attachments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaSelectedTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMediaSelectedTableviewCellIdentifier forIndexPath:indexPath];
    PCOAttachment *attachment = self.attachments[indexPath.row];
    PCOMedia *media = attachment.media;
    
    cell.accessoryImage.hidden = YES;
    cell.titleLabel.text = [attachment displayFilename];
    
    MediaItemImageProvider *provider = [[MediaItemImageProvider alloc] init];
    provider.media = media;
    [provider getImage:^(NSNumber *remoteID, UIImage *image) {
        MediaSelectedTableviewCell *bCell = (MediaSelectedTableviewCell *)[tableView cellForRowAtIndexPath:indexPath];
        bCell.mediaImage.image = image;
        [bCell setNeedsLayout];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PCOAttachment *attachment = self.attachments[indexPath.row];
    if (self.pickerHandler) {
        self.pickerHandler(attachment, self.selectedMedia);
    }
}

@end
