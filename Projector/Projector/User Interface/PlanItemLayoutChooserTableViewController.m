//
//  PlanItemLayoutChooserTableViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/10/14.
//

#import "PlanItemLayoutChooserTableViewController.h"
#import "PROSlideManager.h"
#import "PCOSlideLayout.h"
#import "PlanItemEditingController.h"
#import "LayoutPreviewTableViewCell.h"
#import "PlanItemEditingController.h"

@interface PlanItemLayoutChooserTableViewController ()

@end

@implementation PlanItemLayoutChooserTableViewController

- (void)loadView {
    [super loadView];
    
    [self addBackButtonWithString:NSLocalizedString(@"Settings", nil)];
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [self.tableView registerClass:[LayoutPreviewTableViewCell class] forCellReuseIdentifier:kLayoutPreviewTableViewCellIdentifier];
}

#pragma mark -
#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MediaSelectedTableviewCell heightForCell];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LayoutPreviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLayoutPreviewTableViewCellIdentifier forIndexPath:indexPath];
    cell.cellAccessoryType = MediaSelectedAccessoryTypeCheckmark;
    
    PCOSlideLayout *layout = [self layoutForIndexPath:indexPath];
    
    cell.titleLabel.text = [layout localizedDescription];
    cell.layout = layout;

    if ([self.selectedItem.selectedSlideLayoutId pco_isEqualToNumber:layout.remoteId]) {
        cell.showCheckmark = YES;
    } else {
        cell.showCheckmark = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

     PCOSlideLayout *layout = [self layoutForIndexPath:indexPath];
    if (layout) {
        [PCOEventLogger logEvent:@"Changed Plan Item Layout"];
        [[PlanItemEditingController sharedController] changeLayoutOfItem:self.selectedItem toLayout:layout inPlan:self.plan];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
