/*!
 * LESLyricsFontPickerController.m
 *
 *
 * Created by Skylar Schipper on 6/12/14
 */

#import "LESLyricsFontPickerController.h"

@interface LESLyricsFontPickerController ()

@property (nonatomic, strong) NSArray *fonts;

@end

@interface LESLyricsFontPickerFontObject : NSObject

@property (nonatomic, strong) NSArray *fonts;
@property (nonatomic, strong) NSString *name;

- (NSString *)indexTitle;

- (void)loadFonts;

@end

@interface _LyricFontNameObject : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSString *displayName;

@end

@implementation LESLyricsFontPickerController

- (void)loadView {
    [super loadView];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor projectorBlackColor];
    
    self.title = NSLocalizedString(@"Font Family", nil);
}

- (NSArray *)fonts {
    if (!_fonts) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:100];
        for (NSString *fontFamily in [UIFont familyNames]) {
            LESLyricsFontPickerFontObject *font = [[LESLyricsFontPickerFontObject alloc] init];
            font.name = fontFamily;
            [font loadFonts];
            [array addObject:font];
        }
        
        _fonts = [array sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]]];
    }
    return _fonts;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fonts.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LESLyricsFontPickerFontObject *object = self.fonts[section];
    return object.fonts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fontCell" forIndexPath:indexPath];
    
    LESLyricsFontPickerFontObject *object = self.fonts[indexPath.section];
    _LyricFontNameObject *fontName = object.fonts[indexPath.row];
    
    cell.textLabel.font = fontName.font;
    cell.textLabel.text = fontName.displayName;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([self.textLayout.fontName isEqualToString:fontName.name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    LESLyricsFontPickerFontObject *object = self.fonts[section];
    return object.name;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableSet *objects = [NSMutableSet setWithCapacity:self.fonts.count];
    for (LESLyricsFontPickerFontObject *obj in self.fonts) {
        [objects addObject:[obj indexTitle]];
    }
    return [[objects allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSUInteger section = 0;
    
    for (LESLyricsFontPickerFontObject *obj in self.fonts) {
        if ([[obj indexTitle] isEqualToString:title]) {
            return section;
        }
        section++;
    }
    
    return section;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LESLyricsFontPickerFontObject *object = self.fonts[indexPath.section];
    _LyricFontNameObject *fontName = object.fonts[indexPath.row];
    
    self.textLayout.fontName = fontName.name;
    
    [self.rootController updateUserInterfaceUpdateForObjectChange:self];
    
    NSArray *paths = [[tableView visibleCells] collectSafe:^id(id object) {
        UITableViewCell *cell = (UITableViewCell *)object;
        NSIndexPath *cellIndexPath = [tableView indexPathForCell:cell];
        if (cell.accessoryType != UITableViewCellAccessoryNone) {
            return cellIndexPath;
        }
        if ([indexPath isEqual:cellIndexPath]) {
            return cellIndexPath;
        }
        return nil;
    }];
    
    [tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end


@implementation LESLyricsFontPickerFontObject

- (void)loadFonts {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    NSString *familyName = [self.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (NSString *fontName in [UIFont fontNamesForFamilyName:self.name]) {
        _LyricFontNameObject *obj = [[_LyricFontNameObject alloc] init];
        obj.font = [UIFont fontWithName:fontName size:16.0];
        obj.name = fontName;
        
        NSString *display = [fontName stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        display = [display stringByReplacingOccurrencesOfString:familyName withString:self.name];
        
        obj.displayName = display;
        
        [array addObject:obj];
    }
    self.fonts = [array sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]]];
}
- (NSString *)indexTitle {
    if (self.name.length > 0) {
        return [[self.name substringToIndex:1] uppercaseString];
    }
    return @"#";
}

@end

@implementation _LyricFontNameObject

@end
