/*!
 * LogoPickerMediaDisplayCell.m
 *
 *
 * Created by Skylar Schipper on 7/1/14
 */

#import "LogoPickerMediaDisplayCell.h"

@interface LogoPickerMediaDisplayCell ()

@end

@implementation LogoPickerMediaDisplayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor mediaSelectedCellBackgroundColor];
    self.textLabel.textColor = [UIColor logoPickerCellTextColor];
    self.textLabel.font = [UIFont defaultFontOfSize_16];
    self.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    self.detailTextLabel.textColor = [UIColor logoPickerCellTextColor];
    self.detailTextLabel.font = [UIFont defaultFontOfSize_12];
}

@end
