//
//  CustomSlidesListViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/15/14.
//

#import "CustomSlidesListViewController.h"
#import "CommonNavButton.h"
#import "NSLayoutConstraint+PCOKitAdditions.h"
#import "PRONavigationController.h"
#import "PCOCustomSlide.h"
#import "CustomSlideListTableViewCell.h"
#import "PlanItemEditingController.h"
#import "UIBarButtonItem+PCOKitAdditions.h"

@interface CustomSlidesListViewController ()

@property (nonatomic, strong) NSArray *viewContraints;

@property (nonatomic, weak) PCOTableView *customSlideTable;

@property (nonatomic, weak) UIView *dragContainerView;

@property (nonatomic) BOOL draggingAddNew;

@property (nonatomic, strong) NSMutableArray * deletedSlideRemoteIds;
@property (nonatomic, strong) NSMutableArray * modifiedSlideObjectIds;


@end

@implementation CustomSlidesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Custom Slides", nil);
    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Save", nil)
                                                                                                              color:[UIColor customSlideSaveButtonColor]
                                                                                                             action:@selector(saveButtonAction:)]];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Cancel", nil)
                                                                                                                color:[UIColor sequenceTableViewBorderColor]
                                                                                                               action:@selector(cancelButtonAction:)]];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PRONavigationController *proNav = (PRONavigationController *)[self navigationController];
    proNav.navigationBar.barTintColor = [UIColor layoutControllerToolbarBackgroundColor];
    self.view.backgroundColor = [UIColor customSlidesBorderColor];
    [self.view updateConstraintsIfNeeded];
    [self.customSlideTable reloadData];
}

#pragma mark -
#pragma mark - Setters

- (void)setSelectedItem:(PCOItem *)selectedItem {
    _selectedItem = selectedItem;
    [[PCOCoreDataManager sharedManager] save:NULL];
    self.selectedItem.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
    [self.selectedItem.managedObjectContext.undoManager beginUndoGrouping];
    [self.selectedItem.managedObjectContext.undoManager setActionName:@"Custom Slide List"];
    
    [self.customSlideTable reloadData];
}


#pragma mark -
#pragma mark - Layout
- (void)updateViewConstraints {
    [super updateViewConstraints];

    if (self.viewContraints) {
        [self.view removeConstraints:self.viewContraints];
    }
    
    CGFloat dragViewHeight = 60;
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{@"drag_view_height": @(dragViewHeight)};
    
    NSDictionary *views = @{
                            @"table": self.customSlideTable,
                            @"drag_view": self.dragContainerView,
                            };
    
    for (NSString *format in @[
                               @"H:|[table]|",
                               @"H:|[drag_view]|",
                               
                               @"V:|-1-[table][drag_view(==drag_view_height)]|",
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
    return [[self.selectedItem customSlides] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CustomSlideListTableViewCell heightForCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
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
    CustomSlideListTableViewCell *reorderCell = (CustomSlideListTableViewCell *)cell;
    [reorderCell repositionReorderControl];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.row == destinationIndexPath.row) return;
    
    //NSLog(@"from %d to %ld", sourceIndexPath.row, (long)destinationIndexPath.row);
    
    NSMutableArray * reorderArray = [[NSMutableArray alloc] init];
    
    for (PCOCustomSlide * slide in [self.selectedItem orderedCustomSlides])
    {
        [reorderArray addObject:slide];
    }
    
    [self.selectedItem clearOrderCache];
    
    PCOCustomSlide *movingSlide = [reorderArray objectAtIndex:sourceIndexPath.row];
    [reorderArray removeObjectAtIndex:sourceIndexPath.row];
    [reorderArray insertObject:movingSlide atIndex:destinationIndexPath.row];
    
    NSUInteger order = 1;
    for (PCOCustomSlide * slide in reorderArray) {
        slide.order = [NSNumber numberWithInteger:order];
        order++;
    }
    
    [self.customSlideTable reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomSlideListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomSlideListTableViewCellIdentifier];
    
    PCOCustomSlide * currentSlide = [[self.selectedItem orderedCustomSlides] objectAtIndex:indexPath.row];
    if ([currentSlide.label length] > 0)
    {
        cell.titleLabel.text = currentSlide.label;
    }
    else
    {
        cell.titleLabel.text = [NSString stringWithFormat:@"Slide %ld", (long)indexPath.row + 1];
    }
    
    cell.subTitleLabel.text = currentSlide.body;

    
//    cell.textLabel.textColor = [UIColor customSlidesCellTextColor];
//    cell.backgroundColor = [UIColor customSlidesCellBackgroundColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [PCOEventLogger logEvent:@"Edit Custom Slide"];
    PCOCustomSlide * currentSlide = [[self.selectedItem orderedCustomSlides] objectAtIndex:indexPath.row];
    CustomSlidesEditorViewController *viewController = [[CustomSlidesEditorViewController alloc] initWithNibName:@"CustomSlidesEditorViewController" bundle:[NSBundle mainBundle]];
    viewController.delegate = self;
    viewController.plan = self.plan;
    viewController.newOrderIndex = indexPath.row;
    viewController.selectedItem = self.selectedItem;
    viewController.slideObjectID = currentSlide.objectID;
    [self.navigationController pushViewController:viewController animated:YES];

}

#pragma mark -
#pragma mark - CustomSlidesEditorViewControllerDelegate Methods
- (void)slideEditor:(CustomSlidesEditorViewController *)editor didSaveChangesForSlideWithObjectID:(NSManagedObjectID *)objectID {
    if (![self.modifiedSlideObjectIds containsObject:objectID])
    {
        [self.modifiedSlideObjectIds addObject:objectID];
    }
    
    PCOCustomSlide * newSlide = (PCOCustomSlide *)[self.selectedItem.managedObjectContext existingObjectWithID:objectID error:nil];
    
    if (![self.selectedItem.customSlides containsObject:newSlide])
    {
        [self.selectedItem addCustomSlidesObject:newSlide];
    }
    
    //NSInteger fromIndex = [[currentItem orderedCustomSlides] indexOfObject:newSlide];
    NSInteger toIndex = editor.newOrderIndex;
    if (toIndex >= (NSInteger)[self.selectedItem.customSlides count])
    {
        toIndex = [self.selectedItem.customSlides count] - 1;
    }
    
    //NSLog(@"from %d to %ld", fromIndex, (long)toIndex);
    
    NSMutableArray * reorderArray = [[NSMutableArray alloc] init];
    
    for (PCOCustomSlide * slide in [self.selectedItem orderedCustomSlides])
    {
        [reorderArray addObject:slide];
    }
    
    PCOCustomSlide *movingSlide = newSlide;
    [reorderArray removeObject:movingSlide];
    [reorderArray insertObject:movingSlide atIndex:toIndex];
    
    NSUInteger order = 1;
    for (PCOCustomSlide * slide in reorderArray) {
        slide.order = [NSNumber numberWithInteger:order];
        order++;
    }
    
    [self.customSlideTable reloadData];
}

- (void)slideEditorDidDeleteSlideWithObjectID:(NSManagedObjectID *)slideObjectID {
    [PCOEventLogger logEvent:@"Deleted Custom Slide"];
    PCOCustomSlide * currentSlide = [[PCOCoreDataManager sharedManager] objectWithID:slideObjectID inContext:self.selectedItem.managedObjectContext];
    
    NSNumber * slideRemoteId = [currentSlide remoteId];
    
    if (slideRemoteId)
        [self.deletedSlideRemoteIds addObject:slideRemoteId];
    
    [self.selectedItem removeCustomSlidesObject:currentSlide];
    
    NSMutableArray * reorderArray = [[NSMutableArray alloc] init];
    
    for (PCOCustomSlide * slide in [self.selectedItem orderedCustomSlides]) {
        [reorderArray addObject:slide];
    }
    
    NSUInteger order = 1;
    for (PCOCustomSlide * slide in reorderArray) {
        slide.order = [NSNumber numberWithInteger:order];
        order++;
    }
    
    [self.customSlideTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -
#pragma mark - Helper Methods

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector{
    CGRect frame = [CommonNavButton frameWithText:text backArrow:NO];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark -
#pragma mark - Lazy Loaders

- (PCOTableView *)customSlideTable {
    if (!_customSlideTable) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor customSlidesListBackgroundColor];
        table.separatorColor = [UIColor customSlidesTableViewSeparatorColor];
        table.editing = YES;
        table.allowsSelectionDuringEditing = YES;
        [table registerClass:[CustomSlideListTableViewCell class] forCellReuseIdentifier:kCustomSlideListTableViewCellIdentifier];
        [self.view addSubview:table];
        _customSlideTable = table;
    }
    return _customSlideTable;
}

- (UIView *)dragContainerView {
    if (!_dragContainerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor customSlidesDragAreaBackgroundColor];
        [self.view addSubview:view];

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
        label.text = NSLocalizedString(@"Drag or tap to add slide", nil);
        [view addSubview:label];
        CGFloat xOffset = 19 + image.size.width + 13;
        [view addConstraints:[NSLayoutConstraint pco_fitView:label inView:view insets:UIEdgeInsetsMake(0, xOffset, 0, 0)]];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addNewBarGestureAction:)];
        longPress.minimumPressDuration = 0.2;
        [view addGestureRecognizer:longPress];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addNewTapGestureAction:)]];

        
        _dragContainerView = view;


    }
    return _dragContainerView;
}

- (NSMutableArray *)deletedSlideRemoteIds {
    if (!_deletedSlideRemoteIds) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        _deletedSlideRemoteIds = array;
    }
    return _deletedSlideRemoteIds;
}

- (NSMutableArray *)modifiedSlideObjectIds {
    if (!_modifiedSlideObjectIds) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        _modifiedSlideObjectIds = array;
    }
    return _modifiedSlideObjectIds;
}

#pragma mark -
#pragma mark - Action Methods
- (void)addNewBarGestureAction:(UILongPressGestureRecognizer *)longPress {
    CGPoint location = [longPress locationInView:self.view];
    NSIndexPath *indexPath = [self.customSlideTable indexPathForRowAtPoint:[longPress locationInView:self.customSlideTable]];
    CGPoint center = self.dragContainerView.center;
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        self.draggingAddNew = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.dragContainerView.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self.dragContainerView.alpha = 0.9;
        }];
    }
    if (longPress.state == UIGestureRecognizerStateChanged) {
        center.y = location.y;
    }
    if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled) {
        self.draggingAddNew = NO;
        [self addNewItemAtIndexPath:indexPath];
    }
    
    self.dragContainerView.center = center;
    
    if (!self.draggingAddNew) {
        [UIView animateWithDuration:0.2 animations:^{
            [self viewWillLayoutSubviews];
            self.dragContainerView.transform = CGAffineTransformIdentity;
            self.dragContainerView.alpha = 1.0;
        }];
    }
}
- (void)addNewTapGestureAction:(UITapGestureRecognizer *)tapper {
    [self addNewItemAtIndexPath:nil];
}

- (void)addNewItemAtIndexPath:(NSIndexPath *)indexPath {
    [PCOEventLogger logEvent:@"Add Custom Slide"];

    CustomSlidesEditorViewController *viewController = [[CustomSlidesEditorViewController alloc] initWithNibName:@"CustomSlidesEditorViewController" bundle:[NSBundle mainBundle]];
    viewController.delegate = self;
    viewController.plan = self.plan;
    viewController.selectedItem = self.selectedItem;
    
    if (indexPath) {
        viewController.newOrderIndex = indexPath.row;
        viewController.newSlideNumber = [self.selectedItem.customSlides count] + 1;
    }
    else {
        viewController.newOrderIndex = [[[[self.selectedItem orderedCustomSlides] lastObject] order] integerValue] + 1;
        viewController.newSlideNumber = [self.selectedItem.customSlides count] + 1;
    }
    viewController.slideObjectID = nil;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)saveButtonAction:(id)sender {
    if (self.selectedItem.managedObjectContext.undoManager.groupingLevel == 1) {
        [self.selectedItem.managedObjectContext.undoManager endUndoGrouping];
    }
    if ([self.selectedItem.managedObjectContext hasChanges]) {
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if ([item.customView respondsToSelector:@selector(setColor:)]) {
            [((UIActivityIndicatorView *)item.customView) setColor:[UIColor projectorOrangeColor]];
        }
        if ([item.customView respondsToSelector:@selector(startAnimating)]) {
            [((UIActivityIndicatorView *)item.customView) startAnimating];
        }
        self.navigationItem.rightBarButtonItem = item;
        
        [[PlanItemEditingController sharedController] saveCustomSlides:self.modifiedSlideObjectIds
                                                       deletedSlideIds:self.deletedSlideRemoteIds
                                                               forItem:self.selectedItem inPlan:self.plan completionBlock:^{
                                                                   [self dismissViewControllerAnimated:YES completion:^{
                                                                       
                                                                   }];
                                                               }];
        return;
    }
    self.selectedItem.managedObjectContext.undoManager = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)cancelButtonAction:(id)sender {
    if (self.selectedItem.managedObjectContext.undoManager.groupingLevel > 0) {
        [self.selectedItem.managedObjectContext.undoManager endUndoGrouping];
    }
    if ([self.selectedItem.managedObjectContext.undoManager canUndo]) {
        [self.selectedItem.managedObjectContext.undoManager undo];
    }
    self.selectedItem.managedObjectContext.undoManager = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
