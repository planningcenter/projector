//
//  CommonNavButton.h
//  Projector
//
//  Created by Peter Fokos on 10/17/14.
//

#import "PCOButton.h"

@interface CommonNavButton : PCOButton

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text color:(UIColor *)color;
- (void)showBackArrow;

+ (CGRect)frameWithText:(NSString *)text backArrow:(BOOL)backArrow;

@end
