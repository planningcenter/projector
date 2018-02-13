/*!
 * LayoutTableViewHeaderView.m
 *
 *
 * Created by Skylar Schipper on 5/13/14
 */

#import "LayoutTableViewHeaderView.h"

@interface LayoutTableViewHeaderView ()

@end

@implementation LayoutTableViewHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor layoutListSectionHeaderColor];
        self.textLabel.textColor = [UIColor layoutListSectionStrokeColor];
    }
    return self;
}

@end
