/*!
 * PlanViewGridSectionHeaderHeaderItem.m
 *
 *
 * Created by Skylar Schipper on 3/17/14
 */

#import "PlanViewGridSectionHeaderItemHeader.h"

@interface PlanViewGridSectionHeaderHeaderView : PlanViewGridSectionHeaderView

@end

@interface PlanViewGridSectionHeaderItemHeader ()

@end

@implementation PlanViewGridSectionHeaderItemHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.view.backgroundColor = [UIColor planGridSectionHeaderItemHeaderBackgroundColor];
        self.view.titleLabel.textColor = [UIColor planGridSectionHeaderItemHeaderTextColor];
    }
    return self;
}


+ (Class)headerViewClass {
    return [PlanViewGridSectionHeaderHeaderView class];
}

@end

@implementation PlanViewGridSectionHeaderMobileItemHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.view.backgroundColor = [UIColor planGridSectionHeaderItemHeaderBackgroundColor];
        self.view.titleLabel.textColor = [UIColor planGridSectionHeaderItemHeaderTextColor];
    }
    return self;
}

+ (Class)headerViewClass {
    return [PlanViewGridSectionHeaderHeaderView class];
}

@end

@implementation PlanViewGridSectionHeaderHeaderView

- (void)setState:(PlanViewGridSectionState)state {
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    // I have no idea what's setting this after init... Stack trace is worthless, so... Here we are -- SS
    [super setBackgroundColor:[UIColor planGridSectionHeaderItemHeaderBackgroundColor]];
}

@end
