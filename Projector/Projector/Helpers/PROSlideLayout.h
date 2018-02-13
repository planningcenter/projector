/*!
 * PROSlideLayout.h
 *
 *
 * Created by Skylar Schipper on 5/7/14
 */

#ifndef PROSlideLayout_h
#define PROSlideLayout_h

@import Foundation;

@class PCOSlideTextLayout;
@class PROSlideLabel;
@class PROSlideTextLabel;

@interface PROSlideLayout : NSObject <NSCopying>

- (instancetype)initWithLayout:(PCOSlideTextLayout *)layout;
- (void)configureTextLabel:(PROSlideTextLabel *)label;

- (void)prepareFont:(UIFont *(^)(UIFont *))prepare;

#if DEBUG
- (NSString *)debugDescription;
#endif

@end

#endif
