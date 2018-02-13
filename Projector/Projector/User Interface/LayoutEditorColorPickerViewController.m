//
//  LayoutEditorColorPickerViewController.m
//  Projector
//
//  Created by Skylar Schipper on 6/23/14.
//

#import "LayoutEditorColorPickerViewController.h"
#import "LayoutEditorSidebarBaseTableViewCell.h"
#import "LayoutEditorColorPickerHexTableViewCell.h"
#import "PROSwitchTableViewCell.h"
#import "MCTColorPickerView.h"
#import "MCTColorPickerBarView.h"
#import "ColorPickerInputBarView.h"

typedef NS_ENUM(NSInteger, LayoutEditorColorPickerRow) {
    LayoutEditorColorPickerRowHEX    = 0,
    LayoutEditorColorPickerRowSat    = 1,
    LayoutEditorColorPickerRowHue    = 2,
    LayoutEditorColorPickerRow_Count = 3
};
typedef NS_ENUM(NSInteger, LayoutEditorColorPickerSection) {
    LayoutEditorColorPickerSectionPicker   = 0,
    LayoutEditorColorPickerSectionContrast = 1,
    LayoutEditorColorPickerSection_Count   = 2
};

static NSString *const LayoutEditorColorPickerHexTableViewCellIdentifier = @"LayoutEditorColorPickerHexTableViewCellIdentifier";
static NSString *const LayoutEditorSidebarBaseTableViewCellIdentifier = @"LayoutEditorSidebarBaseTableViewCell";

@interface LayoutEditorColorPickerViewController ()

@property (nonatomic, weak) LayoutEditorColorPickerHexTableViewCell *hexCell;
@property (nonatomic, strong) MCTColorPickerBarView *barView;
@property (nonatomic, strong) MCTColorPickerView *pickerView;

@end

@implementation LayoutEditorColorPickerViewController

- (void)loadView {
    [super loadView];
    
    if (!self.color) {
        self.color = [UIColor redColor];
    }
    
    self.title = NSLocalizedString(@"Color Picker", nil);
    
    [self.tableView registerClass:[PROSwitchTableViewCell class] forCellReuseIdentifier:PROSwitchTableViewCellIdentifier];
    [self.tableView registerClass:[LayoutEditorColorPickerHexTableViewCell class] forCellReuseIdentifier:LayoutEditorColorPickerHexTableViewCellIdentifier];
    [self.tableView registerClass:[LayoutEditorSidebarBaseTableViewCell class] forCellReuseIdentifier:LayoutEditorSidebarBaseTableViewCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateColor];
}

#pragma mark -
#pragma mark - Setters
- (void)setShowAutoContrastOption:(BOOL)showAutoContrastOption {
    _showAutoContrastOption = showAutoContrastOption;
    if (!showAutoContrastOption) {
        self.autoContrastColor = NO;
    }
    [self.tableView reloadData];
}
- (void)setColor:(UIColor *)color {
    _color = color;
    
    [self updateColor];
}
- (void)updateColor {
    [self.tableView reloadData];
    [self updateColorForTableLoad];
}
- (void)updateColorForTableLoad {
    welf();
    MCTHSV hsv = MCTCreateHSVFromColor([self.color CGColor]);
    [self.pickerView performSetup:^(MCTColorPickerView *view) {
        [welf.barView setHue:hsv.h];
        [view selectSaturation:hsv.s value:hsv.v];
    }];
    
    [self.pickerView updateColorsNotifyChangeHandler:NO];
}

#pragma mark -
#pragma mark - Lazy Loaders
- (MCTColorPickerBarView *)barView {
    if (!_barView) {
        _barView = [MCTColorPickerBarView newAutoLayoutView];
        _barView.pickerView = self.pickerView;
        _barView.pointView = [[ColorPickerInputBarView alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 24.0)];
    }
    return _barView;
}
- (MCTColorPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [MCTColorPickerView newAutoLayoutView];
        _pickerView.pointView = [[ColorPickerInputView alloc] initWithFrame:CGRectMake(0.0, 0.0, 24.0, 24.0)];
        welf();
        _pickerView.changeHandler = ^(id obj, UIColor *color) {
            welf.hexCell.color = color;
            UIColor *contrast = nil;
            if ([welf shouldAutoContrastColor]) {
                contrast = [color contrastColor];
            }
            [welf.pickerDelegate colorPicker:welf didPickColor:color withContrastColor:contrast];
            [welf.rootController updateUserInterfaceUpdateForObjectChange:welf];
        };
    }
    return _pickerView;
}

#pragma mark -
#pragma mark - Table View Data
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LayoutEditorColorPickerSectionPicker && indexPath.row == LayoutEditorColorPickerRowSat) {
        CGFloat height = CGRectGetWidth(tableView.bounds);
        if (![[PROAppDelegate delegate] isPad]) {
            height = CGRectGetHeight(tableView.bounds) - 100;
        }
        return height;
    }
    return 50.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return LayoutEditorColorPickerSection_Count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == LayoutEditorColorPickerSectionPicker) {
        return LayoutEditorColorPickerRow_Count;
    }
    if (section == LayoutEditorColorPickerSectionContrast) {
        if ([self shouldShowAutoContrastOption]) {
            return 1;
        }
        return 0;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    welf();
    
    if (indexPath.section == LayoutEditorColorPickerSectionContrast) {
        PROSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PROSwitchTableViewCellIdentifier forIndexPath:indexPath];
        [LayoutEditorSidebarBaseTableViewCell configureCell:cell];
        cell.textLabel.text = NSLocalizedString(@"Auto Contrast Text Color", nil);
        [cell setOn:[self shouldAutoContrastColor]];
        cell.valueChanged = ^(BOOL value) {
            welf.autoContrastColor = value;
        };
        return cell;
    }
    
    if (indexPath.section == LayoutEditorColorPickerSectionPicker) {
        if (indexPath.row == LayoutEditorColorPickerRowHEX) {
            LayoutEditorColorPickerHexTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LayoutEditorColorPickerHexTableViewCellIdentifier forIndexPath:indexPath];
            cell.color = self.color;
            cell.hexColorStringChangeHandler = ^(UIColor *color) {
                welf.color = color;
            };
            
            self.hexCell = cell;
            
            return cell;
        }
        if (indexPath.row == LayoutEditorColorPickerRowSat) {
            LayoutEditorSidebarBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LayoutEditorSidebarBaseTableViewCellIdentifier forIndexPath:indexPath];
            [self.pickerView removeFromSuperview];
            
            [cell.contentView addSubview:self.pickerView];
            UIEdgeInsets insets = UIEdgeInsetsZero;
            if (![[PROAppDelegate delegate] isPad]) {
                insets = UIEdgeInsetsMake(0, 10, 0, 60);
            }
            [cell.contentView addConstraints:[NSLayoutConstraint insetViewInSuperview:self.pickerView insets:insets]];
            
            [cell layoutIfNeeded];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self updateColorForTableLoad];
            
            return cell;
        }
        if (indexPath.row == LayoutEditorColorPickerRowHue) {
            LayoutEditorSidebarBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LayoutEditorSidebarBaseTableViewCellIdentifier forIndexPath:indexPath];
            [self.barView removeFromSuperview];
            
            [cell.contentView addSubview:self.barView];
            UIEdgeInsets insets = UIEdgeInsetsZero;
            if (![[PROAppDelegate delegate] isPad]) {
                insets = UIEdgeInsetsMake(0, 10, 0, 60);
            }
            [cell.contentView addConstraints:[NSLayoutConstraint insetViewInSuperview:self.barView insets:insets]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            [cell layoutIfNeeded];
            
            [self updateColorForTableLoad];
            
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
}


@end
