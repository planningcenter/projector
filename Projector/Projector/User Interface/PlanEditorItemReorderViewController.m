//
//  PlanEditorItemReorderViewController.m
//  Projector
//
//  Created by Peter Fokos on 11/7/14.
//

#import "PlanEditorItemReorderViewController.h"
#import "PRONavigationController.h"
#import "CommonNavButton.h"
#import "SequenceReorderTableViewCell.h"
#import "PlanEditingController.h"
#import "UIBarButtonItem+PCOKitAdditions.h"
#import "PROSlideManager.h"

#define EDIT_BUTTONS_SIZE 40
#define DRAG_VIEW_HEIGHT 44

@interface PlanEditorItemReorderViewController ()

@property (nonatomic, strong) NSArray *viewContraints;
@property (nonatomic, weak) PCOTableView *planItemsTable;
@property (nonatomic, weak) UIView *dragContainerView;
@property (nonatomic, weak) UIView *dragableView;
@property (nonatomic) BOOL draggingAddNew;
@property (nonatomic) BOOL planWasChanged;
@property (nonatomic) BOOL planItemWasChanged;

@end

@implementation PlanEditorItemReorderViewController

- (void)loadView {
    self.title = NSLocalizedString(@"Order of Service", nil);
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationBarButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PRONavigationController *proNav = (PRONavigationController *)[self navigationController];
    proNav.navigationBar.barTintColor = [UIColor layoutControllerToolbarBackgroundColor];
    self.view.backgroundColor = [UIColor captializedTextHeaderBackgroundColor];
    [self.view updateConstraintsIfNeeded];
    [self.planItemsTable reloadData];
}

#pragma mark - Helper Methods
#pragma mark -

- (void)configureNavigationBarButtons {
    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Done", nil)
                                                                                                              color:[UIColor projectorOrangeColor]
                                                                                                             action:@selector(saveButtonAction:)]];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    PCOButton *servicesButton = [[PCOButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [servicesButton setImage:[UIImage imageNamed:@"services-icon"] forState:UIControlStateNormal];
    [servicesButton addTarget:self action:@selector(serviceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * servicesButtonItem = [[UIBarButtonItem alloc] initWithCustomView:servicesButton];
    self.navigationItem.leftBarButtonItem = servicesButtonItem;
}

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector{
    CGRect frame = [CommonNavButton frameWithText:text backArrow:NO];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)editItem:(PCOItem *)selectedItem {
    ItemEditorViewController *viewController = [[ItemEditorViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    viewController.plan = self.plan;
    viewController.selectedItem = selectedItem;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Layout
#pragma mark -

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (self.viewContraints) {
        [self.view removeConstraints:self.viewContraints];
    }
    
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{@"drag_view_height": @(DRAG_VIEW_HEIGHT)};
    
    NSDictionary *views = @{
                            @"table": self.planItemsTable,
                            @"drag_view": self.dragContainerView,
                            @"dragable_view": self.dragableView,
                            };
    
    for (NSString *format in @[
                               @"H:|[table]|",
                               @"H:|[drag_view]|",
                               @"H:|[dragable_view]|",
                               
                               @"V:|-1-[table][drag_view(==drag_view_height)]|",
                               @"V:[dragable_view(==drag_view)]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    
    [self.view addConstraints:array];
    self.viewContraints = [NSArray arrayWithArray:array];
    [self.view updateConstraintsIfNeeded];
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    count = [[self.plan orderedItems] count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if (tableView == self.planItemsTable) {
        SequenceReorderTableViewCell *reorderCell = (SequenceReorderTableViewCell *)cell;
        [reorderCell repositionReorderControl];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (tableView == self.planItemsTable) {
        if (sourceIndexPath.row == destinationIndexPath.row) {
            return;
        }
        NSMutableArray *planItems = [NSMutableArray arrayWithArray:[self.plan orderedItems]];

        PCOItem *move = [planItems objectAtIndex:sourceIndexPath.row];
        [planItems removeObjectAtIndex:sourceIndexPath.row];
        [planItems insertObject:move atIndex:destinationIndexPath.row];
        
        NSUInteger order = 1;
        for (PCOItem *item in planItems) {
            item.sequence = @(order);
            order++;
        }
        self.planWasChanged = YES;
        [self.planItemsTable reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOItem *item = [[self.plan orderedItems] objectAtIndex:indexPath.row];
    SequenceReorderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSequenceReorderTableViewCellIdentifier];
    cell.showsReorderControl = YES;
    cell.backgroundView.backgroundColor = [UIColor sequenceTableCellBackgroundColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    [cell accessoryTintColor:nil];
    if ([item isTypeHeader]) {
        cell.backgroundView.backgroundColor = [UIColor planGridSectionHeaderItemHeaderBackgroundColor];
        [cell accessoryTintColor:[UIColor mediaSelectedCellSubTitleColor]];
    }
    cell.titleLabel.textColor = [UIColor sequenceTableCellTitleColor];
    cell.titleLabel.text = item.name;
    [cell.swipeLeft addTarget:self action:@selector(showDeleteCell:)];
    [cell.swipeRight addTarget:self action:@selector(hideDeleteCell:)];
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deletePlanItemAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.plan.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
    [self.plan.managedObjectContext.undoManager beginUndoGrouping];
    [self.plan.managedObjectContext.undoManager setActionName:@"Edit Item"];
    PCOItem *selectedItem = [[self.plan orderedItems] objectAtIndex:indexPath.row];
    [self editItem:selectedItem];
}

#pragma mark -
#pragma mark - Setter Methods

- (void)setPlan:(PCOPlan *)plan {
    _plan = plan;
    [self.planItemsTable reloadData];
}

#pragma mark -
#pragma mark - Lazy Loaders

- (PCOTableView *)planItemsTable {
    if (!_planItemsTable) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor sequenceTableCellBackgroundColor];
        table.separatorColor = [UIColor sequenceTableViewSeparatorColor];
        _planItemsTable = table;
        [table registerClass:[CustomSlideListTableViewCell class] forCellReuseIdentifier:kSequenceReorderTableViewCellIdentifier];
        table.editing = YES;
        table.allowsSelectionDuringEditing = YES;
        
        [self.view addSubview:table];
    }
    return _planItemsTable;
}

- (UIView *)dragView {
    UIView *view = [UIView newAutoLayoutView];
    view.backgroundColor = [UIColor customSlidesDragAreaBackgroundColor];
    
    UIImageView *iView = [UIImageView newAutoLayoutView];
    iView.backgroundColor = [UIColor clearColor];
    UIImage *image = [UIImage imageNamed:@"drag-up"];
    iView.image = image;
    iView.contentMode = UIViewContentModeCenter;
    iView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:iView];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:iView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:19]];
    [view addConstraint:[NSLayoutConstraint pco_centerVertical:iView inView:view]];
    [view addConstraints:[NSLayoutConstraint pco_size:image.size forView:iView]];
    
    PCOLabel *label = [PCOLabel newAutoLayoutView];
    label.font = [UIFont defaultFontOfSize_16];
    label.textColor = [UIColor customSlidesCellTextColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 1;
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Add New Item", nil);
    [view addSubview:label];
    CGFloat xOffset = 19 + image.size.width + 13;
    [view addConstraints:[NSLayoutConstraint pco_fitView:label inView:view insets:UIEdgeInsetsMake(0, xOffset, 0, 0)]];
    return view;
}

- (UIView *)dragContainerView {
    if (!_dragContainerView) {
        UIView *dragView = [self dragView];
        [self.view addSubview:dragView];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addNewBarGestureAction:)];
        longPress.minimumPressDuration = 0.2;
        [dragView addGestureRecognizer:longPress];
        [dragView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addNewTapGestureAction:)]];
        
        _dragContainerView = dragView;
        
        
    }
    return _dragContainerView;
}

- (UIView *)dragableView {
    if (!_dragableView) {
        UIView *dragView = [self dragView];
        dragView.hidden = YES;
        [self.view addSubview:dragView];
        _dragableView = dragView;
    }
    return _dragableView;
}

#pragma mark -
#pragma mark - Action Methods

- (void)saveButtonAction:(id)sender {
    if (self.planWasChanged) {
        [PCOEventLogger logEvent:@"Reorder controller did reorder"];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if ([item.customView respondsToSelector:@selector(setColor:)]) {
            [((UIActivityIndicatorView *)item.customView) setColor:[UIColor projectorOrangeColor]];
        }
        if ([item.customView respondsToSelector:@selector(startAnimating)]) {
            [((UIActivityIndicatorView *)item.customView) startAnimating];
        }
        self.navigationItem.rightBarButtonItem = item;
        [[PlanEditingController sharedController] savePlanOrderChanges:self.plan completionBlock:^{
            [self dismissViewControllerAnimated:YES completion:^{
                [[PROSlideManager sharedManager] emptyCache];
            }];
        }];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.planItemWasChanged) {
                [[PROSlideManager sharedManager] emptyCache];
            }
        }];
    }
}

- (void)serviceButtonAction:(id)sender {
    MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Edit in Services App?", nil) message:NSLocalizedString(@"Do you want to switch to the Services app to edit items in this plan? Any external screens will be disconnected.", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil)];
    
    [alert addActionWithTitle:NSLocalizedString(@"Open Services", nil) handler:^(MCTAlertViewAction *a) {
        [self editPlanInServices];
    }];
    
    [alert show];
}

- (void)deletePlanItemAction:(PCOButton *)sender {
    [PCOEventLogger logEvent:@"User deleted item"];
    NSInteger tag = sender.tag;
    PCOItem *itemToDelete = [[self.plan orderedItems] objectAtIndex:tag];
    [[PlanEditingController sharedController] deleteItem:itemToDelete inPlan:self.plan completionBlock:^{
        [self.planItemsTable reloadData];
        self.planWasChanged = YES;
    }];
}

- (void)showDeleteCell:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.planItemsTable];
    NSIndexPath *indexPath = [self.planItemsTable indexPathForRowAtPoint:location];
    SequenceReorderTableViewCell *cell = (SequenceReorderTableViewCell *)[self.planItemsTable cellForRowAtIndexPath:indexPath];
    if (!cell.deleteVisible) {
        [cell toggleDeleteAnimated:YES];
    }
}

- (void)hideDeleteCell:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.planItemsTable];
    NSIndexPath *indexPath = [self.planItemsTable indexPathForRowAtPoint:location];
    SequenceReorderTableViewCell *cell = (SequenceReorderTableViewCell *)[self.planItemsTable cellForRowAtIndexPath:indexPath];
    if (cell.deleteVisible) {
        [cell toggleDeleteAnimated:YES];
    }
}

- (void)addNewBarGestureAction:(UILongPressGestureRecognizer *)longPress {
    CGPoint location = [longPress locationInView:self.view];
    NSIndexPath *indexPath = [self.planItemsTable indexPathForRowAtPoint:[longPress locationInView:self.planItemsTable]];
    CGPoint center = self.dragContainerView.center;
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.draggingAddNew = YES;
        self.dragableView.hidden = NO;
        [self.view bringSubviewToFront:self.dragableView];
        [UIView animateWithDuration:0.2 animations:^{
            self.dragableView.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.dragableView.alpha = 0.9;
        }];
    }
    if (longPress.state == UIGestureRecognizerStateChanged) {
        center.y = location.y;
    }
    if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled) {
        self.draggingAddNew = NO;
        self.dragableView.hidden = YES;
        [self addNewItemAtIndexPath:indexPath];
    }
    
    self.dragableView.center = center;
    
    if (!self.draggingAddNew) {
        [UIView animateWithDuration:0.2 animations:^{
            [self viewWillLayoutSubviews];
            self.dragableView.transform = CGAffineTransformIdentity;
            self.dragableView.alpha = 1.0;
        }];
    }
}

- (void)addNewTapGestureAction:(UITapGestureRecognizer *)tapper {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self.plan orderedItems] count] inSection:0];
    [self addNewItemAtIndexPath:indexPath];
}

- (void)addNewItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath && self.plan) {
        self.planWasChanged = YES;

        PCOItem *newItem = [PCOItem object];

        self.plan.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
        [self.plan.managedObjectContext.undoManager beginUndoGrouping];
        [self.plan.managedObjectContext.undoManager setActionName:@"Add New Item"];
        
        [newItem setName:NSLocalizedString(@"", nil)];
        [newItem setSequence:@(indexPath.row + 1)];
        [newItem setType:NSLocalizedString(@"PlanItem", nil)];
        
        NSArray *currentItems = [self.plan orderedItems];
        
        for (NSUInteger i = indexPath.row; i < [currentItems count]; i++) {
            PCOItem *change = [currentItems objectAtIndex:i];
            change.sequence = @(i + 2);
        }
        
        NSUInteger offset = 1;
        if (indexPath.row == [self.planItemsTable numberOfRowsInSection:0]) {
            offset = 2;
        }
        newItem.sequence = @(indexPath.row + offset);
        
        [self.plan addItemsObject:newItem];
        
        [self.planItemsTable beginUpdates];
        [self.planItemsTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.planItemsTable endUpdates];
        
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self editItem:newItem];
        });
    }
}

#pragma mark -
#pragma mark - Edit Item
- (void)editPlanInServices {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"pcoservices://projector-edit-service-order"];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:4];
    [items addObject:[[NSURLQueryItem alloc] initWithName:@"userID" value:[[[PCOUserData current] remoteId] stringValue]]];
    [items addObject:[[NSURLQueryItem alloc] initWithName:@"organizationID" value:[[[PCOOrganization current] remoteId] stringValue]]];
    [items addObject:[[NSURLQueryItem alloc] initWithName:@"planID" value:[self.plan.remoteId stringValue]]];
    [items addObject:[[NSURLQueryItem alloc] initWithName:@"pco-callback-url" value:@"pcoprojector2://refresh/current-plan"]];
    
    components.queryItems = items;
    
    NSURL *URL = [components URL];
    
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://appstore.com/planningcenterservices"]];
    }
}

#pragma mark -
#pragma mark - ItemEditorViewControllerDelegate Method

- (void)planItemWasSaved {
    self.planItemWasChanged = YES;
}

@end
