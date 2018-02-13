/*!
 * SecondScreenViewController.m
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#import "SecondScreenViewController.h"
#import "PRODisplayController.h"
#import "ProjectorSettings.h"
#import "PRORecordingController.h"

@interface SecondScreenViewController ()

@property (nonatomic, weak) NSLayoutConstraint *constraint;

@end

@implementation SecondScreenViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aspectDidChange:) name:kProjectorDefaultAspectRatioSetting object:nil];
    
    [self pro_rebuildDisplayViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PRORecordingController sharedController] setDontRecordNextEvent:YES];
    [[PRODisplayController sharedController] displayCurrentItem:self.displayView.item];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[PRODisplayController sharedController] removeView:self.displayView];
}

- (void)aspectDidChange:(NSNotification *)notif {
    [self pro_rebuildDisplayViewConstraints];
}

- (void)pro_rebuildDisplayViewConstraints {
    if (_constraint) {
        [self.view removeConstraint:_constraint];
    }
    
    CGFloat aspect = ProjectorAspectForRatio([[ProjectorSettings userSettings] aspectRatio]);
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.displayView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.displayView attribute:NSLayoutAttributeHeight multiplier:aspect constant:0.0];
    
    _constraint = constraint;
    
    [self.view addConstraint:constraint];
    [self.view setNeedsLayout];
}

- (PRODisplayView *)displayView {
    if (!_displayView) {
        PRODisplayView *view = [PRODisplayView newAutoLayoutView];
        view.priority = PRODisplayViewPrioritySecondScreen;
        
        _displayView = view;
        [self.view addSubview:view];
        
        [self.view addConstraints:[NSLayoutConstraint center:view inView:self.view]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [[PRODisplayController sharedController] registerView:view];

    }
    return _displayView;
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft;
}

@end
