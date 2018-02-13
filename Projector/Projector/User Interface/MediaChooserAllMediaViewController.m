
//
//  MediaChooserAllMediaViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/9/14.
//

#import "MediaChooserAllMediaViewController.h"
#import "MediaChooserAllMediaMediaTypeDisplayController.h"

@interface MediaChooserAllMediaViewController ()

@end

@implementation MediaChooserAllMediaViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PCOMediaType *type = self.mediaTypes[indexPath.row];
    
    MediaChooserAllMediaMediaTypeDisplayController *controller = [[MediaChooserAllMediaMediaTypeDisplayController alloc] initWithNibName:nil bundle:nil];
    controller.preferredContentSize = self.preferredContentSize;
    controller.mediaType = type;
    controller.picker = self.picker;
    controller.plan = self.plan;
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
