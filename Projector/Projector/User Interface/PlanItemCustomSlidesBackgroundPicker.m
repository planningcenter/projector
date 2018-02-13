/*!
 * PlanItemCustomSlidesBackgroundPicker.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 2/23/15
 */

#import "PlanItemCustomSlidesBackgroundPicker.h"
#import "PCOReorderTableView.h"
#import "MediaSelectedTableviewCell.h"
#import "PlanItemBackgroundChooserViewController.h"
#import "PROSlideHelper.h"
#import "PROSlideManager.h"
#import "CapitalizedTableviewHeaderView.h"

typedef NS_ENUM(NSInteger, PlanItemCustomSlidesSection) {
    PlanItemCustomSlidesSectionItem   = 0,
    PlanItemCustomSlidesSectionSlides = 1,
    PlanItemCustomSlidesSection_Count = 2
};

@interface PlanItemCustomSlidesBackgroundPicker () <PCOReorderTableViewDelegate>

@property (nonatomic, assign) BOOL didShowPicker;

@end

@implementation PlanItemCustomSlidesBackgroundPicker

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.picker.slide isNew] && self.picker.slide.label.length == 0) {
        [self deleteSlide:self.picker.slide];
    }
    
    self.picker.slide = nil;
    
    [self reloadTableView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.picker.item.attachments.count == 0 && !self.didShowPicker) {
        [self presentItemPickerViewController];
    }
}

// MARK: - Actions
- (void)addCustomSlideButtonAction:(id)sender {
    PCOCustomSlide *slide = [PCOCustomSlide object];
    slide.enabled = @YES;
    slide.order = @([[[[self.picker.item orderedCustomSlides] lastObject] order] integerValue] + 1);
    [self.picker.item addCustomSlidesObject:slide];
    
    [[PCOCoreDataManager sharedManager] save:NULL];
    
    [self showPickerForSlide:slide];
}

// MARK: - Helpers
- (void)showPickerForSlide:(PCOCustomSlide *)slide {
    self.picker.slide = slide;
    
    PlanItemBackgroundChooserViewController *viewController = [[PlanItemBackgroundChooserViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.picker = self.picker;
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void)deleteSlide:(PCOCustomSlide *)slide {
    NSNumber *itemID = slide.item.remoteId;
    
    [slide.item removeCustomSlidesObject:slide];
    
    [self reloadTableView];
    
    [[PCOCoreDataManager sharedManager] save:NULL];
    [[PROSlideManager sharedManager] emptyCacheOfItem:slide.item];
    
    if ([slide isNew]) {
        return;
    }
    [PROSlideHelper deleteCustomSlide:slide.remoteId itemID:itemID completion:^(NSError *error) {
        if (error) {
            [MCTAlertView showError:error];
        }
    }];
}
- (void)presentItemPickerViewController {
    self.picker.slide = nil;
    PlanItemBackgroundChooserViewController *viewController = [[PlanItemBackgroundChooserViewController alloc] initWithStyle:UITableViewStylePlain];
    viewController.picker = self.picker;
    [self.navigationController pushViewController:viewController animated:YES];
    self.didShowPicker = YES;
}

// MARK: - Tableview Setup
+ (Class)tableViewClass {
    return [PCOReorderTableView class];
}
- (void)finishTableViewSetup:(PCOTableView *)tableView {
    if ([tableView isKindOfClass:[PCOReorderTableView class]]) {
        [((PCOReorderTableView *)tableView) setReorderDelegate:self];
    }
    tableView.backgroundColor = [UIColor projectorBlackColor];
    tableView.separatorColor = HEX(0x0E0E10);
}
- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[MediaSelectedTableviewCell class] forCellReuseIdentifier:kMediaSelectedTableviewCellIdentifier];
}

// MARK: - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return PlanItemCustomSlidesSection_Count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == PlanItemCustomSlidesSectionItem) {
        return 1;
    }
    if (section == PlanItemCustomSlidesSectionSlides) {
        return self.picker.item.customSlides.count;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MediaSelectedTableviewCell heightForCell];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaSelectedTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMediaSelectedTableviewCellIdentifier forIndexPath:indexPath];
    cell.mediaImage.layer.borderWidth = 0.0;
    cell.mediaImage.layer.borderColor = [[UIColor projectorOrangeColor] CGColor];
    
    if (indexPath.section == PlanItemCustomSlidesSectionItem) {
        PCOAttachment *attachment = self.picker.item.slideBackgroundAttachment;
        if (attachment) {
            cell.titleLabel.text = [attachment displayFilename];
        } else {
            cell.titleLabel.text = NSLocalizedString(@"None", nil);
        }
        
        cell.mediaImage.image = [[PROSlideManager sharedManager] thumbnailForMediaAttachment:attachment];
        cell.mediaImage.layer.borderWidth = 2.0;
    } else if (indexPath.section == PlanItemCustomSlidesSectionSlides) {
        PCOCustomSlide *slide = [self.picker.item orderedCustomSlides][indexPath.row];
        
        cell.titleLabel.text = [slide localizedDescription];
        
        PCOAttachment *attachment = [slide selectedBackgroundAttachment];
        if (attachment) {
            cell.mediaImage.image = [[PROSlideManager sharedManager] thumbnailForMediaAttachment:attachment];
        }
        
        if (slide.backgroundAttachmentId == nil) {
            cell.mediaImage.layer.borderWidth = 2.0;
        }
    }
    
    
    if ([tableView isKindOfClass:[PCOReorderTableView class]]) {
        PCOReorderTableView *rTableView = (PCOReorderTableView *)tableView;
        if ([rTableView.dropIndexPath isEqual:indexPath]) {
            cell.alpha = 0.0;
            return [rTableView newDropCell];
        }
    }
    
    return cell;
}

// MARK: - Delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PlanItemCustomSlidesSectionSlides) {
        return [self.picker.plan canEdit];
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PlanItemCustomSlidesSectionSlides) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            PCOCustomSlide *slide = [self.picker.item orderedCustomSlides][indexPath.row];
            if (slide.body.length == 0) {
                [self deleteSlide:slide];
            } else {
                MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Slide", nil) message:NSLocalizedString(@"This slide contains text.  Are you sure you want to delete it?", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil)];
                
                [alert addActionWithTitle:NSLocalizedString(@"Delete", nil) handler:^(MCTAlertViewAction *action) {
                    [self deleteSlide:slide];
                }];
                
                [alert show];
            }
        }
    }
}

// MARK: - Table View header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == PlanItemCustomSlidesSectionItem) {
        return NSLocalizedString(@"Item Background", nil);
    }
    if (section == PlanItemCustomSlidesSectionSlides) {
        return NSLocalizedString(@"Custom Slides", nil);
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [CapitalizedTableviewHeaderView heightForView];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CapitalizedTableviewHeaderView *view = [[CapitalizedTableviewHeaderView alloc] init];
    [view capitalizedTitle:[tableView.dataSource tableView:tableView titleForHeaderInSection:section]];
    return view;
}

// MARK: - Table view footer
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == PlanItemCustomSlidesSectionSlides) {
        return 40.0;
    }
    return 0.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    PCOButton *button = [[PCOButton alloc] initWithFrame:CGRectZero];
    [button setBackgroundColor:HEX(0x181819) forState:UIControlStateNormal];
    [button setBackgroundColor:HEX(0x141416) forState:UIControlStateHighlighted];
    [button setTitle:NSLocalizedString(@"+ Add Slide", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addCustomSlideButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    button.titleLabel.font = [UIFont defaultFontOfSize_14];
    
    return button;
}

// MARK: - Select
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (indexPath.section == PlanItemCustomSlidesSectionItem) {
        [self presentItemPickerViewController];
    } else {
        PCOCustomSlide *slide = [self.picker.item orderedCustomSlides][indexPath.row];
        [self showPickerForSlide:slide];
    }
}

// MARK: - Reorder
- (BOOL)reorderTableView:(PCOReorderTableView *)tableView shouldReorderItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PlanItemCustomSlidesSectionSlides) {
        return [self.picker.plan canEdit];
    }
    return NO;
}
- (NSIndexPath *)reorderTableView:(PCOReorderTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (sourceIndexPath.section == proposedDestinationIndexPath.section) {
        return proposedDestinationIndexPath;
    }
    return nil;
}
- (void)reorderTableView:(PCOReorderTableView *)tableView moveFromFromIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.row == destinationIndexPath.row) {
        return;
    }
    if (sourceIndexPath.section != PlanItemCustomSlidesSectionSlides || destinationIndexPath.section != PlanItemCustomSlidesSectionSlides) {
        return;
    }
    
    NSMutableArray *reorderArray = [[self.picker.item orderedCustomSlides] mutableCopy];
    
    [self.picker.item clearOrderCache];
    
    PCOCustomSlide *movingSlide = [reorderArray objectAtIndex:sourceIndexPath.row];
    [reorderArray removeObjectAtIndex:sourceIndexPath.row];
    [reorderArray insertObject:movingSlide atIndex:destinationIndexPath.row];
    
    NSUInteger order = 1;
    for (PCOCustomSlide * slide in reorderArray) {
        slide.order = @(order);
        order++;
    }
    
    [[PCOCoreDataManager sharedManager] save:NULL];
    
    [[PROSlideManager sharedManager] emptyCacheOfItem:self.picker.item];
    
    [PROSlideHelper saveCustomSlideOrder:self.picker.item completion:^(NSError *error) {
        PCOError(error);
    }];
    
    [self reloadTableView];
}

@end
