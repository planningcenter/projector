/*!
 * PlanViewGridCollectionViewLayout.m
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#import "PlanViewGridCollectionViewLayout.h"

#import "PlanViewGridSelectedDecorationView.h"
#import "PlanViewGridUpNextDecorationView.h"
#import "PlanViewGridConnectToPreviousView.h"
#import "PlanViewGridUpNextPlayDecorationView.h"
#import "PlanViewGridViewController.h"
#import "PROThumbnailView.h"

#define l_delegate ((id<PlanViewGridCollectionViewLayoutDelegate>)self.collectionView.delegate)

@interface PlanViewGridCollectionViewLayout ()

@property (nonatomic, assign) BOOL onlyChangeY;
@property (nonatomic, assign) CGRect lastFrame;

@property (nonatomic, assign) CGFloat maximumY;

@property (nonatomic, strong) NSMutableArray *slideLayoutAttributes;
@property (nonatomic, strong) NSMutableArray *slideHeaderAttributes;

@property (nonatomic, strong) NSMutableArray *slideDecorationSelectedAttributes;
@property (nonatomic, strong) NSMutableArray *slideDecorationUpNextAttributes;
@property (nonatomic, strong) NSMutableArray *slideDecorationPreviousAttributes;
@property (nonatomic, strong) NSMutableArray *slideDecorationUpNextPlayButtonAttributes;

@property (nonatomic) CGFloat aspectRatio;
@property (nonatomic) ProjectorGridSize gridSize;

@property (nonatomic) BOOL forceRefresh;

@end

@implementation PlanViewGridCollectionViewLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (newBounds.origin.x == self.lastFrame.origin.x && CGSizeEqualToSize(newBounds.size, self.lastFrame.size)) {
        self.onlyChangeY = YES;
    } else {
        self.onlyChangeY = NO;
    }
    self.lastFrame = newBounds;
    return YES;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
    if ([context isKindOfClass:[PlanViewGridCollectionSelectionChangeInvalidationContext class]]) {
        self.onlyChangeY = YES;
    }
    [super invalidateLayoutWithContext:context];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aspectRatioDidChange:) name:kProjectorDefaultAspectRatioSetting object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gridSizeSettingDidChange:) name:kProjectorGrideSizeSetting object:nil];
        self.aspectRatio = ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]);
        self.gridSize = [[ProjectorSettings userSettings] gridSize];
        
        [self registerClass:[PlanViewGridSelectedDecorationView class] forDecorationViewOfKind:PlanViewGridSelectedDecoration];
        [self registerClass:[PlanViewGridUpNextDecorationView class] forDecorationViewOfKind:PlanViewGridUpNextDecoration];
        [self registerClass:[PlanViewGridConnectToPreviousView class] forDecorationViewOfKind:PlanViewGridConnectToPreviousDecoration];
        [self registerClass:[PlanViewGridUpNextPlayDecorationView class] forDecorationViewOfKind:PlanViewGridUpNextPlayDecoration];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)selectionChanged {
    [self invalidateLayoutWithContext:[[PlanViewGridCollectionSelectionChangeInvalidationContext alloc] init]];
}

- (void)invalidateLayoutCache {
    self.onlyChangeY = NO;
    self.forceRefresh = YES;
    [self _invalidateLayoutCache];
    [self invalidateLayout];
}
- (void)_invalidateLayoutCache {
    if (self.slideLayoutAttributes) {
        [self.slideLayoutAttributes removeAllObjects];
    }
    if (self.slideHeaderAttributes) {
        [self.slideHeaderAttributes removeAllObjects];
    }
    if (self.slideDecorationSelectedAttributes) {
        [self.slideDecorationSelectedAttributes removeAllObjects];
    }
    if (self.slideDecorationUpNextAttributes) {
        [self.slideDecorationUpNextAttributes removeAllObjects];
    }
    if (self.slideDecorationPreviousAttributes) {
        [self.slideDecorationPreviousAttributes removeAllObjects];
    }
    if (self.slideDecorationUpNextPlayButtonAttributes) {
        [self.slideDecorationUpNextPlayButtonAttributes removeAllObjects];
    }
}

#pragma mark -
#pragma mark - Storage
- (NSMutableArray *)slideLayoutAttributes {
    if (!_slideLayoutAttributes) {
        _slideLayoutAttributes = [NSMutableArray arrayWithCapacity:60];
    }
    return _slideLayoutAttributes;
}
- (NSMutableArray *)slideHeaderAttributes {
    if (!_slideHeaderAttributes) {
        _slideHeaderAttributes = [NSMutableArray arrayWithCapacity:10];
    }
    return _slideHeaderAttributes;
}
- (NSMutableArray *)slideDecorationSelectedAttributes {
    if (!_slideDecorationSelectedAttributes) {
        _slideDecorationSelectedAttributes = [NSMutableArray arrayWithCapacity:60];
    }
    return _slideDecorationSelectedAttributes;
}
- (NSMutableArray *)slideDecorationUpNextAttributes {
    if (!_slideDecorationUpNextAttributes) {
        _slideDecorationUpNextAttributes = [NSMutableArray arrayWithCapacity:60];
    }
    return _slideDecorationUpNextAttributes;
}
- (NSMutableArray *)slideDecorationPreviousAttributes {
    if (!_slideDecorationPreviousAttributes) {
        _slideDecorationPreviousAttributes = [NSMutableArray arrayWithCapacity:60];
    }
    return _slideDecorationPreviousAttributes;
}
- (NSMutableArray *)slideDecorationUpNextPlayButtonAttributes {
    if (!_slideDecorationUpNextPlayButtonAttributes) {
        _slideDecorationUpNextPlayButtonAttributes = [NSMutableArray arrayWithCapacity:60];
    }
    return _slideDecorationUpNextPlayButtonAttributes;
}

#pragma mark -
#pragma mark - Aspect ratio changed
- (void)aspectRatioDidChange:(NSNotification *)notif {
    PCOKitOnMainThread(^{
        self.aspectRatio = ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]);
        [self invalidateLayout];
    });
}
- (void)gridSizeSettingDidChange:(NSNotification *)notif {
    PCOKitOnMainThread(^{
        self.gridSize = [[ProjectorSettings userSettings] gridSize];
        [self invalidateLayout];
        [l_delegate gridSizeSettingDidChange];
    });
}

#pragma mark -
#pragma mark - Layout

- (void)prepareLayout {
    [super prepareLayout];
    
    if (self.onlyChangeY && !self.forceRefresh) {
        self.onlyChangeY = NO;
        return;
    }
    
    if (self.forceRefresh) {
        self.forceRefresh = NO;
    }
    
    [self _invalidateLayoutCache];
    
    self.maximumY = 0.0;
    
    CGFloat (^performLayoutMath)(CGFloat, NSUInteger, CGFloat) = ^CGFloat(CGFloat width, NSUInteger cellsPer, CGFloat pad) {
        return ceilf((width - (pad * (cellsPer + 1))) / cellsPer) - ceilf(PlanViewGridPadding / 2.0);
    };
    
    
    CGFloat thumbnailViewNameHeight = [PROThumbnailView thumbnailViewNameHeight];
    
    CGFloat randomOffset = 0.0; // Random offset corrects some math that isn't quite right when we're on a normal size.
    NSUInteger cellsPerColumn = 3;
    switch (self.gridSize) {
        case ProjectorGridSizeNormal:
            randomOffset = 1.0;
            cellsPerColumn = 3;
            break;
        case ProjectorGridSizeLarge:
            cellsPerColumn = 2;
            break;
        case ProjectorGridSizeSmall:
            cellsPerColumn = 4;
            break;
        default:
            break;
    }
    
    CGFloat maxWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat cellWidth = performLayoutMath(maxWidth, cellsPerColumn, 0.0);
    CGFloat cellHeight = ceilf((cellWidth + (PlanViewGridPadding * 2.0)) / self.aspectRatio);
    cellHeight += thumbnailViewNameHeight;
    
    // I don't know why this has to be here, but it fixes problems (╯°□°）╯︵ ┻━┻) - SS
    if (self.aspectRatio <= 1.4) {
        cellHeight -= PlanViewGridPadding; // Offset for 4:3
    } else {
        cellHeight -= 3.0; // Offset for 16:9
    }
    
    cellHeight -= randomOffset;
    
    CGSize cellSize = CGSizeMake(cellWidth, cellHeight);
    
    CGFloat currentY = 0.0;
    
    NSUInteger sectionCount = [self.collectionView numberOfSections];
    for (NSUInteger section = 0; section < sectionCount; section++) {
        NSUInteger rowCount = [self.collectionView numberOfItemsInSection:section];
        CGFloat currentX = PlanViewGridPadding;
        NSUInteger sectionColumnIndex = 0;
        
        NSIndexPath *sectionPath = [NSIndexPath indexPathForRow:0 inSection:section];
        UICollectionViewLayoutAttributes *headerAttrib = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:sectionPath];
        headerAttrib.zIndex = 1000000 + section;
        
        CGRect headerFrame = (CGRect){{0.0, currentY},{maxWidth, 44.0}};
        headerAttrib.frame = headerFrame;
        
        [self.slideHeaderAttributes addObject:headerAttrib];
        
        currentY += CGRectGetHeight(headerAttrib.frame);
        
        if (rowCount > 0) {
            currentY += PlanViewGridPadding;
        }
        
        self.maximumY = MAX(self.maximumY, currentY);
        
        // Rows
        for (NSUInteger row = 0; row < rowCount; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGRect frame = (CGRect){{currentX, currentY}, cellSize};
            
            attributes.frame = CGRectIntegral(frame);
            
            [self.slideLayoutAttributes addObject:attributes];
            
            currentX += CGRectGetWidth(attributes.frame);
            
            sectionColumnIndex++;
            
            BOOL nextLine = NO;
            
            UICollectionViewLayoutAttributes *selected = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PlanViewGridSelectedDecoration withIndexPath:indexPath];
            selected.zIndex = -1;
            UICollectionViewLayoutAttributes *upNext = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PlanViewGridUpNextDecoration withIndexPath:indexPath];
            upNext.zIndex = -2;
            UICollectionViewLayoutAttributes *upNextPlay = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PlanViewGridUpNextPlayDecoration withIndexPath:indexPath];
            upNextPlay.zIndex = 10;
            
            CGFloat offset = 2.0;
            CGRect decFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(PlanViewGridPadding - offset, PlanViewGridPadding - offset, PlanViewGridPadding - offset, PlanViewGridPadding - offset));
            selected.frame = decFrame;
            upNext.frame = decFrame;
            upNextPlay.frame = ({
                CGFloat width = 58.0;
                CGFloat width2 = 29.0;
                CGRect f = CGRectZero;
                
                f.size.width = width;
                f.size.height = width;
                f.origin.x = CGRectGetMidX(frame) - width2;
                f.origin.y = CGRectGetMidY(frame) - width2 - (thumbnailViewNameHeight / 2.0);
                
                CGRectIntegral(f);
            });
            
            [self.slideDecorationSelectedAttributes addObject:selected];
            [self.slideDecorationUpNextAttributes addObject:upNext];
            [self.slideDecorationUpNextPlayButtonAttributes addObject:upNextPlay];
            
            if ([l_delegate itemAtIndexPathConnectsToPrevious:indexPath]) {
                UICollectionViewLayoutAttributes *decoration = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:PlanViewGridConnectToPreviousDecoration withIndexPath:indexPath];
                decoration.zIndex = -3;
                
                CGFloat padding = 6.0;
                CGFloat padding2 = (padding * 2.0);
                
                CGRect prevFrame = CGRectMake(CGRectGetMinX(frame) - padding, CGRectGetMinY(frame) + 12.0, padding2, CGRectGetHeight(frame) - (24.0));
                decoration.frame = prevFrame;
                
                [self.slideDecorationPreviousAttributes addObject:decoration];
            }
            
            CGFloat bottomPadding = 0.0;
            
            if (row == rowCount - 1) {
                nextLine = YES;
                bottomPadding = PlanViewGridPadding;
            } else if (sectionColumnIndex >= cellsPerColumn) {
                sectionColumnIndex = 0;
                currentX = PlanViewGridPadding;
                nextLine = YES;
            }
            
            if (nextLine) {
                currentY = CGRectGetMaxY(attributes.frame) + bottomPadding;
            }
            
            self.maximumY = MAX(self.maximumY, currentY);
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    BOOL lowMemoryWarning = NO;
    if ([l_delegate respondsToSelector:@selector(hasLowMemoryWarning)]) {
        lowMemoryWarning = [l_delegate hasLowMemoryWarning];
    }
    NSMutableArray *elements = [NSMutableArray arrayWithCapacity:20];
    
    for (UICollectionViewLayoutAttributes *attribute in self.slideLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [elements addObject:attribute];
        }
    }
    UICollectionViewLayoutAttributes *topSectionHeader = nil;
    CGFloat testY = self.collectionView.contentOffset.y;
    if (!lowMemoryWarning) {
        testY += [self collectionViewContentSize].height;
    }
    for (UICollectionViewLayoutAttributes *_attribute in self.slideHeaderAttributes) {
        UICollectionViewLayoutAttributes *attribute = nil;
        if (CGRectGetMinY(_attribute.frame) < testY) {
            UICollectionViewLayoutAttributes *attribs = [_attribute copy];
            CGRect frame = attribs.frame;
            frame.origin.y = testY;
            attribs.frame = frame;
            topSectionHeader = attribs;
        } else if (topSectionHeader && CGRectGetMaxY(topSectionHeader.frame) > CGRectGetMinY(_attribute.frame)) {
            CGRect frame = topSectionHeader.frame;
            frame.origin.y = CGRectGetMinY(_attribute.frame) - CGRectGetHeight(frame);
            topSectionHeader.frame = frame;
            attribute = _attribute;
        } else {
            attribute = _attribute;
        }
        if (attribute && CGRectIntersectsRect(rect, attribute.frame)) {
            [elements addObject:attribute];
        }
    }
    
    if (topSectionHeader) {
        [elements addObject:topSectionHeader];
    }
    
    NSIndexPath *current = nil;
    if ([l_delegate respondsToSelector:@selector(planLayoutCurrentIndexPath:)]) {
        current = [l_delegate planLayoutCurrentIndexPath:self];
    }
    if (current) {
        UICollectionViewLayoutAttributes *attribs = [self layoutAttributesForDecorationViewOfKind:PlanViewGridSelectedDecoration atIndexPath:current];
        if (attribs) {
            if (CGRectIntersectsRect(rect, attribs.frame)) {
                [elements addObject:attribs];
            }
        }
    }
    NSIndexPath *upNext = nil;
    if ([l_delegate respondsToSelector:@selector(planLayoutUpNextIndexPath:)]) {
        upNext = [l_delegate planLayoutUpNextIndexPath:self];
    }
    if (upNext) {
        UICollectionViewLayoutAttributes *attribs = [self layoutAttributesForDecorationViewOfKind:PlanViewGridUpNextDecoration atIndexPath:upNext];
        if (attribs) {
            if (CGRectIntersectsRect(rect, attribs.frame)) {
                [elements addObject:attribs];
            }
        }
        UICollectionViewLayoutAttributes *play = [self layoutAttributesForDecorationViewOfKind:PlanViewGridUpNextPlayDecoration atIndexPath:upNext];
        if (play) {
            if (CGRectIntersectsRect(rect, play.frame)) {
                [elements addObject:play];
            }
        }
    }
    
    for (UICollectionViewLayoutAttributes *attribs in self.slideDecorationPreviousAttributes) {
        if (CGRectIntersectsRect(rect, attribs.frame)) {
            [elements addObject:attribs];
        }
    }
    
    
    return [elements copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.slideLayoutAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath == %@",indexPath]] firstObject];
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [[self.slideHeaderAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath == %@",indexPath]] firstObject];
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    if ([decorationViewKind isEqualToString:PlanViewGridSelectedDecoration]) {
        return [[self.slideDecorationSelectedAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath == %@",indexPath]] firstObject];
    }
    if ([decorationViewKind isEqualToString:PlanViewGridUpNextDecoration]) {
        return [[self.slideDecorationUpNextAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath == %@",indexPath]] firstObject];
    }
    if ([decorationViewKind isEqualToString:PlanViewGridConnectToPreviousDecoration]) {
        return [[self.slideDecorationPreviousAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath == %@",indexPath]] firstObject];
    }
    if ([decorationViewKind isEqualToString:PlanViewGridUpNextPlayDecoration]) {
        return [[self.slideDecorationUpNextPlayButtonAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"indexPath == %@",indexPath]] firstObject];
    }
    
    return nil;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), self.maximumY);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    return proposedContentOffset;
}

#pragma mark -
#pragma mark - Decoration

@end

@implementation PlanViewGridCollectionSelectionChangeInvalidationContext

- (BOOL)invalidateDataSourceCounts {
    return NO;
}
- (BOOL)invalidateEverything {
    return NO;
}

@end

_PCO_EXTERN_STRING PlanViewGridSelectedDecoration = @"PlanViewGridSelectedDecoration";
_PCO_EXTERN_STRING PlanViewGridUpNextDecoration = @"PlanViewGridUpNextDecoration";
_PCO_EXTERN_STRING PlanViewGridConnectToPreviousDecoration = @"PlanViewGridConnectToPreviousDecoration";
_PCO_EXTERN_STRING PlanViewGridUpNextPlayDecoration = @"PlanViewGridUpNextPlayDecoration";

CGFloat const PlanViewGridPadding = 12.0;
