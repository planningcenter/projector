/*!
 * LESGeneralPresetColorTableViewController.m
 *
 *
 * Created by Skylar Schipper on 6/12/14
 */

#import "LESGeneralPresetColorTableViewController.h"
#import "LayoutEditorSidebarBaseTableViewCell.h"

static NSString *const kPresetColorName = @"name";
static NSString *const kPresetColorTextBackground = @"textColor";
static NSString *const kPresetColorBackground = @"backgroundColor";
static NSString *const kPresetColorStrokeColor = @"strokeColor";

@interface LESGeneralPresetColorTableViewController ()

@property (nonatomic, strong) NSArray *presetColors;

@end

@implementation LESGeneralPresetColorTableViewController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Preset Colors", nil);
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSArray *)presetColors {
    if (!_presetColors) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"LayoutColorPresets" ofType:@"plist"];
        NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:path];
        if (info) {
            _presetColors = info[@"colors"];
        }
        if (!_presetColors) {
            _presetColors = @[];
        }
    }
    return _presetColors;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.presetColors.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LayoutEditorSidebarBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorCell" forIndexPath:indexPath];
    
    NSDictionary *info = self.presetColors[indexPath.row];
    
    cell.textLabel.text = [info[kPresetColorName] uppercaseString];
    cell.textLabel.textColor = [self colorFromRGBString:info[kPresetColorTextBackground]];
    cell.textLabel.shadowColor = [self colorFromRGBString:info[kPresetColorStrokeColor]];
    cell.textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    
    cell.backgroundColor = [self colorFromRGBString:info[kPresetColorBackground]];
    cell.contentView.backgroundColor = cell.backgroundColor;
    
    return cell;
}

- (UIColor *)colorFromRGBString:(NSString *)string {
    if (string.length == 0) {
        return [UIColor layoutControllerPreviewBackgroundColor];
    }
    static NSNumberFormatter *num;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        num = [[NSNumberFormatter alloc] init];
        num.numberStyle = NSNumberFormatterDecimalStyle;
    });
    
    NSArray *components = [string componentsSeparatedByString:@","];
    if (components.count >= 3) {
        NSNumber *red = [num numberFromString:components[0]];
        NSNumber *green = [num numberFromString:components[1]];
        NSNumber *blue = [num numberFromString:components[2]];
        return pco_kit_RGB([red floatValue], [green floatValue], [blue floatValue]);
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *info = self.presetColors[indexPath.row];
    
    self.layout.backgroundColor = [self colorFromRGBString:info[kPresetColorBackground]];
    self.layout.lyricTextLayout.fontColor = [self colorFromRGBString:info[kPresetColorTextBackground]];
    self.layout.lyricTextLayout.fontShadowColor = [self colorFromRGBString:info[kPresetColorStrokeColor]];
    
    [self.rootController updateUserInterfaceUpdateForObjectChange:self animated:YES];
}

@end
