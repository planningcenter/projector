/*!
 * PROSlideTextLabel.m
 *
 *
 * Created by Skylar Schipper on 6/18/14
 */

#import "PROSlideTextLabel.h"

@interface PROSlideTextLabel ()

@property (nonatomic) BOOL configuring;

@property (nonatomic, weak) UIView *insetView;
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak) NSLayoutConstraint *topInset;
@property (nonatomic, weak) NSLayoutConstraint *bottomInset;
@property (nonatomic, weak) NSLayoutConstraint *leftInset;
@property (nonatomic, weak) NSLayoutConstraint *rightInset;

@property (nonatomic, weak) NSLayoutConstraint *containerHeight;

@property (nonatomic, weak) NSLayoutConstraint *containerVertial;

@end

@interface _PROSlideTextLineLabel : UILabel

@property (nonatomic) NSUInteger number;

@end

@interface _PROSlideTextContainerView : UIView

@end

@implementation PROSlideTextLabel

// MARK: - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        [self finalizeInitialization];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self finalizeInitialization];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self finalizeInitialization];
    }
    return self;
}
- (void)finalizeInitialization {
    self.layer.needsDisplayOnBoundsChange = YES;
    
    self.vertialAlignment = PROTextVertialAlignmentCenter;
    self.textAlignment = NSTextAlignmentCenter;
    self.maxNumberOfLines = PROSlideTextLabelNoMaxLines;
}

// MARK: - Setters
- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if (self.boundsChangedHandler) {
        welf();
        self.boundsChangedHandler(welf, bounds);
    }
    
    [self updateIfNeeded];
}
- (void)setFont:(UIFont *)font {
    _font = font;
    
    [self updateIfNeeded];
}
- (void)setText:(NSString *)text {
    _text = [text stringByReplacingOccurrencesOfString:@"\n:\n" withString:@"\n\n"];
    
    [self updateIfNeeded];
}
- (void)setVertialAlignment:(PROTextVertialAlignment)vertialAlignment {
    _vertialAlignment = vertialAlignment;
    
    [self updateIfNeeded];
}
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    
    [self updateIfNeeded];
}
- (void)setTextInsets:(UIEdgeInsets)textInsets {
    _textInsets = textInsets;
    
    self.topInset.constant = textInsets.top;
    self.bottomInset.constant = -textInsets.bottom;
    self.leftInset.constant = textInsets.left;
    self.rightInset.constant = -textInsets.right;
    
    [self updateIfNeeded];
}
- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    [self updateIfNeeded];
}
- (void)setShadow:(NSShadow *)shadow {
    _shadow = shadow;
    
    [self updateIfNeeded];
}
- (void)setMaxNumberOfLines:(NSInteger)maxNumberOfLines {
    _maxNumberOfLines = maxNumberOfLines;
    
    [self updateIfNeeded];
}

// MARK: - Lazy Loaders
- (UIView *)containerView {
    if (!_containerView) {
        UIView *view = [_PROSlideTextContainerView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        
        _containerView = view;
        [self.insetView addSubview:view];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight]];
        
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:view.intrinsicContentSize.height];
        self.containerHeight = height;
        [self.insetView addConstraint:height];
    }
    return _containerView;
}
- (UIView *)insetView {
    if (!_insetView) {
        UIView *view = [_PROSlideTextContainerView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        
        _insetView = view;
        [self addSubview:view];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.textInsets.top];
        self.topInset = top;
        
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.textInsets.bottom];
        self.bottomInset = bottom;
        
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.textInsets.left];
        self.leftInset = left;
        
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.textInsets.right];
        self.rightInset = right;
        
        [self addConstraints:@[top, bottom, left, right]];
    }
    return _insetView;
}
- (_PROSlideTextLineLabel *)newDefaultLineLabel {
    _PROSlideTextLineLabel *label = [[_PROSlideTextLineLabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = self.font;
    label.textColor = self.textColor;
    label.textAlignment = self.textAlignment;
    label.numberOfLines = 1;
    label.lineBreakMode = NSLineBreakByClipping;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.8;
    
    return label;
}

// MARK: - Updates
- (void)updateIfNeeded {
    if ([self isConfiguring]) {
        return;
    }
    [self pro_performUpdateIfNeeded];
}
- (void)pro_performUpdateIfNeeded {
    [UIView performWithoutAnimation:^{
        [self pro_performUpdate];
    }];
}
- (void)pro_performUpdate {
    NSUInteger __block count = 0;
    
    for (UILabel *label in [self labels]) {
        [label removeFromSuperview];
    }
    
    [_containerView removeFromSuperview];
    _containerView = nil;
    
    [self.text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (line.length > 0) {
            count++;
        }
        if (self.maxNumberOfLines != PROSlideTextLabelNoMaxLines && (NSInteger)count > self.maxNumberOfLines) {
            *stop = YES;
            return;
        }
        
        [self setLine:line number:count];
    }];
    
    UIView *last = nil;
    for (UIView *view in [self orderedLabels]) {
        if (last) {
            [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:last attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.lineSpacing + self.font.descender]];
        } else {
            [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        }
        last = view;
    }
    
    if (self.containerVertial) {
        [self.insetView removeConstraint:self.containerVertial];
    }
    NSLayoutConstraint *constraint = nil;
    switch (self.vertialAlignment) {
        case PROTextVertialAlignmentCenter: {
            constraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.insetView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
            break;
        }
        case PROTextVertialAlignmentTop: {
            constraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.insetView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            break;
        }
        case PROTextVertialAlignmentBottom: {
            constraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.insetView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
            break;
        }
    }
    
    [self.containerView setNeedsLayout];
    
    if (constraint) {
        [self.insetView addConstraint:constraint];
        self.containerVertial = constraint;
    }
    
    [self updateContainerHeight];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self adjustFontToFit];
}

- (void)updateContainerHeight {
    CGFloat height = 0.0;
    for (UIView *view in [self labels]) {
        height += view.intrinsicContentSize.height;
        height += self.lineSpacing + self.font.descender;
    }
    
    self.containerHeight.constant = height;
}
- (void)adjustFontToFit {
    CGFloat maxWidth = CGRectGetWidth(self.insetView.bounds);
    CGFloat __block scale = 1.0;
    [self forEachLabel:^(UILabel *label, BOOL *stop) {
        if (label.intrinsicContentSize.width > maxWidth) {
            scale = MIN(scale, maxWidth / label.intrinsicContentSize.width);
        }
    }];
    
    if (scale < 1.0 && scale > 0.0) {
        CGFloat nScale = floorf(scale * 100.0) / 100.0;
        
        UIFont *font = [self.font fontWithSize:self.font.pointSize * nScale];
        
        [self forEachLabel:^(UILabel *label, BOOL *stop) {
            label.font = font;
        }];
        
        _font = font;
        
        [self updateContainerHeight];
        
        [self setNeedsLayout];
    }
}

// MARK: - Config State
- (void)beginConfig {
    self.configuring = YES;
}
- (void)commitConfig {
    self.configuring = NO;
    [self pro_performUpdateIfNeeded];
}
- (BOOL)isConfiguring {
    return self.configuring;
}

// MARK: - Line Managers
- (void)setLine:(NSString *)line number:(NSUInteger)number {
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    _PROSlideTextLineLabel *label = [self newDefaultLineLabel];
    label.number = number;
    
    if (line.length == 0) {
        label.text = @"--";
        label.hidden = YES;
    } else {
        NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
        if (self.shadow) {
            attribs[NSShadowAttributeName] = [self.shadow copy];
        }
        label.attributedText = [[NSMutableAttributedString alloc] initWithString:line attributes:attribs];
    }
    
    [self.containerView addSubview:label];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
}

- (NSArray *)labels {
    return [self.containerView.subviews collectSafe:^id(id object) {
        if ([object isKindOfClass:[_PROSlideTextLineLabel class]]) {
            return object;
        }
        return nil;
    }];
}
- (NSArray *)orderedLabels {
    return [[self labels] sortedArrayUsingComparator:^NSComparisonResult(_PROSlideTextLineLabel *obj1, _PROSlideTextLineLabel *obj2) {
        if (obj1.number > obj2.number) {
            return NSOrderedDescending;
        }
        if (obj1.number < obj2.number) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (void)forEachLabel:(void(^)(UILabel *label, BOOL *stop))block {
    for (UILabel *l in [self labels]) {
        BOOL stop = NO;
        block(l, &stop);
        if (stop) {
            break;
        }
    }
}

+ (NSString *)sampleLyricText {
    return NSLocalizedString(@"When peace like a river\nAttendeth my way\nWhen sorrows like sea billows roll;\nWhatever my lot,\nThou has taught me to say,\nIt is well, it is well, with my soul.\nIt is well with my soul\nit is well, it is well with my soul.\nThough Satan should buffet\nthough trials should come\nlet this blest assurance control\nthat Christ has regarded my helpless estate\nand hath shed his own blood for my soul.\nMy sin, oh, the bliss of this glorious thought!\nMy sin, not in part but the whole, ", nil);
}

+ (NSString *)sampleLyricTextWithMaxLines:(NSInteger)maxLines {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[PROSlideTextLabel sampleLyricText] componentsSeparatedByString:@"\n"]];
    if (maxLines <= (NSInteger)[array count]) {
        NSRange range;
        range.location = maxLines;
        range.length = [array count]-maxLines;
        [array removeObjectsInRange:range];
    }
    NSString *string = [array componentsJoinedByString:@"\n"];
    return string;
}

@end

@implementation _PROSlideTextLineLabel

@end
@implementation _PROSlideTextContainerView

- (CGSize)intrinsicContentSize {
    CGFloat max = 0.0;
    for (UIView *view in self.subviews) {
        max = MAX(max, CGRectGetMaxY(view.frame));
    }
    return CGSizeMake(UIViewNoIntrinsicMetric, max);
}

@end

NSInteger const PROSlideTextLabelNoMaxLines = -1;
