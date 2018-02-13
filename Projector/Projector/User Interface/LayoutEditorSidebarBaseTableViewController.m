/*!
 * LayoutEditorSidebarBaseTableViewController.m
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#import "LayoutEditorSidebarBaseTableViewController.h"
#import "LayoutEditorInterfaceContainerController.h"

@interface _LayoutEditorSidebarBaseTableViewHeaderView : UITableViewHeaderFooterView

@end
@implementation _LayoutEditorSidebarBaseTableViewHeaderView @end
static NSString *const _LayoutEditorSidebarBaseTableViewHeaderViewIdentifier = @"_LayoutEditorSidebarBaseTableViewHeaderViewIdentifier";

@interface LayoutEditorSidebarBaseTableViewController ()

@property (nonatomic, weak, readwrite) LayoutEditorInterfaceContainerController *rootController;

@end

@implementation LayoutEditorSidebarBaseTableViewController 

- (void)loadView {
    [super loadView];
    
    [self.tableView registerClass:[_LayoutEditorSidebarBaseTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:_LayoutEditorSidebarBaseTableViewHeaderViewIdentifier];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor layoutEditorSidebarTableViewBackgroundColor];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.parentViewController.title = title;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.rootController registerObjectForChanges:self];
    
    if (!self.layout) {
        self.layout = self.rootController.layout;
    }
    if (!self.textLayout) {
        [self updateCurrentTextLayout];
    }
    
    [self updateUserInterfaceForObjectChanges];
    
    [self.tableView reloadData];
}

- (void)updateCurrentTextLayout {
    if ([self useCurrentTextLayout]) {
        self.textLayout = self.rootController.currentTextLayout;
    } else {
        self.textLayout = self.rootController.currentSongLayout;
    }
}

- (LayoutEditorInterfaceContainerController *)rootController {
    if (!_rootController) {
        _rootController = [self fetchRootController];
    }
    return _rootController;
}
- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    self.rootController = nil;
}
- (LayoutEditorInterfaceContainerController *)fetchRootController {
    LayoutEditorInterfaceContainerController *controller = (id)self.parentViewController;
    while (![controller isKindOfClass:[LayoutEditorInterfaceContainerController class]]) {
        LayoutEditorInterfaceContainerController *nextParent = (id)controller.parentViewController;
        if (!nextParent) {
            if (controller.navigationController) {
                nextParent = (id)controller.navigationController;
            }
            if (!nextParent) {
                break;
            }
        }
        controller = nextParent;
    }
    
    if ([controller isKindOfClass:[LayoutEditorInterfaceContainerController class]]) {
        return controller;
    }
    return nil;
}

- (void)updateUserInterfaceForObjectChanges {
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:_LayoutEditorSidebarBaseTableViewHeaderViewIdentifier];
}

- (BOOL)useCurrentTextLayout {
    return YES;
}

@end
