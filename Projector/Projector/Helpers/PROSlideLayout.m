/*!
 * PROSlideLayout.m
 *
 *
 * Created by Skylar Schipper on 5/7/14
 */

#import "PROSlideLayout.h"

#import "PCOSlideTextLayout.h"

#import "PROSlideTextLabel.h"

#import <objc/runtime.h>

@interface PROSlideLayout ()

@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) CGSize textShadowOffset;
@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic) CGFloat textShadowBlurRadius;

@property (nonatomic) PROTextVertialAlignment verticalAlignment;

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic) CGFloat rawFontSize;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *textShadowColor;

@property (nonatomic) NSUInteger maxLineCount;

@property (nonatomic) CGFloat lineSpacing;

@property (nonatomic, copy) UIFont *(^fontPrep)(UIFont *);

@end

@implementation PROSlideLayout

- (instancetype)initWithLayout:(PCOSlideTextLayout *)layout {
    self = [self init];
    if (self) {
        [self _configureForLayout:layout];
    }
    return self;
}

- (void)_configureForLayout:(PCOSlideTextLayout *)layout {
    if ([layout.textAlignment isEqualToString:kPCOSlideTextAlignmentCenter]) {
        self.textAlignment = NSTextAlignmentCenter;
    } else if ([layout.textAlignment isEqualToString:kPCOSlideTextAlignmentRight]) {
        self.textAlignment = NSTextAlignmentRight;
    } else {
        self.textAlignment = NSTextAlignmentLeft;
    }
    
    if ([layout.verticalAlignment isEqualToString:kPCOSlideTextVerticalAlignmentTop]) {
        self.verticalAlignment = PROTextVertialAlignmentTop;
    } else if ([layout.verticalAlignment isEqualToString:kPCOSlideTextVerticalAlignmentBottom]) {
        self.verticalAlignment = PROTextVertialAlignmentBottom;
    } else {
        self.verticalAlignment = PROTextVertialAlignmentCenter;
    }
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = ([layout.marginTop floatValue] / 100.0);
    insets.bottom = ([layout.marginBottom floatValue] / 100.0);
    insets.left = ([layout.marginLeft floatValue] / 100.0);
    insets.right = ([layout.marginRight floatValue] / 100.0);
    self.edgeInsets = insets;
    
    self.rawFontSize = [layout.fontSize floatValue];
    self.fontName = layout.fontName;
    
    self.textColor = layout.fontColor;
    
    self.textShadowOffset = [layout fontShadowOffset];
    self.textShadowColor = [[layout fontShadowColor] colorWithAlphaComponent:[layout.fontShadowOpacity floatValue]];
    self.textShadowBlurRadius = [layout.fontShadowBlur floatValue];
    
    self.maxLineCount = [layout.defaultLinesPerSlide unsignedIntegerValue];
    
    self.lineSpacing = [layout.lineSpacing floatValue];
}

- (void)configureTextLabel:(PROSlideTextLabel *)label {
    [label beginConfig];
    
    label.textAlignment = self.textAlignment;
    
    // This is an arbitrary number that was used in Projector 1... (╯°□°）╯︵ ┻━┻ -- SS
    static CGFloat const sizeOffset = 1024.0;
    
    CGFloat sizeMultiplier = (CGRectGetWidth(label.superview.bounds) / sizeOffset);
    
    label.lineSpacing = floorf(self.lineSpacing * sizeMultiplier);
    
    UIEdgeInsets contentInsets;
    contentInsets.top = floorf(CGRectGetHeight(label.bounds) * self.edgeInsets.top);
    contentInsets.bottom = floorf(CGRectGetHeight(label.bounds) * self.edgeInsets.bottom);
    contentInsets.left = floorf(CGRectGetHeight(label.bounds) * self.edgeInsets.left);
    contentInsets.right = floorf(CGRectGetHeight(label.bounds) * self.edgeInsets.right);
    label.textInsets = contentInsets;
    
    CGFloat fontSizeMultiplier = (CGRectGetWidth(label.superview.bounds) - (contentInsets.left + contentInsets.right)) / sizeOffset;
    
    CGFloat fontSize = floorf(self.rawFontSize * fontSizeMultiplier);
    
    UIFont *font = [UIFont fontWithName:self.fontName size:fontSize];
    if (self.fontPrep) {
        UIFont *newFont = self.fontPrep(font);
        if (newFont) {
            font = newFont;
        }
    }
    label.font = font;
    label.textColor = self.textColor;
    
    CGSize shadowSize = ({
        CGSize size;
        if (self.textShadowOffset.width < 0.0) {
            size.width = floorf(self.textShadowOffset.width * sizeMultiplier);
        } else {
            size.width = ceilf(self.textShadowOffset.width * sizeMultiplier);
        }
        if (self.textShadowOffset.height < 0.0) {
            size.height = floorf(self.textShadowOffset.height * sizeMultiplier);
        } else {
            size.height = ceilf(self.textShadowOffset.height * sizeMultiplier);
        }
        size;
    });
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = shadowSize;
    shadow.shadowColor = self.textShadowColor;
    shadow.shadowBlurRadius = self.textShadowBlurRadius;
    
    label.shadow = shadow;
    
    label.vertialAlignment = self.verticalAlignment;
    
    label.text = label.text;
    
    [label commitConfig];
}

- (NSString *)debugDescription {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &count);
    
    NSMutableArray *all = [NSMutableArray arrayWithCapacity:count];
    
    for(uint64_t i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            [all addObject:propertyName];
        }
    }
    free(properties);
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:all.count];
    
    for (NSString *key in all) {
        info[key] = PCOSafe([self valueForKey:key]);
    }
    
    return [NSString stringWithFormat:@"%@\n%@",[self description],info];
}

- (id)copyWithZone:(NSZone *)zone {
    PROSlideLayout *layout = [[PROSlideLayout alloc] init];
    layout.textAlignment = self.textAlignment;
    layout.textShadowOffset = self.textShadowOffset;
    layout.edgeInsets = self.edgeInsets;
    layout.textShadowBlurRadius = self.textShadowBlurRadius;
    layout.verticalAlignment = self.verticalAlignment;
    layout.fontName = [self.fontName copyWithZone:zone];
    layout.rawFontSize = self.rawFontSize;
    layout.textColor = [self.textColor copyWithZone:zone];
    layout.textShadowColor = [self.textShadowColor copyWithZone:zone];
    layout.maxLineCount = self.maxLineCount;
    layout.lineSpacing = self.lineSpacing;
    
    return layout;
}

- (void)prepareFont:(UIFont *(^)(UIFont *))prepare {
    self.fontPrep = [prepare copy];
}

@end
