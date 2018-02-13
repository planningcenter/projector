/*!
 * LESSongInfoOptionsShowController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 10/3/14
 */

#import "LESSongInfoOptionsShowController.h"

@interface LESSongInfoOptionsShowController ()

@end

@implementation LESSongInfoOptionsShowController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Show on Slides", nil);
}

- (void)setTextLayout:(PCOSlideTextLayout *)textLayout {
    [super setTextLayout:textLayout];
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    BOOL all = [self.textLayout.showOnAllSlides boolValue];
    BOOL first = [self.textLayout.showOnlyOnFirstSlide boolValue];
    BOOL last = [self.textLayout.showOnlyOnLastSlide boolValue];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"All", nil);
            if (all) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"First", nil);
            if (first) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Last", nil);
            if (last) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"None", nil);
            if (!last && !first && !all) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.textLayout.showOnAllSlides = @NO;
    self.textLayout.showOnlyOnFirstSlide = @NO;
    self.textLayout.showOnlyOnLastSlide = @NO;
    
    switch (indexPath.row) {
        case 0:
            self.textLayout.showOnAllSlides = @YES;
            break;
        case 1:
            self.textLayout.showOnlyOnFirstSlide = @YES;
            break;
        case 2:
            self.textLayout.showOnlyOnLastSlide = @YES;
            break;
            
        default:
            break;
    }
    
    [tableView reloadData];
}

- (BOOL)useCurrentTextLayout {
    return NO;
}

@end
