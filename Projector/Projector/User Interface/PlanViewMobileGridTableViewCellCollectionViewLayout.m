/*!
 * PlanViewMobileGridTableViewCellCollectionViewLayout.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/4/14
 */

#import "PlanViewMobileGridTableViewCellCollectionViewLayout.h"
#import "PlanViewMobileGridViewCollectionViewCell.h"

#import "PlanViewGridSelectedDecorationView.h"
#import "PlanViewGridConnectToPreviousView.h"
#import "PlanViewGridUpNextPlayDecorationView.h"
#import "PlanViewGridUpNextDecorationView.h"
#import "PROThumbnailView.h"

@interface PlanViewMobileGridTableViewCellCollectionViewLayout ()

@property (nonatomic, strong) NSMutableDictionary *cellAttributes;

@property (nonatomic, strong) NSMutableDictionary *previousDecorationAttributes;
@property (nonatomic, strong) NSMutableDictionary *selectedDecorationAttributes;
@property (nonatomic, strong) NSMutableDictionary *upNextDecorationAttributes;
@property (nonatomic, strong) NSMutableDictionary *upNextPlayDecorationAttributes;

@property (nonatomic) CGFloat maxWidth;

@end

@implementation PlanViewMobileGridTableViewCellCollectionViewLayout

+ (void)initialize {
    [PROThumbnailView setThumbnailViewNameHeight:PlanViewMobileGridViewCollectionViewCellBottomBarHeight];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registerClass:[PlanViewGridSelectedDecorationView class] forDecorationViewOfKind:PlanViewGridSelectedDecoration];
        [self registerClass:[PlanViewGridUpNextDecorationView class] forDecorationViewOfKind:PlanViewGridUpNextDecoration];
        [self registerClass:[PlanViewGridConnectToPreviousView class] forDecorationViewOfKind:PlanViewGridConnectToPreviousDecoration];
        [self registerClass:[PlanViewGridUpNextPlayDecorationView class] forDecorationViewOfKind:PlanViewGridUpNextPlayDecoration];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [self _invalidateLayoutCache];
    
    id delegate = (id<PlanViewMobileGridTableViewCellCollectionViewLayoutDelegate>)self.collectionView.delegate;
    if (![delegate conformsToProtocol:@protocol(PlanViewMobileGridTableViewCellCollectionViewLayoutDelegate)]) {
#if DEBUG
        PCOLogError(@"%@ does not conform to PlanViewMobileGridTableViewCellCollectionViewLayoutDelegate",delegate);
#endif
        delegate = nil;
    }
    
    CGFloat padding = 8.0;
    CGFloat lastX = padding;
    
    CGFloat aspect = ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]);
    CGFloat height = CGRectGetHeight(self.collectionView.bounds) - (padding * 2.0);
    CGFloat width = floor((height - PlanViewMobileGridViewCollectionViewCellBottomBarHeight) * aspect);
    
    CGRect frame = CGRectZero;
    frame.size.width = width;
    frame.size.height = height;
    frame.origin.y = padding;
    
    CGFloat thumbnailViewNameHeight = [PROThumbnailView thumbnailViewNameHeight];
    
    for (NSInteger section = 0; section < [self.collectionView numberOfSections]; section++) {
        for (NSInteger row = 0; row < [self.collectionView numberOfItemsInSection:section]; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            frame.origin.x = lastX;
            
            UICollectionViewLayoutAttributes *attribs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attribs.frame = frame;
            
            self.cellAttributes[indexPath] = attribs;
            
            UICollectionViewLayoutAttributes *selected = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PlanViewGridSelectedDecoration withIndexPath:indexPath];
            selected.zIndex = -1;
            UICollectionViewLayoutAttributes *upNext = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PlanViewGridUpNextDecoration withIndexPath:indexPath];
            upNext.zIndex = -2;
            UICollectionViewLayoutAttributes *upNextPlay = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PlanViewGridUpNextPlayDecoration withIndexPath:indexPath];
            upNextPlay.zIndex = 10;
            
            CGFloat offset = 2.0;
            CGRect decFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(-offset, -offset, -offset, -offset));
            selected.frame = decFrame;
            upNext.frame = decFrame;
            upNextPlay.frame = ({
                CGFloat width = 32.0;
                CGFloat width2 = 16.0;
                CGRect f = CGRectZero;
                
                f.size.width = width;
                f.size.height = width;
                f.origin.x = CGRectGetMidX(frame) - width2;
                f.origin.y = CGRectGetMidY(frame) - width2 - (thumbnailViewNameHeight / 2.0);
                
                CGRectIntegral(f);
            });
            
            self.selectedDecorationAttributes[indexPath] = selected;
            self.upNextDecorationAttributes[indexPath] = upNext;
            self.upNextPlayDecorationAttributes[indexPath] = upNextPlay;
            
            if ([delegate itemAtIndexPathConnectsToPrevious:indexPath]) {
                UICollectionViewLayoutAttributes *decoration = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PlanViewGridConnectToPreviousDecoration withIndexPath:indexPath];
                decoration.zIndex = -3;
                
                decoration.frame = ({
                    CGRect f = CGRectZero;
                    f.origin.y = CGRectGetMinY(frame) + 2.0;
                    f.size.height = height - 4.0;
                    f.origin.x = CGRectGetMinX(frame) - padding - (padding / 2.0);
                    f.size.width = padding;
                    CGRectIntegral(f);
                });
                
                self.previousDecorationAttributes[indexPath] = decoration;
            }
            
            lastX = CGRectGetMaxX(frame) + padding + padding;
        }
    }
    
    self.maxWidth = lastX;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.maxWidth, CGRectGetHeight(self.collectionView.bounds));
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
#define LAYOUT_IN_RECT(rect, dict, array, idxPath)\
    for (UICollectionViewLayoutAttributes *attribs in [dict allValues]) {\
        if (idxPath) {\
            if ([attribs.indexPath isEqual:idxPath] && CGRectIntersectsRect(rect, attribs.frame)) {\
                [array addObject:attribs];\
            }\
        } else {\
            if (CGRectIntersectsRect(rect, attribs.frame)) {\
                [array addObject:attribs];\
            }\
        }\
    }\

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    id delegate = (id<PlanViewMobileGridTableViewCellCollectionViewLayoutDelegate>)self.collectionView.delegate;
    if (![delegate conformsToProtocol:@protocol(PlanViewMobileGridTableViewCellCollectionViewLayoutDelegate)]) {
#if DEBUG
        PCOLogError(@"%@ does not conform to PlanViewMobileGridTableViewCellCollectionViewLayoutDelegate",delegate);
#endif
        delegate = nil;
    }
    
    LAYOUT_IN_RECT(rect, self.cellAttributes, array, nil);
    LAYOUT_IN_RECT(rect, self.previousDecorationAttributes, array, nil);
    
    NSIndexPath *current = [delegate planLayoutCurrentIndexPath:self];
    NSIndexPath *upNext = [delegate planLayoutUpNextIndexPath:self];
    
    if ([delegate isPlanIndexPath:current inCollectionView:self.collectionView]) {
        current = [NSIndexPath indexPathForRow:current.row inSection:0];
    } else {
        current = nil;
    }
    if ([delegate isPlanIndexPath:upNext inCollectionView:self.collectionView]) {
        upNext = [NSIndexPath indexPathForRow:upNext.row inSection:0];
    } else {
        upNext = nil;
    }
    
    if (current) {
        LAYOUT_IN_RECT(rect, self.selectedDecorationAttributes, array, current);
    }
    if (upNext) {
        LAYOUT_IN_RECT(rect, self.upNextDecorationAttributes, array, upNext);
        LAYOUT_IN_RECT(rect, self.upNextPlayDecorationAttributes, array, upNext);
    }
    
    return array;
}

- (void)selectionChanged {
    [self invalidateLayoutWithContext:[[PlanViewGridCollectionSelectionChangeInvalidationContext alloc] init]];
}

- (void)invalidateLayoutCache {
    [self _invalidateLayoutCache];
    [self invalidateLayout];
}

// MARK: - Attribute Getters
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellAttributes[indexPath];
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    if ([decorationViewKind isEqualToString:PlanViewGridSelectedDecoration]) {
        return self.selectedDecorationAttributes[indexPath];
    }
    if ([decorationViewKind isEqualToString:PlanViewGridUpNextDecoration]) {
        return self.upNextDecorationAttributes[indexPath];
    }
    if ([decorationViewKind isEqualToString:PlanViewGridConnectToPreviousDecoration]) {
        return self.previousDecorationAttributes[indexPath];
    }
    if ([decorationViewKind isEqualToString:PlanViewGridUpNextPlayDecoration]) {
        return self.upNextPlayDecorationAttributes[indexPath];
    }
    
    return nil;
}

// MARK: - Cache
- (void)_invalidateLayoutCache {
    [self.cellAttributes removeAllObjects];
    if (!_cellAttributes) {
        _cellAttributes = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    [self.previousDecorationAttributes removeAllObjects];
    if (!_previousDecorationAttributes) {
        _previousDecorationAttributes = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    [self.selectedDecorationAttributes removeAllObjects];
    if (!_selectedDecorationAttributes) {
        _selectedDecorationAttributes = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    [self.upNextDecorationAttributes removeAllObjects];
    if (!_upNextDecorationAttributes) {
        _upNextDecorationAttributes = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    [self.upNextPlayDecorationAttributes removeAllObjects];
    if (!_upNextPlayDecorationAttributes) {
        _upNextPlayDecorationAttributes = [NSMutableDictionary dictionaryWithCapacity:5];
    }
}

@end
