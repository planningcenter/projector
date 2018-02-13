//
//  ItemEditorViewController.m
//  Projector
//
//  Created by Peter Fokos on 11/10/14.
//

#import "ItemEditorViewController.h"
#import "PRONavigationController.h"
#import "CommonNavButton.h"
#import "PlanEditingController.h"
#import "PlanEditItemNameTableViewCell.h"
#import "PlanEditItemTypeTableViewCell.h"
#import "PlanEditLengthTableViewCell.h"
#import "PlanEditItemSongLinkTableViewCell.h"
#import "PlanEditItemArrangementKeyTableViewCell.h"
#import "PlanEditItemPickerTableViewCell.h"
#import "SongListViewController.h"
#import "UIBarButtonItem+PCOKitAdditions.h"
#import "PROSlideManager.h"
#import "PlanItemEditingController.h"
#import "PlanEditorItemReorderViewController.h"

typedef NS_ENUM(NSInteger, EditItemType) {
    EditItemTypeNewItem             = 0,
    EditItemTypeNewSong             = 1,
    EditItemTypeNewHeader           = 2,
    EditItemTypeItem                = 3,
    EditItemTypeSong                = 4,
    EditItemTypeHeader              = 5,
};

typedef NS_ENUM(NSInteger, EditItemTableRow) {
    EditItemTableRowName            = 0,
    EditItemTableRowNewItemType     = 1,
    EditItemTableRowLength          = 2,
    EditItemTableRowSong            = 3,
    EditItemTableRowArrangementKey  = 4,
    EditItemTableRowPicker          = 5,
    EditItemTableRowCount           = 6,
};

@interface ItemEditorViewController () <UITextFieldDelegate> {
    
}

@property (nonatomic, strong) NSArray *viewContraints;

@property (nonatomic, weak) PCOTableView *tableView;
@property (nonatomic, weak) PCOButton *deleteButton;

@property (nonatomic) ArrangementKeySelected pickerType;

@end

@implementation ItemEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = HEX(0x393940); // customSlidesBorderColor];
    self.title = NSLocalizedString(@"Edit", nil);
    
    UIBarButtonItem * saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Save", nil)
                                                                                                              color:[UIColor customSlideSaveButtonColor]
                                                                                                             action:@selector(saveButtonAction:)
                                                                                                          backArrow:NO]];

    self.navigationItem.rightBarButtonItem = saveButtonItem;
    
    UIBarButtonItem * cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self customNavBarButtonWithText:NSLocalizedString(@"Cancel", nil)
                                                                                                                color:[UIColor sequenceTableViewBorderColor]
                                                                                                               action:@selector(cancelButtonAction:)
                                                                                                            backArrow:YES]];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view updateConstraintsIfNeeded];
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
    
    NSDictionary *metrics = @{};
    
    NSDictionary *views = @{
                            @"table": self.tableView,
                            @"delete": self.deleteButton,
                            };
    
    for (NSString *format in @[
                               @"H:|[table]|",
                               @"H:|[delete]|",
                               
                               @"V:|-1-[table]-1-[delete(==60)]|",
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
    return EditItemTableRowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger height = 0;
    EditItemType type = [self itemType];
    
    switch (indexPath.row) {

        case EditItemTableRowName:
            height = [PlanEditItemNameTableViewCell heightForCell];
            break;
            
        case EditItemTableRowNewItemType:
            height = 0;
            if ([self.selectedItem isNew]) {
                height = [PlanEditItemTypeTableViewCell heightForCell];
            }
            break;
            
        case EditItemTableRowLength:
            height = [PlanEditLengthTableViewCell heightForCell];
            if (type == EditItemTypeHeader || type == EditItemTypeNewHeader) {
                height = 0;
            }
            break;
            
        case EditItemTableRowSong:
            height = [PlanEditItemSongLinkTableViewCell heightForCell];
            if (type == EditItemTypeHeader || type == EditItemTypeNewHeader) {
                height = 0;
            }
            break;
        case EditItemTableRowArrangementKey:
            height = 0;
            if (type == EditItemTypeNewSong || type == EditItemTypeSong) {
                height = [PlanEditItemArrangementKeyTableViewCell heightForCell];
            }
            break;
        case EditItemTableRowPicker:
            height = 0;
            if (self.pickerType != ArrangementKeySelectedNone) {
                height = [PlanEditItemPickerTableViewCell heightForCell];
            }
            break;
        default:
            break;
    }
    return height;
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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"default"];
    cell.backgroundColor = [UIColor clearColor];
    NSString *cellName = @"";
    
    switch (indexPath.row) {
            
        case EditItemTableRowName:
        {
            PlanEditItemNameTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kPlanEditItemNameTableViewCellIdentifier];
            aCell.textField.delegate = self;
            aCell.textField.text = self.selectedItem.name;
            aCell.changeHandler = ^(NSString *name) {
                self.selectedItem.name = name;
            };
            return aCell;
            break;
        }
            
        case EditItemTableRowNewItemType:
        {
            PlanEditItemTypeTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kPlanEditItemTypeTableViewCellIdentifier];
            if ([self.selectedItem isTypeHeader]) {
                [aCell setIndex:ItemTypeSelectedHeader];
            }
            else {
                [aCell setIndex:ItemTypeSelectedItem];
            }
            aCell.changeHandler = ^(ItemTypeSelected index) {
                switch (index) {
                    case ItemTypeSelectedItem:
                        if (self.selectedItem.song) {
                            self.selectedItem.type = PCOItemTypePlanSong;
                        }
                        else {
                            self.selectedItem.type = PCOItemTypePlanItem;
                        }
                        break;
                        
                    case ItemTypeSelectedHeader:
                        self.selectedItem.type = PCOItemTypePlanHeader;
                        break;
                    default:
                        break;
                }
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

            };
            return aCell;
            break;
        }
            
        case EditItemTableRowLength:
        {
            PlanEditLengthTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kPlanEditLengthTableViewCellIdentifier];
            aCell.length = self.selectedItem.length;
            aCell.changeHandler = ^(NSNumber *length) {
                self.selectedItem.length = length;
            };
            return aCell;
            break;
        }
            
        case EditItemTableRowSong:
        {
            PlanEditItemSongLinkTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kPlanEditItemSongLinkTableViewCellIdentifier];
            if (self.selectedItem.song == nil) {
                aCell.titleLabel.text = NSLocalizedString(@"Link a Song", nil);
            }
            else {
                aCell.titleLabel.text = self.selectedItem.song.name;
            }
            return aCell;
            break;
        }
            
        case EditItemTableRowArrangementKey:
        {
            PlanEditItemArrangementKeyTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kPlanEditItemArrangementKeyTableViewCellIdentifier];
            aCell.arrangementTitle = self.selectedItem.arrangement.name;
            aCell.keyTitle = self.selectedItem.key.starting;
            aCell.state = self.pickerType;
            aCell.changeHandler = ^(ArrangementKeySelected state) {
                self.pickerType = state;
            };
            return aCell;
            break;
        }
            
        case EditItemTableRowPicker:
        {
            PlanEditItemPickerTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:kPlanEditItemPickerTableViewCellIdentifier];
            NSInteger selectedIndex = 0;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            if (self.pickerType == ArrangementKeySelectedArrangment) {
                for (PCOArrangement *arr in [self.selectedItem.song orderedArrangements]) {
                    [array addObject:arr.name];
                    if (arr == self.selectedItem.arrangement) {
                        selectedIndex = [[self.selectedItem.song orderedArrangements] indexOfObject:arr];
                    }
                }
            }
            else if (self.pickerType == ArrangementKeySelectedKey) {
                for (PCOKey *key in [self.selectedItem.arrangement orderedKeys]) {
                    [array addObject:key.starting];
                    if (key == self.selectedItem.key) {
                        selectedIndex = [[self.selectedItem.arrangement orderedKeys] indexOfObject:key];
                    }
                }
            }
            aCell.choices = array;
            aCell.changeHandler = ^(NSInteger index) {
                if (self.pickerType == ArrangementKeySelectedArrangment) {
                    PCOArrangement *arrangement = [[self.selectedItem.song orderedArrangements] objectAtIndex:index];
                    [self.selectedItem setSelectedArrangement:arrangement];
                    [self.selectedItem setSelectedKey:nil];
                    if ([[arrangement orderedKeys] count] > 0) {
                        PCOKey *key = [[arrangement orderedKeys] objectAtIndex:0];
                        [self.selectedItem setSelectedKey:key];
                    }
                    [self.tableView reloadData];
                }
                else if (self.pickerType == ArrangementKeySelectedKey) {
                    PCOKey *key = [[self.selectedItem.arrangement orderedKeys] objectAtIndex:index];
                    [self.selectedItem setSelectedKey:key];
                    [self.tableView reloadData];
                }

            };
            aCell.index = selectedIndex;
            return aCell;
            break;
        }
            
        default:
            break;
    }
    cell.textLabel.text = cellName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == EditItemTableRowSong) {
        SongListViewController *viewController = [[SongListViewController alloc] initWithNibName:nil bundle:nil];
        viewController.plan = self.plan;
        viewController.selectedItem = self.selectedItem;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark -
#pragma mark - Setters

- (void)setSelectedItem:(PCOItem *)selectedItem {
    _selectedItem = selectedItem;
    
    if (selectedItem.song) {
        [[[PCOCoreDataManager sharedManager] songsController] updateSong:self.selectedItem.song completion:^(PCOSong *song) {
            [[PCOCoreDataManager sharedManager] save:NULL];
            [self.tableView reloadData];
        }];
    }
}

- (void)setPickerType:(ArrangementKeySelected)pickerType {
    _pickerType = pickerType;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Lazy Loaders

- (PCOTableView *)tableView {
    if (!_tableView) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = HEX(0x25252A);
        table.separatorColor = HEX(0x393940);
        table.scrollEnabled = NO;

        [table registerClass:[PlanEditItemNameTableViewCell class] forCellReuseIdentifier:kPlanEditItemNameTableViewCellIdentifier];
        [table registerClass:[PlanEditItemTypeTableViewCell class] forCellReuseIdentifier:kPlanEditItemTypeTableViewCellIdentifier];
        [table registerClass:[PlanEditLengthTableViewCell class] forCellReuseIdentifier:kPlanEditLengthTableViewCellIdentifier];
        [table registerClass:[PlanEditItemSongLinkTableViewCell class] forCellReuseIdentifier:kPlanEditItemSongLinkTableViewCellIdentifier];
        [table registerClass:[PlanEditItemArrangementKeyTableViewCell class] forCellReuseIdentifier:kPlanEditItemArrangementKeyTableViewCellIdentifier];
        [table registerClass:[PlanEditItemPickerTableViewCell class] forCellReuseIdentifier:kPlanEditItemPickerTableViewCellIdentifier];

        [self.view addSubview:table];
        _tableView = table;
    }
    return _tableView;
}

- (PCOButton *)deleteButton {
    if (!_deleteButton) {
        PCOButton *button = [PCOButton newAutoLayoutView];
        [button setImage:[UIImage imageNamed:@"red_close"] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"DELETE ITEM", nil) forState:UIControlStateNormal];
        button.backgroundColor = HEX(0x1E1E22);
        button.titleLabel.font = [UIFont boldDefaultFontOfSize_16];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        [button setTitleColor:HEX(0xC64D3D) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _deleteButton = button;
    }
    return _deleteButton;
}

#pragma mark -
#pragma mark - Helper Methods

- (EditItemType)itemType {
    if ([self.selectedItem isNew]) {
        if ([self.selectedItem isTypeHeader]) {
            return EditItemTypeNewHeader;
        }
        else if ([self.selectedItem isTypeSong]) {
            return EditItemTypeNewSong;
        }
        else {
            return EditItemTypeNewItem;
        }
    }
    if ([self.selectedItem isTypeHeader]) {
        return EditItemTypeHeader;
    }
    else if ([self.selectedItem isTypeSong]) {
        return EditItemTypeSong;
    }
    return EditItemTypeItem;
}

- (PCOButton *)customNavBarButtonWithText:(NSString *)text color:(UIColor *)color action:(SEL)selector backArrow:(BOOL)backArrow {
    CGRect frame = [CommonNavButton frameWithText:text backArrow:backArrow];
    CommonNavButton *button = [[CommonNavButton alloc] initWithFrame:frame text:text color:color];
    if (backArrow) {
        [button showBackArrow];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}


#pragma mark -
#pragma mark - Action Methods

- (void)saveButtonAction:(id)sender {
    if ([self.selectedItem.name isEqualToString:@""]) {
        self.selectedItem.name = NSLocalizedString(@"New Item", nil);
    }
    if (self.plan.managedObjectContext.undoManager.groupingLevel == 1) {
        [self.plan.managedObjectContext.undoManager endUndoGrouping];
        self.plan.managedObjectContext.undoManager = nil;
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if ([item.customView respondsToSelector:@selector(setColor:)]) {
        [((UIActivityIndicatorView *)item.customView) setColor:[UIColor projectorOrangeColor]];
    }
    if ([item.customView respondsToSelector:@selector(startAnimating)]) {
        [((UIActivityIndicatorView *)item.customView) startAnimating];
    }
    self.navigationItem.rightBarButtonItem = item;

    [[PlanEditingController sharedController] saveItem:self.selectedItem inPlan:self.plan completionBlock:^{
        [[PCOCoreDataManager sharedManager] save:NULL];
        [self.delegate planItemWasSaved];
//        [[NSNotificationCenter defaultCenter] postNotificationName:PlanItemBackgroundChangedNotification object:self.selectedItem.objectID];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)cancelButtonAction:(id)sender {
    if (self.plan.managedObjectContext.undoManager.groupingLevel == 1) {
        [self.plan.managedObjectContext.undoManager endUndoGrouping];
        [self.plan.managedObjectContext.undoManager undo];
        self.plan.managedObjectContext.undoManager = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteButtonAction:(id)sender {
    if (self.plan.managedObjectContext.undoManager.groupingLevel == 1) {
        [self.plan.managedObjectContext.undoManager endUndoGrouping];
        self.plan.managedObjectContext.undoManager = nil;
    }
    [self.delegate planItemWasSaved];
    [[PlanEditingController sharedController] deleteItem:self.selectedItem inPlan:self.plan completionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


@end
