//
//  MediaChooserAllMediaMediaTypeDisplayController.m
//  Projector
//
//  Created by Peter Fokos on 10/9/14.
//

#import "MediaChooserAllMediaMediaTypeDisplayController.h"
#import "PCOMedia.h"
#import "PCOAttachment+ProjectorAdditions.h"
#import "LogoPickerMutipleAttachmentsPickerViewController.h"
#import "LogoPickerAllMediaMediaTypeDisplayController.h"
#import "PROSlideManager.h"
#import "PlanItemEditingController.h"
#import "PCOPlanItemMedia.h"
#import "MCTAlertView.h"
#import "PCOCustomSlide.h"

@interface MediaChooserAllMediaMediaTypeDisplayController ()

@end

@implementation MediaChooserAllMediaMediaTypeDisplayController

- (void)loadView {
    [super loadView];
    [self addBackButtonWithString:NSLocalizedString(@"Add", nil)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOMedia *media = self.media[indexPath.row];
    NSArray *attachments = [[media orderedAttachments] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type IN %@",[LogoPickerAllMediaMediaTypeDisplayController compatibleAttachmentTypes]]];
    
    if (attachments.count > 1) {
        [self presentAttachemntsPicker:attachments selectedMedia:media];
    } else if (attachments.count == 1) {
        [self newMediaAdded:media newAttachment:[attachments firstObject]];
    }
}



#pragma mark -
#pragma mark - Picker
- (void)presentAttachemntsPicker:(NSArray *)attachements selectedMedia:(PCOMedia *)selectedMedia {
    LogoPickerMutipleAttachmentsPickerViewController *picker = [[LogoPickerMutipleAttachmentsPickerViewController alloc] initWithNibName:nil bundle:nil];
    picker.title = NSLocalizedString(@"Attachments", nil);
    picker.attachments = attachements;
    picker.selectedMedia = selectedMedia;
    picker.preferredContentSize = self.preferredContentSize;
    
    welf();
    picker.pickerHandler = ^(PCOAttachment *attachment, PCOMedia *selectedMedia) {
        [welf newMediaAdded:selectedMedia newAttachment:attachment];
    };

    [self.navigationController pushViewController:picker animated:YES];
}

- (void)newMediaAdded:(PCOMedia *)media newAttachment:(PCOAttachment *)attachment {
    if (media) {
        BOOL duplicate = [[self.picker.item.planItemMedias valueForKeyPath:@"media.remoteId"] containsObject:media.remoteId];
        
        if (attachment) {
            [self.picker selectAttachment:attachment];
        }
        
        if (!duplicate) {
            [[PlanItemEditingController sharedController] addMedia:media toItem:self.picker.item inPlan:self.picker.plan];
        }
    } else if (attachment) {
        [self.picker.item addAttachmentsObject:attachment];
        [self.picker selectAttachment:attachment];
    }
 
    [[PROSlideManager sharedManager] addMediaAttachment:attachment toItem:self.picker.item];

    [[PlanItemEditingController sharedController] saveBackgroundEditingChangesForItem:self.picker.item inPlan:self.picker.plan];
    
    [[PROSlideManager sharedManager] emptyCacheOfItem:self.picker.item];
    
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

@end
