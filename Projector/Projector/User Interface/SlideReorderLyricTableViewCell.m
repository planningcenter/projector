//
//  SlideReorderLyricTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 10/23/14.
//

#import "SlideReorderLyricTableViewCell.h"

#define CELL_HEIGHT 44

@implementation SlideReorderLyricTableViewCell

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
    self.accessoryImage.hidden = YES;
    self.backgroundColor = [UIColor customSlidesListBackgroundColor];
    self.backgroundView.backgroundColor = [UIColor customSlidesListBackgroundColor];
}

+ (CGFloat)heightForCell {
    return CELL_HEIGHT;
}

@end

NSString *const kSlideReorderLyricTableViewCellIdentifier = @"kSlideReorderLyricTableViewCellIdentifier";
