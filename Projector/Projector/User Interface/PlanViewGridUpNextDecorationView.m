/*!
 * PlanViewGridUpNextDecorationView.m
 *
 *
 * Created by Skylar Schipper on 3/21/14
 */

#import "PlanViewGridUpNextDecorationView.h"

@interface PlanViewGridUpNextDecorationView ()

@end

@implementation PlanViewGridUpNextDecorationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor nextUpItemBlueColor];
    }
    return self;
}

@end
