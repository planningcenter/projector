/*!
 * PlanViewMobileGridOptionsTableViewController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/10/14
 */

#import "PlanViewMobileGridOptionsTableViewController.h"
#import "PlanGridHelper.h"
#import "PRODisplayController.h"

typedef NS_ENUM(NSInteger, PlanViewMobileGridOptionsTableViewControllerRows) {
    PlanViewMobileGridOptionsTableViewControllerRecordings        = 0,
    PlanViewMobileGridOptionsTableViewControllerRowPickLogo       = 1,
    PlanViewMobileGridOptionsTableViewControllerRowOrderOfService = 2,
    PlanViewMobileGridOptionsTableViewControllerRowLayouts        = 3,
    PlanViewMobileGridOptionsTableViewControllerRow_Count         = 4
};

static NSString *const PlanViewMobileGridOptionsTableViewCellIdentifier = @"PlanViewMobileGridOptionsTableViewCellIdentifier";

@interface PlanViewMobileGridOptionsTableViewCell : PCOTableViewCell

@property (nonatomic) BOOL isStaged;
@property (nonatomic) BOOL isActive;

@property (nonatomic, weak) PCOLabel *infoLabel;

- (void)updateInfoLabel;

@end

@interface PlanViewMobileGridOptionsTableViewController ()

@property (nonatomic, weak) UIVisualEffectView *effectView;

@end

@implementation PlanViewMobileGridOptionsTableViewController

// MARK: - View Lifecycle
- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.tableView reloadData];
}

// MARK: - Table View Setup
- (UIView *)viewForTableView:(PCOTableView *)tableView {
    return self.effectView.contentView;
}
- (void)finishTableViewSetup:(PCOTableView *)tableView {
    tableView.backgroundColor = [UIColor clearColor];
}
- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[PlanViewMobileGridOptionsTableViewCell class] forCellReuseIdentifier:PlanViewMobileGridOptionsTableViewCellIdentifier];
}

// MARK: - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return PlanViewMobileGridOptionsTableViewControllerRow_Count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlanViewMobileGridOptionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlanViewMobileGridOptionsTableViewCellIdentifier forIndexPath:indexPath];
    cell.isStaged = NO;
    cell.isActive = NO;
    
    switch (indexPath.row) {
        case PlanViewMobileGridOptionsTableViewControllerRecordings: {
            cell.textLabel.text = NSLocalizedString(@"Recordings", nil);
            cell.imageView.image = [UIImage templateImageNamed:@"recorder-record-btn"];
            break;
        }
        case PlanViewMobileGridOptionsTableViewControllerRowPickLogo: {
            cell.textLabel.text = NSLocalizedString(@"Change Logo", nil);
            cell.imageView.image = [UIImage templateImageNamed:@"screen-icon"];
            break;
        }
        case PlanViewMobileGridOptionsTableViewControllerRowOrderOfService: {
            cell.textLabel.text = NSLocalizedString(@"Order of Service", nil);
            cell.imageView.image = [UIImage templateImageNamed:@"dash_edit"];
            break;
        }
        case PlanViewMobileGridOptionsTableViewControllerRowLayouts: {
            cell.textLabel.text = NSLocalizedString(@"Layouts", nil);
            cell.imageView.image = [UIImage templateImageNamed:@"layouts_icon"];
            break;
        }
        default:
            break;
    }
    
    [cell updateInfoLabel];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case PlanViewMobileGridOptionsTableViewControllerRecordings: {
            [self.delegate optionsControllerRecordingsAction:self];
            break;
        }
        case PlanViewMobileGridOptionsTableViewControllerRowPickLogo: {
            [self.delegate optionsControllerChangeLogoAction:self];
            break;
        }
        case PlanViewMobileGridOptionsTableViewControllerRowOrderOfService: {
            [self.delegate optionsControllerOrderOfServiceAction:self];
            break;
        }
        case PlanViewMobileGridOptionsTableViewControllerRowLayouts: {
            [self.delegate optionsControllerLayoutsAction:self];
            break;
        }
        default:
            break;
    }
    
    [tableView reloadData];
}

// MARK: - Animate
- (void)prepareToAnimateIn {
    CGFloat yOffset = 20.0;
    CGFloat multi = 1.5;
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        cell.transform = CGAffineTransformMakeTranslation(0.0, yOffset);
        yOffset += (20.0 * multi);
        multi += 0.23;
    }
}
- (void)animateIn {
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        cell.transform = CGAffineTransformIdentity;
    }
}
- (void)animateOut {
    
}

// MARK: - Layout & Size
- (CGSize)preferredContentSize {
    return CGSizeMake(320.0, 44.0 * PlanViewMobileGridOptionsTableViewControllerRow_Count);
}

// MARK: - Effect
- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVibrancyEffect *vibrancy = [UIVibrancyEffect effectForBlurEffect:blur];
        
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        blurView.translatesAutoresizingMaskIntoConstraints = NO;
        UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancy];
        vibrancyView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _effectView = vibrancyView;
        
        UIView *stroke = [UIView newAutoLayoutView];
        stroke.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:stroke];
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:stroke offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeTop]];
        [self.view addConstraint:[NSLayoutConstraint height:2.0 forView:stroke]];
        
        [blurView.contentView addSubview:vibrancyView];
        [blurView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:vibrancyView offset:0.0 edges:UIRectEdgeAll]];
        
        [self.view addSubview:blurView];
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:blurView offset:0.0 edges:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:blurView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:stroke attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    }
    return _effectView;
}

@end



@implementation PlanViewMobileGridOptionsTableViewCell

- (void)initializeDefaults {
    [super initializeDefaults];
    
    self.textLabel.font = [UIFont defaultFontOfSize_16];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)updateInfoLabel {
    self.infoLabel.text = nil;
    if ([self isStaged]) {
        self.infoLabel.text = NSLocalizedString(@"Up Next", nil);
    }
    if ([self isActive]) {
        self.infoLabel.text = NSLocalizedString(@"Active", nil);
    }
    
    self.infoLabel.hidden = (self.infoLabel.text.length == 0);
}

- (PCOLabel *)infoLabel {
    if (!_infoLabel) {
        PCOLabel *label = [PCOLabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_12];
        label.insets = UIEdgeInsetsMake(0.0, 4.0, 0.0, 4.0);
        
        _infoLabel = label;
        [self.contentView addSubview:label];
        
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:self.layoutMargins.right edges:UIRectEdgeRight]];
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:5.0 edges:UIRectEdgeBottom]];
    }
    return _infoLabel;
}

@end
