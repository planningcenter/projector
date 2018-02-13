/*!
 * UIFont+ProjectorBoldMaker.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 1/14/15
 */

#import "UIFont+ProjectorBoldMaker.h"

@implementation UIFont (ProjectorBoldMaker)

- (BOOL)isBold {
    return ((self.fontDescriptor.symbolicTraits & UIFontDescriptorTraitBold) == UIFontDescriptorTraitBold);
}
- (UIFont *)boldFont {
    UIFontDescriptorSymbolicTraits traits = self.fontDescriptor.symbolicTraits;
    traits |= UIFontDescriptorTraitBold;
    UIFontDescriptor *desc = [self.fontDescriptor fontDescriptorWithSymbolicTraits:traits];
    return [UIFont fontWithDescriptor:desc size:self.pointSize];
}

@end
