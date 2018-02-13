/*!
 * PROSlideTextLabel.h
 *
 *
 * Created by Skylar Schipper on 6/18/14
 */

#ifndef PROSlideTextLabel_h
#define PROSlideTextLabel_h

@import UIKit;

typedef NS_ENUM(NSUInteger, PROTextVertialAlignment) {
    PROTextVertialAlignmentTop    = 0,
    PROTextVertialAlignmentCenter = 1,
    PROTextVertialAlignmentBottom = 2
};

@interface PROSlideTextLabel : UIView

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) NSString *text;

@property (nonatomic) UIEdgeInsets textInsets;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, copy) void(^boundsChangedHandler)(PROSlideTextLabel *label, CGRect bounds);

@property (nonatomic, strong) NSShadow *shadow;

@property (nonatomic) BOOL seperatorLineOn;

@property (nonatomic) CGFloat lineSpacing;

@property (nonatomic) NSInteger maxNumberOfLines;

- (void)updateIfNeeded;

- (void)adjustFontToFit;

+ (NSString *)sampleLyricText;
+ (NSString *)sampleLyricTextWithMaxLines:(NSInteger)maxLines;

#pragma mark -
#pragma mark - States
- (void)beginConfig;
- (void)commitConfig;

- (BOOL)isConfiguring;

#pragma mark -
#pragma mark - Layout
@property (nonatomic) PROTextVertialAlignment vertialAlignment;
@property (nonatomic) NSTextAlignment textAlignment;

@end

FOUNDATION_EXTERN
NSInteger const PROSlideTextLabelNoMaxLines;

#endif
