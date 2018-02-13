/*!
 * PlanViewGridSelectedDecorationView.m
 *
 *
 * Created by Skylar Schipper on 3/21/14
 */

#import "PlanViewGridSelectedDecorationView.h"

@interface PlanViewGridSelectedDecorationView ()

@end

@implementation PlanViewGridSelectedDecorationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor currentItemGreenColor];
    }
    return self;
}

@end
