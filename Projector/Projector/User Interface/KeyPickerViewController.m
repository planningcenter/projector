//
//  KeyPickerViewController.m
//  Projector
//
//  Created by Peter Fokos on 11/18/14.
//

#import "KeyPickerViewController.h"

@interface KeyPickerViewController ()

@property (nonatomic, weak) PCOTableView *tableView;

@end

@implementation KeyPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Arrangements", nil);
    self.view.backgroundColor = [UIColor sequenceTableViewSeparatorColor];
    PCOKitLazyLoad(self.tableView);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.selectedItem.arrangement orderedKeys] count];
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
    PCOTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PCOTableViewCell"];
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView.backgroundColor = HEX(0x25252a);
    cell.textLabel.font = [UIFont defaultFontOfSize_14];
    cell.textLabel.textColor = HEX(0xc8cee0);
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = [UIColor blackColor];
    cell.selectedBackgroundView = selectedView;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = [[[self.selectedItem.arrangement orderedKeys] objectAtIndex:indexPath.row] starting];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOKey *key = [[self.selectedItem.arrangement orderedKeys] objectAtIndex:indexPath.row];
    [self.selectedItem setSelectedKey:key];
    NSArray *viewControllers = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[viewControllers objectAtIndex:1] animated:YES];
}

#pragma mark -
#pragma mark - Lazy Loaders

- (PCOTableView *)tableView {
    if (!_tableView) {
        PCOTableView *table = [PCOTableView newAutoLayoutView];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor sequenceTableCellBackgroundColor];
        table.separatorColor = [UIColor sequenceTableViewSeparatorColor];
        table.sectionIndexBackgroundColor = [UIColor clearColor];
        table.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        table.sectionIndexColor = HEX(0xc8cee0);
        _tableView = table;
        [table registerClass:[PCOTableViewCell class] forCellReuseIdentifier:@"PCOTableViewCell"];
        
        [self.view addSubview:table];
        [self.view addConstraints:[NSLayoutConstraint pco_fitView:table inView:self.view insets:UIEdgeInsetsMake(0, 0, 0, 0)]];
    }
    return _tableView;
}


@end
