/*!
 * PROFirstLaunchViewController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 1/8/15
 */

#import "PROFirstLaunchViewController.h"
#import "PCOKeyValueStore.h"
#import "PRONavigationController.h"

static NSString *const kPROFirstLaunchViewControllerHasPresented = @"kPROFirstLaunchViewControllerHasPresented";

@interface PROFirstLaunchViewController ()

@end

@implementation PROFirstLaunchViewController

+ (void)presentFromViewController:(UIViewController *)controller {
    if ([[[PCOKeyValueStore defaultStore] objectForKey:kPROFirstLaunchViewControllerHasPresented] boolValue]) {
        return;
    }
    
    PRONavigationController *navigation = [[PRONavigationController alloc] initWithRootViewController:[[self alloc] initWithNibName:@"PROFirstLaunchViewController" bundle:[NSBundle mainBundle]]];
    navigation.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [controller presentViewController:navigation animated:YES completion:^{
        [[PCOKeyValueStore defaultStore] setObject:@YES forKey:kPROFirstLaunchViewControllerHasPresented];
    }];
}

- (void)loadView {
    [super loadView];
    
    self.view.tintColor = [UIColor projectorOrangeColor];
    self.view.backgroundColor = [UIColor projectorBlackColor];
    
    self.title = NSLocalizedString(@"Setup", nil);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UILabel *label in self.view.subviews) {
        if ([label respondsToSelector:@selector(setFont:)]) {
            CGFloat size = 16.0;
            if ([label respondsToSelector:@selector(font)]) {
                size = [[label font] pointSize];
            }
            [label setFont:[UIFont defaultFontOfSize:size]];
        }
    }
    
    switch ([[ProjectorSettings userSettings] aspectRatio]) {
        case ProjectorAspectRatio_16_9:
            self.aspectPicker.selectedSegmentIndex = 0;
            break;
        case ProjectorAspectRatio_4_3:
            self.aspectPicker.selectedSegmentIndex = 1;
            break;
    }
    
    switch ([[ProjectorSettings userSettings] gridSize]) {
        case ProjectorGridSizeSmall:
            self.gridSizePicker.selectedSegmentIndex = 0;
            break;
        case ProjectorGridSizeNormal:
            self.gridSizePicker.selectedSegmentIndex = 1;
            break;
        case ProjectorGridSizeLarge:
            self.gridSizePicker.selectedSegmentIndex = 2;
            break;
    }
}

- (IBAction)doneButtonAction:(id)sender {
    if (self.aspectPicker.selectedSegmentIndex == 0) {
        [[ProjectorSettings userSettings] setAspectRatio:ProjectorAspectRatio_16_9];
    }
    if (self.aspectPicker.selectedSegmentIndex == 1) {
        [[ProjectorSettings userSettings] setAspectRatio:ProjectorAspectRatio_4_3];
    }
    
    if (self.gridSizePicker.selectedSegmentIndex == 0) {
        [[ProjectorSettings userSettings] setGridSize:ProjectorGridSizeSmall];
    }
    if (self.gridSizePicker.selectedSegmentIndex == 1) {
        [[ProjectorSettings userSettings] setGridSize:ProjectorGridSizeNormal];
    }
    if (self.gridSizePicker.selectedSegmentIndex == 2) {
        [[ProjectorSettings userSettings] setGridSize:ProjectorGridSizeLarge];
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
