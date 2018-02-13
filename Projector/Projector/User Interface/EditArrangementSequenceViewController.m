//
//  EditArrangementSequenceViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/15/14.
//

#import "EditArrangementSequenceViewController.h"
#import "NSLayoutConstraint+PCOKitAdditions.h"
#import "PRONavigationController.h"
#import "EditLyricsViewController.h"
#import "CommonNavButton.h"

#import "PCOSequenceItem.h"
#import "PCOStanza.h"
#import "PCOItem.h"
#import "PCOArrangement.h"

#import "SequenceReorderTableViewCell.h"
#import "PlanItemSequenceViewController.h"
#import "MCTAlertView.h"

#import "PlanItemEditingController.h"
#import "UIBarButtonItem+PCOKitAdditions.h"
#import "PROSlideHelper.h"
#import "PROItemStanzaHelper.h"

#define EDIT_BUTTONS_SIZE 40

@interface EditArrangementSequenceViewController () {
    BOOL isEditing;
    NSString *stanzaLabel;
    BOOL autoScrolling;
}

@property (nonatomic, strong) NSArray *viewContraints;
@property (nonatomic, strong) NSArray *tablesContainerContraints;

@property (nonatomic, weak) UIView *instructionsContainerView;
@property (nonatomic, weak) UIView *tablesContainerView;

@property (nonatomic, weak) PCOTableView *sequenceTable;
@property (nonatomic, weak) PCOTableView *elementsTable;

@property (nonatomic, weak) PCOButton *addElementsButton;

@property (nonatomic, weak) UISegmentedControl *linkTypeSegmentedControl;
@property (nonatomic, weak) UIImageView *itemLinkImageView;
@property (nonatomic, weak) UIImageView *arrangementLinkImageView;

@property (nonatomic, weak) PCOLabel *instructionsLabel;

@property (nonatomic, strong) NSArray *availableStanzas;

@property (nonatomic, weak) UIView *draggableView;

@end

@implementation EditArrangementSequenceViewController

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureNavigationBarButtons];
    PCOKitLazyLoad(self.instructionsLabel);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PRONavigationController *proNav = (PRONavigationController *)[self navigationController];
    proNav.navigationBar.barTintColor = [UIColor layoutControllerToolbarBackgroundColor];
    self.view.backgroundColor = [UIColor captializedTextHeaderBackgroundColor];
    [self.view updateConstraintsIfNeeded];
    if ([self.selectedItem.saveSequenceToArrangement boolValue]) {
        self.linkTypeSegmentedControl.selectedSegmentIndex = 1;
        self.itemLinkImageView.hidden = YES;
        self.arrangementLinkImageView.hidden = NO;

    }
    else {
        self.linkTypeSegmentedControl.selectedSegmentIndex = 0;
        self.itemLinkImageView.hidden = NO;
        self.arrangementLinkImageView.hidden = YES;
    }
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
//    [self.tableView registerClass:[MediaSelectedTableviewCell class] forCellReuseIdentifier:kMediaSelectedTableviewCellIdentifier];
}

- (void)configureNavigationBarButtons {
    if (isEditing) {
        UIBarButtonItem * doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Done", nil)
                                                                                                                  color:[UIColor customSlideSaveButtonColor]
                                                                                                                 action:@selector(addElementsButtonAction:)]];
        self.navigationItem.rightBarButtonItem = doneButtonItem;
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        NSString *saveButtonTitle = NSLocalizedString(@"Save", nil);
        if (![self.plan canEdit]) {
            saveButtonTitle = NSLocalizedString(@"Done", nil);
        }
        UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:saveButtonTitle
                                                                                                                  color:[UIColor customSlideSaveButtonColor]
                                                                                                                 action:@selector(saveButtonAction:)]];
        self.navigationItem.rightBarButtonItem = saveButtonItem;
        
        UIBarButtonItem * lyricsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Lyrics", nil)
                                                                                                                    color:[UIColor sequenceTableViewBorderColor]
                                                                                                                   action:@selector(editLyricsAction:)]];
        self.navigationItem.leftBarButtonItem = lyricsButtonItem;
    }

}

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector{
    CGRect frame = [CommonNavButton frameWithText:text backArrow:NO];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIImageView *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [[UIImageView alloc] initWithImage:img];
}


#pragma mark - Layout
#pragma mark -

- (void)updateViewConstraints {    
    [super updateViewConstraints];
    [self updateMainViewConstraints];
    [self updateTablesContainerViewConstraints];
}

- (void)updateMainViewConstraints {
    if (self.viewContraints) {
        [self.view removeConstraints:self.viewContraints];
    }
    
    CGFloat instructionsHeight = 60;
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{
                              @"instructions_height": @(instructionsHeight),
                              @"edit_buttons_size": @(EDIT_BUTTONS_SIZE),
                              };
    
    NSDictionary *views = @{
                            @"instructions_container_view": self.instructionsContainerView,
                            @"tables_container_view": self.tablesContainerView,
                            @"add_button": self.addElementsButton,
                            @"link_control": self.linkTypeSegmentedControl,
                            };
    
    for (NSString *format in @[
                               @"H:|[instructions_container_view]|",
                               @"H:|[tables_container_view]|",
                               
                               @"V:|[tables_container_view][instructions_container_view(==instructions_height)]|",
                               @"H:[add_button(==edit_buttons_size)]-9-|",
                               @"V:[add_button(==edit_buttons_size)]-9-|",
                               @"H:|-12-[link_control(==310)]",
                               @"V:[link_control(==36)]-12-|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    
    [self.view addConstraints:array];
    self.viewContraints = [NSArray arrayWithArray:array];
    [self.view updateConstraintsIfNeeded];
}

- (void)updateTablesContainerViewConstraints {
    
    if (self.tablesContainerContraints) {
        [self.tablesContainerView removeConstraints:self.tablesContainerContraints];
    }

    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *metrics = @{
                              @"elements_table_width": @(0),
                              };
    
    NSDictionary *views = @{
                            @"sequence_table": self.sequenceTable,
                            @"elements_table": self.elementsTable,
                            };
    
    for (NSString *format in @[
                               @"V:|-1-[sequence_table]|",
                               @"V:|-1-[elements_table]|",
                               ]) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
        [array addObjectsFromArray:constraints];
    }
    if (isEditing) {
        [array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sequence_table][elements_table(==sequence_table)]|" options:0 metrics:metrics views:views]];
    }
    else {
        [array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sequence_table][elements_table(==0)]|" options:0 metrics:metrics views:views]];
    }
    
    [self.tablesContainerView addConstraints:array];
    self.tablesContainerContraints = [NSArray arrayWithArray:array];
    [self.tablesContainerView updateConstraintsIfNeeded];
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count;
    if (tableView == self.sequenceTable) {
        count = [[self.selectedItem orderedArrangementSequence] count];
    }
    else {
        count = [self.availableStanzas count];
    }
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
    if (tableView == self.sequenceTable) {
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
    if (tableView == self.sequenceTable) {
        [[[PCOCoreDataManager sharedManager] itemsController] moveStanzaForItem:self.selectedItem atIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
        [PROItemStanzaHelper clearCache];
        [self.sequenceTable reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOTableViewCell *cell = [[PCOTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (tableView == self.sequenceTable) {
        SequenceReorderTableViewCell *sCell = [tableView dequeueReusableCellWithIdentifier:kSequenceReorderTableViewCellIdentifier];
        sCell.showsReorderControl = YES;
        sCell.backgroundView.backgroundColor = [UIColor sequenceTableCellBackgroundColor];
        sCell.titleLabel.textColor = [UIColor sequenceTableCellTitleColor];
        PCOSequenceItem *item = [[self.selectedItem orderedArrangementSequence] objectAtIndex:indexPath.row];
        sCell.titleLabel.text = item.label;
        [sCell.swipeLeft addTarget:self action:@selector(showDeleteCell:)];
        [sCell.swipeRight addTarget:self action:@selector(hideDeleteCell:)];
        sCell.deleteButton.tag = indexPath.row;
        [sCell.deleteButton addTarget:self action:@selector(deleteSequenceAction:) forControlEvents:UIControlEventTouchUpInside];
        return sCell;
    }
    else {
        cell.backgroundView.backgroundColor = [UIColor elementsTableCellBackgroundColor];
        cell.backgroundColor = [UIColor elementsTableViewSeparatorColor];
        cell.textLabel.textColor = [UIColor sequenceTableCellTitleColor];
        cell.textLabel.font = [UIFont defaultFontOfSize_14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *stanzaText = [self.availableStanzas objectAtIndex:indexPath.row];
        cell.textLabel.text = stanzaText;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addNewStanzaGestureAction:)];
        longPress.minimumPressDuration = 0.2;
        [cell.contentView addGestureRecognizer:longPress];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.elementsTable) {
        return;
    }
    
    PCOStanza *stanza = [PROItemStanzaHelper stanzaAtIndex:indexPath.row item:self.selectedItem];
    if (stanza.lyrics) {
        PlanItemSequenceViewController *viewController = [[PlanItemSequenceViewController alloc] initWithNibName:nil bundle:nil];
        PCOSequenceItem *item = [[self.selectedItem orderedArrangementSequence] objectAtIndex:indexPath.row];
        viewController.title = item.label;
        viewController.plan = self.plan;
        viewController.selectedItem = self.selectedItem;
        viewController.stanza = stanza;
        
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"No Lyrics", nil)
                                                              message:NSLocalizedString(@"No lyrics for this section", nil)
                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)];
        [alertView show];
    }
}


#pragma mark -
#pragma mark - Lazy Loaders

- (PCOTableView *)sequenceTable {
    if (!_sequenceTable) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor sequenceTableCellBackgroundColor];
        table.separatorColor = [UIColor sequenceTableViewSeparatorColor];
        _sequenceTable = table;
        [table registerClass:[CustomSlideListTableViewCell class] forCellReuseIdentifier:kSequenceReorderTableViewCellIdentifier];
        table.editing = YES;
        table.allowsSelectionDuringEditing = YES;

        [self.tablesContainerView insertSubview:table aboveSubview:self.elementsTable];
    }
    return _sequenceTable;
}

- (PCOTableView *)elementsTable {
    if (!_elementsTable) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor elementsTableCellBackgroundColor];
        table.separatorColor = [UIColor elementsTableViewSeparatorColor];
        
        [self.tablesContainerView addSubview:table];
        _elementsTable = table;
    }
    return _elementsTable;
}

- (UIView *)tablesContainerView {
    if (!_tablesContainerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor sequenceTableViewBorderColor];
        view.clipsToBounds = YES;
        [self.view addSubview:view];
        _tablesContainerView = view;
    }
    return _tablesContainerView;
}

- (UIView *)instructionsContainerView {
    if (!_instructionsContainerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor sequenceInstructionsViewBackgroundColor];
        [self.view addSubview:view];
        _instructionsContainerView = view;
        
        view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor sequenceTableViewBorderColor];
        [_instructionsContainerView addSubview:view];
        [_instructionsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                               attribute:NSLayoutAttributeLeft
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:_instructionsContainerView
                                                                               attribute:NSLayoutAttributeLeft
                                                                              multiplier:1.0
                                                                                constant:0.0]];
        [_instructionsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:_instructionsContainerView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1.0
                                                                                constant:0.0]];
        [_instructionsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_instructionsContainerView
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
        [view addConstraint:[NSLayoutConstraint pco_height:1.0 forView:view]];
    }
    return _instructionsContainerView;
}

- (PCOLabel *)instructionsLabel {
    if (!_instructionsLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor sequenceInstructionsViewTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.backgroundColor = [UIColor clearColor];
        label.alpha = 0.0;
        label.text = NSLocalizedString(@"DRAG SONG SECTIONS      TO ADD", nil);
        
        UIImageView *iView = [UIImageView newAutoLayoutView];
        iView.backgroundColor = [UIColor clearColor];
        UIImage *image = [UIImage imageNamed:@"left-arrow-small"];
        iView.image = image;
        iView.contentMode = UIViewContentModeCenter;
        [label addSubview:iView];
        [label addConstraint:[NSLayoutConstraint constraintWithItem:iView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:label
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:55]];
        [label addConstraint:[NSLayoutConstraint pco_centerVertical:iView inView:label]];
        [label addConstraints:[NSLayoutConstraint pco_size:image.size forView:iView]];

        
        _instructionsLabel = label;
        [self.instructionsContainerView addSubview:label];
        [self.instructionsContainerView addConstraints:[NSLayoutConstraint pco_fitView:label inView:self.instructionsContainerView insets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    }
    return _instructionsLabel;
}

- (PCOButton *)addElementsButton {
    if (!_addElementsButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        [button setImage:[UIImage imageNamed:@"add-btn"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addElementsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:button aboveSubview:self.instructionsContainerView];
        _addElementsButton = button;
    }
    return _addElementsButton;
}

- (UISegmentedControl *)linkTypeSegmentedControl {
    if (!_linkTypeSegmentedControl) {
        UISegmentedControl *control = [UISegmentedControl newAutoLayoutView];
        [control insertSegmentWithTitle:NSLocalizedString(@"Arrangement", nil) atIndex:0 animated:NO];
        [control insertSegmentWithTitle:NSLocalizedString(@"Item", nil) atIndex:0 animated:NO];
        [control setSelectedSegmentIndex:1];
        [control addTarget:self action:@selector(linkTypeValueChanged:) forControlEvents:UIControlEventValueChanged];
        control.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        control.tintColor = [UIColor sequenceTableCellTitleColor];
        [self.view insertSubview:control aboveSubview:self.instructionsContainerView];
        _linkTypeSegmentedControl = control;
        [self.view bringSubviewToFront:self.itemLinkImageView];
        [self.view bringSubviewToFront:self.arrangementLinkImageView];
        self.itemLinkImageView.hidden = YES;
        self.arrangementLinkImageView.hidden = NO;
    }
    return _linkTypeSegmentedControl;
}

- (UIImageView *)itemLinkImageView {
    if (!_itemLinkImageView) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        view.image = [UIImage imageNamed:@"link_icon"];
        _itemLinkImageView = view;
        [self.view addSubview:view];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.linkTypeSegmentedControl
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.linkTypeSegmentedControl
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:25.0]];
    }
    return _itemLinkImageView;
}

- (UIImageView *)arrangementLinkImageView {
    if (!_arrangementLinkImageView) {
        UIImageView *view = [UIImageView newAutoLayoutView];
        view.contentMode = UIViewContentModeCenter;
        view.image = [UIImage imageNamed:@"link_icon"];
        _arrangementLinkImageView = view;
        [self.view addSubview:view];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.linkTypeSegmentedControl
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.linkTypeSegmentedControl
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:20.0]];
    }
    return _arrangementLinkImageView;
}

- (NSArray *)availableStanzas {
    if (!_availableStanzas) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        PCOArrangement *arrangement = self.selectedItem.arrangement;
        [array addObjectsFromArray:[arrangement orderedStanzaLabels]];
        
        BOOL introAdded = NO;
        BOOL outroAdded = NO;
        BOOL instrAdded = NO;
        NSRange range;
        
        for (NSUInteger i = 0; i < [array count]; i++) {
            range = [[array objectAtIndex:i] rangeOfString:@"intro" options:NSCaseInsensitiveSearch];
            if ( range.location != NSNotFound ) {
                introAdded = YES;
            }
            
            range = [[array objectAtIndex:i] rangeOfString:@"outro" options:NSCaseInsensitiveSearch];
            if ( range.location != NSNotFound ) {
                outroAdded = YES;
            }
            
            range = [[array objectAtIndex:i] rangeOfString:@"instrumental" options:NSCaseInsensitiveSearch];
            if ( range.location != NSNotFound ) {
                instrAdded = YES;
            }
        }
        if (!introAdded) {
            [array addObject:@"Intro"];
        }
        if (!outroAdded) {
            [array addObject:@"Outro"];
        }
        if (!instrAdded) {
            [array addObject:@"Instrumental"];
        }
        _availableStanzas = [NSArray arrayWithArray:array];
    }
    return _availableStanzas;
}


#pragma mark -
#pragma mark - Setter Methods


- (void)setSelectedItem:(PCOItem *)selectedItem {
    _selectedItem = selectedItem;
    self.title = selectedItem.name;
    
    [[[PCOCoreDataManager sharedManager] itemsController] updateSlideSequenceAndSectionsForItem:selectedItem completion:^(NSError *error) {
        PCOError(error);
    }];
}

#pragma mark -
#pragma mark - Action Methods

- (void)deleteSequenceAction:(PCOButton *)sender {
    NSInteger tag = sender.tag;
    [PROItemStanzaHelper removeStanzaAtIndex:tag item:self.selectedItem];
    [self.sequenceTable reloadData];
    [PCOEventLogger logEvent:@"Removed Sequence"];
}

- (void)showDeleteCell:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.sequenceTable];
    NSIndexPath *indexPath = [self.sequenceTable indexPathForRowAtPoint:location];
    SequenceReorderTableViewCell *cell = (SequenceReorderTableViewCell *)[self.sequenceTable cellForRowAtIndexPath:indexPath];
    if (!cell.deleteVisible) {
        [cell toggleDeleteAnimated:YES];
    }
}

- (void)hideDeleteCell:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.sequenceTable];
    NSIndexPath *indexPath = [self.sequenceTable indexPathForRowAtPoint:location];
    SequenceReorderTableViewCell *cell = (SequenceReorderTableViewCell *)[self.sequenceTable cellForRowAtIndexPath:indexPath];
    if (cell.deleteVisible) {
        [cell toggleDeleteAnimated:YES];
    }
}

#define AUTO_SCROLL_BUFFER 80
- (void)addNewStanzaGestureAction:(UILongPressGestureRecognizer *)longPress {
    CGPoint location = [longPress locationInView:self.elementsTable];
    NSIndexPath *pickUpIndexPath = [self.elementsTable indexPathForRowAtPoint:location];
    
    CGPoint dropPointInSequenceTable = [longPress locationInView:self.sequenceTable];
    NSLog(@"Drop Point: %@", NSStringFromCGPoint(dropPointInSequenceTable));
    NSIndexPath *dropIndexPath = [self.sequenceTable indexPathForRowAtPoint:dropPointInSequenceTable];
    if (dropIndexPath == nil) {
        if (CGRectContainsPoint(self.sequenceTable.frame, dropPointInSequenceTable) ) {
            dropIndexPath = [NSIndexPath indexPathForRow:[[self.selectedItem orderedArrangementSequence] count] inSection:0];
        }
    }
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        UITableViewCell *cell = [self.elementsTable cellForRowAtIndexPath:pickUpIndexPath];
        if (cell) {
            stanzaLabel = [self.availableStanzas objectAtIndex:pickUpIndexPath.row];
            CGRect elementsRect = cell.frame;
            CGRect viewFrame = [self.elementsTable convertRect:elementsRect toView:self.tablesContainerView];
            UIView *view = [self imageWithView:cell];
            view.frame = viewFrame;
            view.backgroundColor = [UIColor redColor];
            [self.tablesContainerView addSubview:view];
            _draggableView = view;
            [UIView animateWithDuration:0.2 animations:^{
                self.draggableView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                self.draggableView.alpha = 0.9;
            }];
        }
    }
    
    CGPoint center = self.draggableView.center;
    
    if (longPress.state == UIGestureRecognizerStateChanged) {
        CGPoint newPoint = [self.elementsTable convertPoint:location toView:self.tablesContainerView];
        center = newPoint;
        CGPoint hoverPoint = [longPress locationInView:self.view];
        CGFloat distanceFromBottom = self.sequenceTable.frame.size.height - hoverPoint.y;
        CGFloat distanceFromTop = hoverPoint.y;
        if (distanceFromBottom < AUTO_SCROLL_BUFFER || distanceFromTop < AUTO_SCROLL_BUFFER) {
            if (!autoScrolling && [self.sequenceTable numberOfRowsInSection:0] > 0) {
                if (distanceFromTop < AUTO_SCROLL_BUFFER) {
                    NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    NSLog(@"Scrolling to: %@", scrollToIndexPath);
                    [self.sequenceTable scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                else {
                    NSIndexPath *scrollToIndexPath = [NSIndexPath indexPathForRow:[[self.selectedItem orderedArrangementSequence] count] - 1 inSection:0];
                    NSLog(@"Scrolling to: %@", scrollToIndexPath);
                    [self.sequenceTable scrollToRowAtIndexPath:scrollToIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }
        }
        else {
            autoScrolling = NO;
            [self.sequenceTable setContentOffset:self.sequenceTable.contentOffset animated:NO];
        }
    }
    
    self.draggableView.center = center;
    
    if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled) {
        [self.draggableView removeFromSuperview];
        _draggableView = nil;
        if (dropIndexPath) {
            [PROItemStanzaHelper addStanzaWithLabel:stanzaLabel toItem:self.selectedItem index:dropIndexPath.row];
            [self.sequenceTable reloadData];
        }
    }
}

- (void)linkTypeValueChanged:(UISegmentedControl *)control {
    switch (control.selectedSegmentIndex) {
        case 0:
            self.selectedItem.saveSequenceToArrangement = @(NO);
            self.itemLinkImageView.hidden = NO;
            self.arrangementLinkImageView.hidden = YES;
            break;
        case 1:
            self.selectedItem.saveSequenceToArrangement = @(YES);
            self.itemLinkImageView.hidden = YES;
            self.arrangementLinkImageView.hidden = NO;
        default:
            break;
    }
}

- (void)addElementsButtonAction:(id)sender {
    isEditing = !isEditing;
    [self configureNavigationBarButtons];
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
        if (isEditing) {
            self.addElementsButton.transform = CGAffineTransformMakeRotation(M_PI_2/2.0);
            self.instructionsLabel.alpha = 1.0;
            self.linkTypeSegmentedControl.alpha = 0.0;
            self.itemLinkImageView.alpha = 0.0;
            self.arrangementLinkImageView.alpha = 0.0;
        }
        else {
            self.addElementsButton.transform = CGAffineTransformIdentity;
            self.instructionsLabel.alpha = 0.0;
            self.linkTypeSegmentedControl.alpha = 1.0;
            self.itemLinkImageView.alpha = 1.0;
            self.arrangementLinkImageView.alpha = 1.0;
        }
    } completion:^(BOOL finished) {
        [self.sequenceTable reloadData];
    }];
}

- (void)editLyricsAction:(id)sender {    
    EditLyricsViewController *viewController = [[EditLyricsViewController alloc] initWithNibName:nil bundle:nil];
    viewController.plan = self.plan;
    viewController.selectedItem = self.selectedItem;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)saveButtonAction:(id)sender {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if ([item.customView respondsToSelector:@selector(setColor:)]) {
        [((UIActivityIndicatorView *)item.customView) setColor:[UIColor projectorOrangeColor]];
    }
    if ([item.customView respondsToSelector:@selector(startAnimating)]) {
        [((UIActivityIndicatorView *)item.customView) startAnimating];
    }
    self.navigationItem.rightBarButtonItem = item;
    [[PlanItemEditingController sharedController] saveArrangementSequenceEditingChangesForItem:self.selectedItem inPlan:self.plan];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


@end
