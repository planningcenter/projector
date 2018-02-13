/*!
 * PROAddBarButtonItem.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/12/14
 */

#import "PROAddBarButtonItem.h"

@interface PROAddBarButtonItem ()

@end

@implementation PROAddBarButtonItem

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    UIImage *image = [UIImage templateImageNamed:@"plus_icon"];
    
    UIButton *button = [[UIButton alloc] initWithFrame:(CGRect){CGPointZero, image.size}];
    
    [button setImage:image forState:UIControlStateNormal];
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [super initWithCustomView:button];
}

@end
