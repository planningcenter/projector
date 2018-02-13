//
//  MediaChooserViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/8/14.
//

#import "MediaChooserViewController.h"
#import "MediaChooserAllMediaViewController.h"
#import "MediaChooserPlanMediaViewController.h"

@interface MediaChooserViewController ()

@end

@implementation MediaChooserViewController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Add Media", nil);
    [self addBackButtonWithString:NSLocalizedString(@"Media", nil)];
}

- (UIViewController *)newSegmentControllerForSegment:(NSInteger)segment {
    PROLogoPickerAddLogoSubViewController *controller = nil;
    if (segment == 0) {
        MediaChooserAllMediaViewController *allMediaController = [[MediaChooserAllMediaViewController alloc] initWithNibName:nil bundle:nil];
        allMediaController.picker = self.picker;
        controller = allMediaController;
    }
    if (segment == 1) {
        MediaChooserPlanMediaViewController *planMediaController = [[MediaChooserPlanMediaViewController alloc] initWithNibName:nil bundle:nil];
        planMediaController.picker = self.picker;
        controller = planMediaController;
    }
    controller.plan = self.plan;
    return controller;
}

@end
