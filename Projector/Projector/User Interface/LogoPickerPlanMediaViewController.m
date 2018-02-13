/*!
 * LogoPickerPlanMediaViewController.m
 *
 *
 * Created by Skylar Schipper on 6/30/14
 */

#import "LogoPickerPlanMediaViewController.h"

#import "PCOPlanItemMedia.h"
#import "PCOAttachment.h"
#import "PCOArrangement.h"
#import "PCOKey.h"
#import "PCOSong.h"

#import "PROLogo.h"

@interface LogoPickerPlanMediaViewController ()

@property (nonatomic, strong) NSString *searchString;

@end

@implementation LogoPickerPlanMediaViewController

- (void)reloadTableView {
    _attachments = nil;
    [super reloadTableView];
}

- (NSDictionary *)attachments {
    if (!_attachments) {
        NSMutableDictionary *media = [NSMutableDictionary dictionaryWithCapacity:100];
        NSPredicate *predicate = nil;
        if (self.searchString.length > 0) {
           predicate = [NSPredicate predicateWithFormat:@"filename CONTAINS[cd] %@",self.searchString];
        }
        for (PCOItem *item in self.plan.items) {
            NSMutableSet *set = [NSMutableSet setWithCapacity:100];
            NSString *key = [item localizedDescription];
            if (!key) {
                continue;
            }
            [set addObjectsFromArray:[item imageAttachments]];
            [set addObjectsFromArray:[item videoAttachments]];
            [set addObjectsFromArray:[item slideshowAttachments]];
            [set addObjectsFromArray:[item pdfAttachments]];
            [set addObjectsFromArray:[item audioAttachments]];
            
            [set addObjectsFromArray:[item.song imageAttachments]];
            [set addObjectsFromArray:[item.song videoAttachments]];
            [set addObjectsFromArray:[item.song pdfAttachments]];
            [set addObjectsFromArray:[item.song audioAttachments]];
            
            [set addObjectsFromArray:[item.arrangement imageAttachments]];
            [set addObjectsFromArray:[item.arrangement videoAttachments]];
            [set addObjectsFromArray:[item.arrangement pdfAttachments]];
            [set addObjectsFromArray:[item.arrangement audioAttachments]];
            
            if (set.count > 0) {
                NSArray *all = [set allObjects];
                
                if (predicate) {
                    all = [all filteredArrayUsingPredicate:predicate];
                }
                
                if (all.count > 0) {
                    media[key] = [all sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES selector:@selector(caseInsensitiveCompare:)]]];
                }
            }
        }
        _attachments = [media copy];
    }
    return _attachments;
}

- (NSString *)attachmentsKeyForIndex:(NSInteger)index {
    return [[self.attachments allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)][index];
}

- (BOOL)showSearchBar {
    return YES;
}

- (void)updateSearchString:(NSString *)searchString final:(BOOL)final {
    self.searchString = searchString;
}
- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    [self reloadTableView];
}

#pragma mark -
#pragma mark - Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.attachments.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self attachmentsKeyForIndex:section];
    return [self.attachments[key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self attachmentsKeyForIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogoPickerMediaDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:LogoPickerMediaDisplayCellIdentifier forIndexPath:indexPath];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    NSString *key = [self attachmentsKeyForIndex:indexPath.section];
    PCOAttachment *attachment = self.attachments[key][indexPath.row];
    
    cell.textLabel.text = [attachment displayFilename];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self attachmentsKeyForIndex:indexPath.section];
    PCOAttachment *attachment = self.attachments[key][indexPath.row];
    
    PROLogo *logo = [[PROLogo alloc] init];
    logo.attachmentID = attachment.attachmentId;
    logo.localizedName = [attachment displayFilenameByRemovingExtention];
    logo.fileName = [logo.UUID stringByAppendingPathExtension:([attachment.filename pathExtension]) ?: @"dat"];
    
    PROLogoThumbnailGenerator generator = PROLogoThumbnailGeneratorUseFile;
    if ([attachment isVideo]) {
        generator = PROLogoThumbnailGeneratorVideo;
    }
    
    [logo downloadFileFromURL:[NSURL URLWithString:attachment.url] mimeType:attachment.contentType thumbnailGenerator:generator];
    
    NSError *error = nil;
    if (![logo save:&error]) {
        PCOError(error);
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
