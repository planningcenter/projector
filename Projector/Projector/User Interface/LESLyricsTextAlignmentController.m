/*!
 * LESLyricsAlignmentVerticalController.m
 *
 *
 * Created by Skylar Schipper on 6/16/14
 */

#import "LESLyricsTextAlignmentController.h"

typedef NS_ENUM(NSInteger, LESLyricsTableViewSections) {
    LESLyricsTableViewSectionVertical   = 0,
    LESLyricsTableViewSectionHorizontal = 1,
    LESLyricsTableViewSection_Count     = 2
};
typedef NS_ENUM(NSInteger, LESLyricsAlignmentVerticalRow) {
    LESLyricsAlignmentVerticalRowTop    = 0,
    LESLyricsAlignmentVerticalRowMiddle = 1,
    LESLyricsAlignmentVerticalRowBottom = 2,
    LESLyricsAlignmentVerticalRow_Count = 3
};
typedef NS_ENUM(NSInteger, LESLyricsAlignmentHorizontalRow) {
    LESLyricsAlignmentHorizontalRowLeft   = 0,
    LESLyricsAlignmentHorizontalRowCenter = 1,
    LESLyricsAlignmentHorizontalRowRight  = 2,
    LESLyricsAlignmentHorizontalRow_Count = 3
};

@interface LESLyricsTextAlignmentController ()

@end

@implementation LESLyricsTextAlignmentController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Alignment and Position", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return LESLyricsTableViewSection_Count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == LESLyricsTableViewSectionVertical) {
        return LESLyricsAlignmentVerticalRow_Count;
    }
    if (section == LESLyricsTableViewSectionHorizontal) {
        return LESLyricsAlignmentHorizontalRow_Count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"baseCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == LESLyricsTableViewSectionVertical) {
        switch (indexPath.row) {
            case LESLyricsAlignmentVerticalRowTop:
                cell.textLabel.text = NSLocalizedString(@"Top", nil);
                if ([self.textLayout.verticalAlignment isEqualToString:kPCOSlideTextVerticalAlignmentTop]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case LESLyricsAlignmentVerticalRowMiddle:
                cell.textLabel.text = NSLocalizedString(@"Middle", nil);
                if ([self.textLayout.verticalAlignment isEqualToString:kPCOSlideTextVerticalAlignmentMiddle]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case LESLyricsAlignmentVerticalRowBottom:
                cell.textLabel.text = NSLocalizedString(@"Bottom", nil);
                if ([self.textLayout.verticalAlignment isEqualToString:kPCOSlideTextVerticalAlignmentBottom]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            default:
                break;
        }
    }
    if (indexPath.section == LESLyricsTableViewSectionHorizontal) {
        switch (indexPath.row) {
            case LESLyricsAlignmentHorizontalRowLeft:
                cell.textLabel.text = NSLocalizedString(@"Left", nil);
                if ([self.textLayout.textAlignment isEqualToString:kPCOSlideTextAlignmentLeft]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case LESLyricsAlignmentHorizontalRowCenter:
                cell.textLabel.text = NSLocalizedString(@"Center", nil);
                if ([self.textLayout.textAlignment isEqualToString:kPCOSlideTextAlignmentCenter]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case LESLyricsAlignmentHorizontalRowRight:
                cell.textLabel.text = NSLocalizedString(@"Right", nil);
                if ([self.textLayout.textAlignment isEqualToString:kPCOSlideTextAlignmentRight]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == LESLyricsTableViewSectionVertical) {
        return NSLocalizedString(@"Vertical", nil);
    }
    if (section == LESLyricsTableViewSectionHorizontal) {
        return NSLocalizedString(@"Horizontal", nil);
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == LESLyricsTableViewSectionVertical) {
        switch (indexPath.row) {
            case LESLyricsAlignmentVerticalRowTop:
                self.textLayout.verticalAlignment = kPCOSlideTextVerticalAlignmentTop;
                break;
            case LESLyricsAlignmentVerticalRowMiddle:
                self.textLayout.verticalAlignment = kPCOSlideTextVerticalAlignmentMiddle;
                break;
            case LESLyricsAlignmentVerticalRowBottom:
                self.textLayout.verticalAlignment = kPCOSlideTextVerticalAlignmentBottom;
                break;
            default:
                break;
        }
    }
    if (indexPath.section == LESLyricsTableViewSectionHorizontal) {
        switch (indexPath.row) {
            case LESLyricsAlignmentHorizontalRowLeft:
                self.textLayout.textAlignment = kPCOSlideTextAlignmentLeft;
                break;
            case LESLyricsAlignmentHorizontalRowCenter:
                self.textLayout.textAlignment = kPCOSlideTextAlignmentCenter;
                break;
            case LESLyricsAlignmentHorizontalRowRight:
                self.textLayout.textAlignment = kPCOSlideTextAlignmentRight;
                break;
            default:
                break;
        }
    }
    [self.rootController updateUserInterfaceUpdateForObjectChange:self];
    [tableView reloadData];
}

@end
