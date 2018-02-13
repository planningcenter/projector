//
//  MediaChooserPlanMediaViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/9/14.
//

#import "MediaChooserPlanMediaViewController.h"
#import "PCOAttachment+ProjectorAdditions.h"
#import "PROSlideManager.h"
#import "PlanItemEditingController.h"
#import "MCTAlertView.h"
#import "PCOCustomSlide.h"

@interface MediaChooserPlanMediaViewController ()

@end

@implementation MediaChooserPlanMediaViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *key = [self attachmentsKeyForIndex:indexPath.section];
    PCOAttachment *attachment = self.attachments[key][indexPath.row];
    
    if (attachment) {
        [self.picker selectAttachment:attachment];
    }
    
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

- (PCOPlan *)plan {
    return self.picker.plan;
}

@end
