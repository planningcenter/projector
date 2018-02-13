//
//  PlanItemSequenceViewController.m
//  Projector
//
//  Created by Peter Fokos on 10/22/14.
//

#import "PlanItemSequenceViewController.h"
#import "CommonNavButton.h"
#import "NSLayoutConstraint+PCOKitAdditions.h"
#import "PRONavigationController.h"
#import "SlideReorderHeaderTableViewCell.h"
#import "SlideReorderLyricTableViewCell.h"
#import "PCOStanza.h"
#import "PCOSlideBreak.h"
#import "PROSlideManager.h"
#import "PlanItemEditingController.h"
#import "PROSlideItem.h"

#define DRAG_VIEW_HEIGHT 60

@interface PlanItemSequenceViewController ()

@property (nonatomic, strong) NSArray *viewContraints;

@property (nonatomic, weak) PCOTableView *tableView;

@property (nonatomic, weak) UIView *dividerView;
@property (nonatomic, weak) UIView *dragContainerView;
@property (nonatomic, weak) UIView *dragableView;

@property (nonatomic) BOOL draggingAddNew;

@property (nonatomic, strong) NSMutableArray *lyrics;

@property (nonatomic) BOOL sequenceChanged;

@end

@implementation PlanItemSequenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Save", nil)
                                                                                                              color:[UIColor customSlideSaveButtonColor]
                                                                                                             action:@selector(saveButtonAction:)
                                                                                                          backArrow:NO]];
    self.navigationItem.rightBarButtonItem = saveButtonItem;
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Sequence", nil)
                                                                                                                color:[UIColor sequenceTableViewBorderColor]
                                                                                                               action:@selector(cancelButtonAction:)
                                                                                                            backArrow:YES]];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.sequenceChanged = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PRONavigationController *proNav = (PRONavigationController *)[self navigationController];
    proNav.navigationBar.barTintColor = [UIColor layoutControllerToolbarBackgroundColor];
    self.view.backgroundColor = [UIColor customSlidesBorderColor];
    [self.view updateConstraintsIfNeeded];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Setters

- (void)setSelectedItem:(PCOItem *)selectedItem {
    _selectedItem = selectedItem;
    [[PCOCoreDataManager sharedManager] save:NULL];
    [self.tableView reloadData];
}

- (void)setStanza:(PCOStanza *)stanza {
    _stanza = stanza;
    [self.tableView reloadData];
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
                            @"table": self.tableView,
                            @"drag_view": self.dragContainerView,
                            @"dragable_view": self.dragableView,
                            @"divider_view": self.dividerView,
                            };
    
    for (NSString *format in @[
                               @"H:|[table]|",
                               @"H:|[drag_view]|",
                               @"H:|[dragable_view]|",
                               @"H:|[divider_view]|",
                               
                               @"V:|-1-[table][divider_view(==1)][drag_view(==drag_view_height)]|",
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
    return [self.lyrics count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([self lyricIsSlideHeaderAtRow:indexPath.row]) {
        CustomSlideListTableViewCell *reorderCell = (CustomSlideListTableViewCell *)cell;
        [reorderCell repositionReorderControl];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0 && [self lyricIsSlideHeaderAtRow:indexPath.row]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.row == destinationIndexPath.row) return;
    NSString *from = [[self.lyrics objectAtIndex:sourceIndexPath.row] copy];

    [PCOEventLogger logEvent:@"Changed Plan Item Sequence"];
    
    [self.lyrics removeObjectAtIndex:sourceIndexPath.row];
    [self.lyrics insertObject:from atIndex:destinationIndexPath.row];
    self.sequenceChanged = YES;
    
    [self renumberSlideBreaks];
    
    if (destinationIndexPath.row == 0 || destinationIndexPath.row == (NSInteger)([self.lyrics count] - 1)) {
        [self performSelector:@selector(deleteARow:) withObject:destinationIndexPath afterDelay:0.2];
    } else {
        [self.tableView reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self lyricIsSlideHeaderAtRow:indexPath.row]) {
        SlideReorderHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSlideReorderHeaderTableViewCellIdentifier];
        cell.titleLabel.text = [self lyricAtRow:indexPath.row];
        cell.reorderImage.hidden = YES;
        if (indexPath.row > 0) {
            cell.reorderImage.hidden = NO;
            [cell.swipeLeft addTarget:self action:@selector(showDeleteCell:)];
            [cell.swipeRight addTarget:self action:@selector(hideDeleteCell:)];
            cell.deleteButton.tag = indexPath.row;
            [cell.deleteButton addTarget:self action:@selector(deleteSlideAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }
    SlideReorderLyricTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSlideReorderLyricTableViewCellIdentifier];
    cell.reorderImage.hidden = YES;
    cell.titleLabel.text = [self lyricAtRow:indexPath.row];
    return cell;
}

#pragma mark -
#pragma mark - Helper Methods

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector backArrow:(BOOL)backArrow {
    CGRect frame = [CommonNavButton frameWithText:text backArrow:backArrow];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    if (backArrow) {
        [button showBackArrow];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSString *)lyricAtRow:(NSInteger)row {
    NSString *rowString = @"";
    
    if ([self lyricIsSlideHeaderAtRow:row]) {
        rowString = [[self.lyrics objectAtIndex:row] substringFromIndex:4];
    }
    else {
        rowString = [self.lyrics objectAtIndex:row];
    }
    return rowString;
}

- (BOOL)lyricIsSlideHeaderAtRow:(NSInteger)row {
    NSRange lineRange = [[self.lyrics objectAtIndex:row] rangeOfString:SlideNumberText];
    if ( lineRange.location != NSNotFound ) {
        return YES;
    }
    return NO;
}

- (void)renumberSlideBreaks {
    NSInteger slideNumber = 1;
    
    for (NSUInteger lineIndex = 0; lineIndex < [self.lyrics count]; lineIndex++) {
        NSString *line = [self.lyrics objectAtIndex:lineIndex];
        NSRange lineRange = [line rangeOfString:SlideNumberText];
        if ( lineRange.location != NSNotFound )
        {
            NSString *newLine = [NSString stringWithFormat:@">>> Slide %ld", (long)slideNumber];
            slideNumber++;
            [self.lyrics replaceObjectAtIndex:lineIndex withObject:newLine];
        }
    }
}

- (void)deleteARow:(NSIndexPath *)indexPath {
    [self.lyrics removeObjectAtIndex:indexPath.row];
    self.sequenceChanged = YES;
    [self renumberSlideBreaks];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Lazy Loaders

- (PCOTableView *)tableView {
    if (!_tableView) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor customSlidesListBackgroundColor];
        table.separatorColor = [UIColor customSlidesTableViewSeparatorColor];
        table.editing = YES;
        table.allowsSelectionDuringEditing = YES;
        [table registerClass:[SlideReorderHeaderTableViewCell class] forCellReuseIdentifier:kSlideReorderHeaderTableViewCellIdentifier];
        [table registerClass:[SlideReorderLyricTableViewCell class] forCellReuseIdentifier:kSlideReorderLyricTableViewCellIdentifier];
        [self.view addSubview:table];
        _tableView = table;
    }
    return _tableView;
}

- (UIView *)dividerView {
    if (!_dividerView) {
        UIView *view = [UIView newAutoLayoutView];
        view.backgroundColor = [UIColor rgbColorWithRed:66 green:66 blue:75 alpha:1.0];
        [self.view addSubview:view];
        _dividerView = view;
    }
    return _dividerView;
}

- (UIView *)dragView {
    UIView *view = [UIView newAutoLayoutView];
    view.backgroundColor = [UIColor customSlidesDragAreaBackgroundColor];
    
    UIImageView *iView = [UIImageView newAutoLayoutView];
    iView.backgroundColor = [UIColor clearColor];
    UIImage *image = [UIImage imageNamed:@"plus_icon"];
    iView.image = image;
    iView.contentMode = UIViewContentModeCenter;
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
    label.text = NSLocalizedString(@"Slide Break", nil);
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

- (NSMutableArray *)lyrics {
    if (!_lyrics) {
        if (_stanza) {
            NSUInteger linesPerSlide = [PROSlideItem numberOfLinesPerSlideForItem:self.selectedItem];
            // let the stanza create slide breaks if there aren't any already
            [self.stanza autoGenerateSlideBreaksForLayoutWithDefaultLineCount:linesPerSlide];
            
            // where do the slide break up in the lines of lyrics?
            PCOSlideBreak *slideBreaks = [self.stanza slideBreakDictionaryWithNumberOfLinesPerSlide:linesPerSlide];
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            NSArray * stanzaLyrics = [self.stanza.lyrics componentsSeparatedByString:@"\n"];
            
            
            NSInteger lineNumber = 0;
            [array addObject:@">>> Slide 1"];
            NSInteger slideNumber = 2;
            for (NSString *aLine in stanzaLyrics)
            {
                if ([[aLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 1)
                {
                    [array addObject:[aLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                }
                else
                {
                    [array addObject:@" "];
                }
                
                for (NSNumber *breakAfterLineNumber in [slideBreaks breakLineIndexes]) {
                    if ([breakAfterLineNumber intValue] == lineNumber )
                    {
                        NSString *slideHeader = [NSString stringWithFormat:@">>> Slide %ld", (long)slideNumber];
                        [array addObject:slideHeader];
                        slideNumber++;
                    }
                }
                lineNumber++;
            }
            _lyrics = array;
        }
    }
    return _lyrics;
}


#pragma mark -
#pragma mark - Action Methods

- (void)deleteSlideAction:(PCOButton *)sender {
    NSInteger tag = sender.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    [self deleteARow:indexPath];
    [PCOEventLogger logEvent:@"Removed Slide Break"];
}

- (void)showDeleteCell:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    SlideReorderHeaderTableViewCell *cell = (SlideReorderHeaderTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (!cell.deleteVisible) {
        [cell toggleDeleteAnimated:YES];
    }
}

- (void)hideDeleteCell:(UISwipeGestureRecognizer *)swipe {
    CGPoint location = [swipe locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    SlideReorderHeaderTableViewCell *cell = (SlideReorderHeaderTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.deleteVisible) {
        [cell toggleDeleteAnimated:YES];
    }
}

- (void)addNewBarGestureAction:(UILongPressGestureRecognizer *)longPress {
    CGPoint location = [longPress locationInView:self.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[longPress locationInView:self.tableView]];
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
    [self.lyrics addObject:SlideNumberText];
    [self addNewItemAtIndexPath:nil];
}

- (void)addNewItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) {
        [self.lyrics insertObject:SlideNumberText atIndex:indexPath.row];
    }
    [PCOEventLogger logEvent:@"Added Slide Break"];
    self.sequenceChanged = YES;
    [self renumberSlideBreaks];
    [self.view setNeedsUpdateConstraints];
    [self.tableView reloadData];
}

- (void)saveButtonAction:(id)sender {
    if (self.sequenceChanged) {
        [[PCOCoreDataManager sharedManager] save:NULL];
        BOOL result = [[PlanItemEditingController sharedController] saveSlideBreaksForItem:self.selectedItem inPlan:self.plan withStanza:self.stanza lyrics:self.lyrics completionBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        if (result) {
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
