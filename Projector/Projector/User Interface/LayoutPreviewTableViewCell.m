//
//  LayoutPreviewTableViewCell.m
//  Projector
//
//  Created by Peter Fokos on 12/8/14.
//

#import "LayoutPreviewTableViewCell.h"
#import "PROSlideTextLabel.h"
#import "PROSlideLayout.h"
#import "PCOSlideLayout.h"

@interface LayoutPreviewTableViewCell ()

@property (nonatomic, strong) NSArray *cellContraints;
@property (nonatomic, weak) PCOView *layoutPreview;
@property (nonatomic, weak) PROSlideTextLabel *layoutTextLabel;

@end

@implementation LayoutPreviewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeDefaults];
    }
    return self;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.mediaImage.hidden = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _layoutPreview = nil;
    _layoutTextLabel = nil;
    _layout = nil;
}

#pragma mark - Layout
#pragma mark -

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Lazy loaders
#pragma mark -

- (PCOView *)layoutPreview {
    if (!_layoutPreview) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = self.layout.backgroundColor;
        view.clipsToBounds = YES;
        
        _layoutPreview = view;
        [self.contentView addSubview:view];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:9.0 edges:UIRectEdgeLeft | UIRectEdgeTop | UIRectEdgeBottom]];
        [self.contentView addConstraint:[NSLayoutConstraint width:72.0 forView:view]];
    }
    return _layoutPreview;
}
- (PROSlideTextLabel *)layoutTextLabel {
    if (!_layoutTextLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = NO;
        label.text = [PROSlideTextLabel sampleLyricText];
        
        _layoutTextLabel = label;
        [self.layoutPreview addSubview:label];
        [self.layoutPreview addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:0.0 edges:UIRectEdgeAll]];
    }
    return _layoutTextLabel;
}

- (void)setLayout:(PCOSlideLayout *)layout {
    _layout = layout;
    
    welf();
    self.layoutTextLabel.boundsChangedHandler = ^(PROSlideTextLabel *label, CGRect bounds) {
        PROSlideLayout *slideLayout = [[PROSlideLayout alloc] initWithLayout:welf.layout.lyricTextLayout];
        label.maxNumberOfLines = [welf.layout.lyricTextLayout.defaultLinesPerSlide integerValue];
        [slideLayout configureTextLabel:label];
    };
   
}

@end

NSString *const kLayoutPreviewTableViewCellIdentifier = @"kLayoutPreviewTableViewCellIdentifier";
