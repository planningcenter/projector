/*!
 * PROLogoPickerViewController.m
 *
 *
 * Created by Skylar Schipper on 6/26/14
 */

#import "PROLogoPickerViewController.h"
#import "PROLogo.h"
#import "ProjectorSettings.h"
#import "PROSlideDeleteTableViewCell.h"
#import "PROLogoPickerAddLogoCollectionViewController.h"
#import "FBShimmeringView.h"
#import "PROSlideManager.h"
#import "PROAddBarButtonItem.h"

@interface _PROLogoPickerTableViewCell : PROSlideDeleteTableViewCell

@property (nonatomic, strong) NSString *logoUUID;

@property (nonatomic, weak) PCOView *imageBackingView;
@property (nonatomic, weak) PCOView *progressView;
@property (nonatomic) CGFloat progress;

@property (nonatomic, weak) FBShimmeringView *shimmerView;

@property (nonatomic, getter = isCurrent) BOOL current;
@property (nonatomic, weak) UIImageView *currentImageView;

@end

static NSString *const kPROLogoPickerViewControllerIdentifier = @"kPROLogoPickerViewControllerIdentifier";

@interface PROLogoPickerViewController () <PROSlideDeleteTableViewCellDelegate>

@property (nonatomic) BOOL autoShownAddController;

@property (nonatomic, strong) NSArray *logos;
@property (nonatomic, strong) NSString *currentLogoUUID;

@end

@implementation PROLogoPickerViewController

- (void)loadView {
    [super loadView];
    
    self.title = NSLocalizedString(@"Pick a Logo", nil);
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"", nil) style:UIBarButtonItemStylePlain target:nil action:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PROLogoThubnailGenerationCompletedNotification:) name:PROLogoThubnailGenerationCompletedNotification object:nil];
    
    self.tableView.backgroundColor = [UIColor mediaSelectedCellBackgroundColor];
    self.tableView.separatorColor = [UIColor blackColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView registerClass:[_PROLogoPickerTableViewCell class] forCellReuseIdentifier:kPROLogoPickerViewControllerIdentifier];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor projectorBlackColor];
    
    self.navigationItem.rightBarButtonItem = [[PROAddBarButtonItem alloc] initWithTarget:self action:@selector(addButtonAction:)];
    
    [self reloadTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.logos.count == 0 && !self.autoShownAddController) {
            self.autoShownAddController = YES;
            [self addButtonAction:nil];
        }
    });
}

- (void)PROLogoThubnailGenerationCompletedNotification:(NSNotification *)notif {
    [self reloadTableView];
    PROLogo *logo = notif.userInfo[@"logo"];
    if (logo) {
        [self selectLogo:logo];
    }
}

#pragma mark -
#pragma mark - Random
- (void)setInPopover:(BOOL)inPopover {
    _inPopover = inPopover;
    if (inPopover) {
        self.navigationItem.leftBarButtonItem = nil;
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
    }
}

- (NSArray *)logos {
    if (!_logos) {
        _logos = [PROLogo allLogos];
        _currentLogoUUID = nil;
    }
    return _logos;
}
- (NSString *)currentLogoUUID {
    if (!_currentLogoUUID) {
        _currentLogoUUID = [[PROStateSaver sharedState] currentLogoUUID];
    }
    return _currentLogoUUID;
}

- (CGSize)preferredContentSize {
    return CGSizeMake(320.0, 380.0);
}

- (void)doneButtonAction:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)addButtonAction:(id)sender {
    PROLogoPickerAddLogoCollectionViewController *controller = [[PROLogoPickerAddLogoCollectionViewController alloc] initWithNibName:nil bundle:nil];
    controller.preferredContentSize = [self preferredContentSize];
    controller.plan = self.plan;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark - Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logos.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _PROLogoPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPROLogoPickerViewControllerIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    PROLogo *logo = self.logos[indexPath.row];
    
    [logo finishFileDownloadIfNeeded];
    
    cell.titleLabel.text = logo.localizedName;
    cell.logoUUID = logo.UUID;
    
    cell.current = [self.currentLogoUUID isEqualToString:logo.UUID];
    
    [logo loadThumbnailWithCompletion:^(UIImage *image, NSError *error) {
        if (image) {
            cell.imageView.image = image;
            [cell setNeedsLayout];
        }
    }];
    
    return cell;
}

- (void)slideCellShouldDelete:(PROSlideDeleteTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    
    PROLogo *logo = self.logos[indexPath.row];
    NSError *error = nil;
    if (![logo destroy:&error]) {
        PCOLogError(@"%@",error);
    }
    [self reloadTableView];
}

- (void)reloadTableView {
    _logos = nil;
    [super reloadTableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PROLogo *logo = self.logos[indexPath.row];
    [self selectLogo:logo];
    [PCOEventLogger logEvent:@"Logo Changed"];
}

- (void)selectLogo:(PROLogo *)logo {
    [[PROStateSaver  sharedState] setCurrentLogoUUID:logo.UUID];
    [self.delegate logoPicker:self didSelectLogo:logo];
}

@end


@implementation _PROLogoPickerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat aspect = ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat padding = 16.0;
    
    if ([self isCurrent]) {
        self.currentImageView.frame = ({
            CGRect frame = CGRectZero;
            frame.size = self.currentImageView.image.size;
            frame.origin.y = PCOKitRectGetHalfHeight(self.contentView.bounds) - PCOKitRectGetHalfHeight(frame);
            frame.origin.x = CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(frame) - padding;
            frame;
        });
    } else {
        self.currentImageView.frame = CGRectZero;
    }
    
    self.imageView.frame = ({
        CGRect frame = CGRectZero;
        frame.size.height = height - (padding * 2.0);
        frame.size.width = CGRectGetHeight(frame) * aspect;
        frame.origin.x = padding;
        frame.origin.y = padding;
        frame;
    });
    self.titleLabel.frame = ({
        CGRect frame = self.textLabel.frame;
        CGFloat imageWidth = CGRectGetWidth(self.currentImageView.bounds);
        if (imageWidth > 0.0) {
            imageWidth += 8.0;
        }
        frame.size = [self.titleLabel intrinsicContentSize];
        frame.origin.x = CGRectGetMaxX(self.imageView.frame) + padding;
        frame.origin.y = PCOKitRectGetHalfHeight(self.bounds) - PCOKitRectGetHalfHeight(frame);
        frame.size.width = (CGRectGetWidth(self.slidingContentView.bounds) - CGRectGetMinX(frame) - padding) - imageWidth;
        frame;
    });
    self.progressView.frame = ({
        CGRect frame = CGRectZero;
        frame.size.height = 2.0;
        frame.origin.y = height - CGRectGetHeight(frame);
        frame.size.width = CGRectGetWidth(self.bounds) * self.progress;
        frame;
    });
    
    if (self.progress > 0.0) {
        self.shimmerView.frame = ({
            CGRect frame = self.shimmerView.frame;
            frame.origin.x = CGRectGetMinX(self.titleLabel.frame);
            frame.origin.y = CGRectGetMaxY(self.titleLabel.frame);
            frame.size.width = self.shimmerView.contentView.intrinsicContentSize.width;
            frame;
        });
    }
    
    self.imageBackingView.frame = self.imageView.frame;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.backgroundColor = [UIColor mediaSelectedCellBackgroundColor];
    self.selectedBackgroundView.backgroundColor = [UIColor blackColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont defaultFontOfSize_14];
    self.imageView.contentMode = UIViewContentModeProjectorPreferred;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.subTitleLabel.textColor = pco_kit_GRAY(130.0);
    self.subTitleLabel.font = [UIFont defaultFontOfSize_12];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:PROLogoDownloadProgressUpdatedNotification object:nil];
    
    self.progress = 0.0;
    
    PCOView *view = [[PCOView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor projectorOrangeColor];
    self.progressView = view;
    [self.contentView addSubview:view];
    
    PCOView *back = [[PCOView alloc] initWithFrame:CGRectZero];
    back.backgroundColor = [UIColor blackColor];
    self.imageBackingView = back;
    [self.slidingContentView insertSubview:back atIndex:0];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.progress = 0.0;
    self.imageView.image = nil;
}

- (void)updateProgress:(NSNotification *)notif {
    if ([notif.object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)notif.object;
        
        if (self.logoUUID && [progress.userInfo[@"uuid"] isEqualToString:self.logoUUID]) {
            self.progress = (CGFloat)((CGFloat)progress.completedUnitCount / (CGFloat)progress.totalUnitCount);
        }
    }
}
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (progress <= 0.0) {
        self.shimmerView.shimmering = NO;
        self.shimmerView.hidden = YES;
    } else {
        if (!self.shimmerView.shimmering) {
            self.shimmerView.shimmering = YES;
            self.shimmerView.hidden = NO;
        }
    }
    [self setNeedsLayout];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageBackingView.backgroundColor = [UIColor blackColor];
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageBackingView.backgroundColor = [UIColor blackColor];
}

- (UIImageView *)imageView {
    UIImageView *view = [super imageView];
    if (view.superview != self.slidingContentView) {
        [view removeFromSuperview];
        [self.slidingContentView addSubview:view];
    }
    return view;
}

- (FBShimmeringView *)shimmerView {
    if (!_shimmerView) {
        FBShimmeringView *view = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 18.0)];
        view.shimmeringSpeed = 100.0;
        view.shimmeringPauseDuration = 0.8;
        
        _shimmerView = view;
        [self.slidingContentView addSubview:view];
        
        PCOLabel *label = [[PCOLabel alloc] initWithFrame:view.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.text = NSLocalizedString(@"downloading", nil);
        label.font = [UIFont defaultFontOfSize_12];
        label.textColor = [UIColor whiteColor];
        
        view.contentView = label;
    }
    return _shimmerView;
}

- (void)setCurrent:(BOOL)current {
    _current = current;
    [self setNeedsLayout];
}
- (UIImageView *)currentImageView {
    if (!_currentImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage templateImageNamed:@"green-circle-check"]];
        imageView.tintColor = [UIColor projectorOrangeColor];
        
        _currentImageView = imageView;
        [self.slidingContentView addSubview:imageView];
    }
    return _currentImageView;
}

+ (BOOL)skipConstraintsForTitleLabel {
    return YES;
}

@end
