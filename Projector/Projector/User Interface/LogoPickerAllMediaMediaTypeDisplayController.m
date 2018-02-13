/*!
 * LogoPickerAllMediaMediaTypeDisplayController.m
 *
 *
 * Created by Skylar Schipper on 7/7/14
 */

#import "LogoPickerAllMediaMediaTypeDisplayController.h"
#import "LogoPickerMutipleAttachmentsPickerViewController.h"

#import "PCOMedia.h"
#import "PCOAttachment.h"
#import "MediaItemImageProvider.h"
#import "MediaSelectedTableviewCell.h"
#import "PROSlideManager.h"

#import "PROLogo.h"

@interface _LogoPickerMediaDisplayCellInternal : LogoPickerMediaDisplayCell

@end

static NSString *const _LogoPickerMediaDisplayCellInternalIdentifier = @"_LogoPickerMediaDisplayCellInternalIdentifier";

@interface LogoPickerAllMediaMediaTypeDisplayController () <PCOTableViewPullToRefreshDelegate>

@property (nonatomic, strong) NSString *searchString;

@end

@implementation LogoPickerAllMediaMediaTypeDisplayController

- (void)finishTableViewSetup:(PCOTableView *)tableView {
    [super finishTableViewSetup:tableView];
    
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.refreshDelegate = self;
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [super registerCellsForTableView:tableView];
    
    [self.tableView registerClass:[MediaSelectedTableviewCell class] forCellReuseIdentifier:kMediaSelectedTableviewCellIdentifier];
}

- (void)setMediaType:(PCOMediaType *)mediaType {
    _mediaType = mediaType;
    
    self.title = [mediaType localizedDescription];
    
    [self reloadTableView];
    
    
    if (self.media.count == 0) {
        [self.tableView beginRefreshing];
    }
}

- (void)reloadTableView {
    _media = nil;
    [super reloadTableView];
}

- (NSArray *)media {
    if (!_media) {
        NSArray *array = [[[[PCOCoreDataManager sharedManager] mediaController] orderedMediaForType:self.mediaType] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if (![evaluatedObject isKindOfClass:[PCOMedia class]]) {
                return NO;
            }
            return [[self class] hasCompatibleAttachments:[(NSSet * )[evaluatedObject attachments] allObjects]];
        }]];
        
        if (self.searchString.length > 0.0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@",self.searchString];
            array = [array filteredArrayUsingPredicate:predicate];
        }
        
        _media = array;
    }
    return _media;
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
#pragma mark - Table View
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
    return self.media.count;
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
    MediaSelectedTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMediaSelectedTableviewCellIdentifier forIndexPath:indexPath];
    PCOMedia *media = self.media[indexPath.row];

    cell.titleLabel.text = [media localizedDescription];
    cell.tag = [media.remoteId integerValue];
    
    NSArray *attachments = [[media orderedAttachments] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type IN %@",[[self class] compatibleAttachmentTypes]]];
    
    cell.accessoryImage.hidden = NO;
    if (attachments.count == 1) {
        cell.accessoryImage.hidden = YES;
    }

    
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
    PCOMedia *media = self.media[indexPath.row];

    NSArray *attachments = [[media orderedAttachments] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type IN %@",[[self class] compatibleAttachmentTypes]]];
    
    if (attachments.count > 1) {
        [self presentAttachemntsPicker:attachments];
    } else if (attachments.count == 1) {
        [self makeNewLogoFromAttachment:[attachments firstObject]];
    }
}

#pragma mark -
#pragma mark - Picker
- (void)presentAttachemntsPicker:(NSArray *)attachements {
    LogoPickerMutipleAttachmentsPickerViewController *picker = [[LogoPickerMutipleAttachmentsPickerViewController alloc] initWithNibName:nil bundle:nil];
    picker.title = NSLocalizedString(@"Attachments", nil);
    picker.attachments = attachements;
    picker.preferredContentSize = self.preferredContentSize;
    
    welf();
    picker.pickerHandler = ^(PCOAttachment *attachment, PCOMedia *selectedMedia) {
        [welf makeNewLogoFromAttachment:attachment];
    };
    
    [self.navigationController pushViewController:picker animated:YES];
}
- (void)makeNewLogoFromAttachment:(PCOAttachment *)attachment {
    [PCOEventLogger logEvent:@"Add Logo"];
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

#pragma mark -
#pragma mark - Table View Refresh
- (void)tableViewShouldBeginRefresh:(PCOTableView *)tableView {
    [[[PCOCoreDataManager sharedManager] mediaController] updateMediaForType:self.mediaType completion:^(BOOL success, NSManagedObjectID *typeID) {
        [self reloadTableView];
        [tableView endRefreshing];
    }];
}

+ (NSSet *)compatibleAttachmentTypes {
    static NSSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSSet setWithObjects:kPCOAttachmentTypeS3, kPCOAttachmentTypeLink, nil];
    });
    return set;
}
+ (BOOL)hasCompatibleAttachments:(NSArray *)array {
    NSSet *set = [self compatibleAttachmentTypes];
    for (PCOAttachment *attachment in array) {
        if ([set containsObject:attachment.type]) {
            return YES;
        }
    }
    return NO;
}

@end



@implementation _LogoPickerMediaDisplayCellInternal

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.imageView.contentMode = UIViewContentModeProjectorPreferred;
    self.imageView.backgroundColor = [UIColor blackColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat aspect = ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]);
    
    self.imageView.frame = ({
        CGRect frame = CGRectZero;
        
        frame.size.height = CGRectGetHeight(self.contentView.bounds);
        frame.size.width = CGRectGetHeight(frame) * aspect;
        
        CGRectIntegral(frame);
    });
    
    self.textLabel.frame = ({
        CGRect frame = self.textLabel.frame;
        frame.origin.x = CGRectGetMaxX(self.imageView.frame) + 6.0;
        frame.size.width = CGRectGetWidth(self.contentView.frame) - CGRectGetMinX(frame);
        frame;
    });
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.imageView.backgroundColor = [UIColor blackColor];
}

@end
