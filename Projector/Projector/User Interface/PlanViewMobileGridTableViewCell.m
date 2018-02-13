/*!
 * PlanViewMobileGridTableViewCell.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/3/14
 */

#import "PlanViewMobileGridTableViewCell.h"
#import "PlanViewMobileGridTableViewCellCollectionViewLayout.h"

@interface PlanViewMobileGridTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate, PlanViewMobileGridTableViewCellCollectionViewLayoutDelegate>

@end

@implementation PlanViewMobileGridTableViewCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor mobileGridViewBackgroundColor];
    self.collectionView.backgroundColor = [UIColor mobileGridViewBackgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView) name:kProjectorDefaultAspectRatioSetting object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
    self.delegate = nil;
    [super prepareForReuse];
}
- (void)setDelegate:(id<PlanViewMobileGridTableViewCellDelegate>)delegate {
    _delegate = delegate;
    
    [self.delegate cell:self finalizeCollectionViewSetup:self.collectionView];
    
    [self reloadCollectionView];
}

- (void)reloadCollectionView {
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[PlanViewMobileGridTableViewCellCollectionViewLayout alloc] init]];
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionView.alwaysBounceHorizontal = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;        collectionView.scrollsToTop = NO;
        
        _collectionView = collectionView;
        [self.contentView addSubview:collectionView];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:collectionView offset:0.0 edges:UIRectEdgeAll]];
        
        [collectionView reloadData];
    }
    return _collectionView;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSIndexPath *path = [self.delegate indexPathForCell:self];
    return [self.delegate numberOfItemsInSection:path.section cell:self];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.delegate cell:self collectionView:collectionView cellForItemAtIndexPath:indexPath planIndexPath:[self _transformIndexPath:indexPath]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *path = [self.delegate indexPathForCell:self];
    [self.delegate cell:self didSelectIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:path.section]];
    if ([collectionView.collectionViewLayout respondsToSelector:@selector(selectionChanged)]) {
        [((PlanViewMobileGridTableViewCellCollectionViewLayout *)collectionView.collectionViewLayout) selectionChanged];
    }
}

// MARK: - PlanViewGridCollectionViewLayoutDelegate
- (NSIndexPath *)planLayoutCurrentIndexPath:(PlanViewGridCollectionViewLayout *)layout {
    return [self.delegate planLayoutCurrentIndexPath:layout];
}
- (NSIndexPath *)planLayoutUpNextIndexPath:(PlanViewGridCollectionViewLayout *)layout {
    return [self.delegate planLayoutUpNextIndexPath:layout];
}
- (BOOL)itemAtIndexPathConnectsToPrevious:(NSIndexPath *)indexPath {
    return [self.delegate itemAtIndexPathConnectsToPrevious:[self _transformIndexPath:indexPath]];
}
- (BOOL)isPlanIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView {
    if (!indexPath) {
        return NO;
    }
    NSIndexPath *cellIndex = [self.delegate indexPathForCell:self];
    return (indexPath.section == cellIndex.section);
}

- (void)gridSizeSettingDidChange {
    
}

// MARK: - Index Transform
- (NSIndexPath *)_transformIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *adjIndex = [self.delegate indexPathForCell:self];
    return [NSIndexPath indexPathForRow:indexPath.row inSection:adjIndex.section];
}

@end

_PCO_EXTERN_STRING PlanViewMobileGridTableViewCellIdentifier = @"PlanViewMobileGridTableViewCellIdentifier";
