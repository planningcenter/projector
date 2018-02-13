//
//  SlideReorderHeaderTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 10/23/14.
//

#import "SlideReorderHeaderTableViewCell.h"

#define CELL_HEIGHT 44

@implementation SlideReorderHeaderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundView.backgroundColor = [UIColor customSlidesCellBackgroundColor];
    self.accessoryImage.hidden = YES;
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

@end

NSString *const kSlideReorderHeaderTableViewCellIdentifier = @"kSlideReorderHeaderTableViewCellIdentifier";
