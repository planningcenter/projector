//
//  PRORecordingListTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 6/3/15.
//

#import "PRORecordingListTableViewCell.h"

#define CELL_HEIGHT 60

@implementation PRORecordingListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = RGB(37, 37, 44);
    self.backgroundView.backgroundColor = RGB(37, 37, 44);
    self.textLabel.font = [UIFont defaultFontOfSize_16];
    self.detailTextLabel.font = [UIFont defaultFontOfSize_14];
    self.textLabel.textColor = RGB(119, 121, 134);
    self.detailTextLabel.textColor = RGB(73, 73, 82);
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green-circle-check"]];
    self.accessoryView.hidden = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self showCheckMark:NO];
    self.textLabel.textColor = RGB(119, 121, 134);
}

- (void)showCheckMark:(BOOL)show {
    self.accessoryView.hidden = !show;
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

@end

NSString *const kPRORecordingListTableViewCellIdentifier = @"kPRORecordingListTableViewCellIdentifier";
