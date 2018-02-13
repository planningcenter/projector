/*!
 * PRODisplayItem.m
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#import "PRODisplayItem.h"
#import "PROSlide.h"

@interface PRODisplayItem ()

@end

@implementation PRODisplayItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.background = [[PRODisplayItemBackground alloc] init];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p (%@)>",NSStringFromClass([self class]),self,self.titleString];
}

- (void)configureForSlide:(PROSlide *)slide {
    self.titleString = slide.label;
    self.text = slide.text;
    self.textLayout = slide.textLayout;
    self.background.backgroundColor = slide.backgroundColor;
    self.background.primaryBackgroundURL = slide.backgroundFileURL;
    self.background.staticBackgroundURL = slide.backgroundThumbnailURL;
    self.infoText = slide.copyright;
    self.infoLayout = slide.infoLayout;
    self.performCustomWrap = [slide shouldPerformCustomWrap];
    self.contentMode = slide.contentMode;
    self.serviceTypeID = slide.serviceTypeID;
}

@end
