/*!
 * SplashScreenViewController.m
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#import "SplashScreenViewController.h"
#import "PROLogoLoadingView.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor projectorOrangeColor];
    
    
#if defined(PROJECTOR_PUBLIC_BETA)
    #if PROJECTOR_PUBLIC_BETA
        PCOLabel *beta = [PCOLabel newAutoLayoutView];
        beta.text = @"Beta";
        beta.font = [UIFont boldDefaultFontOfSize:30.0];
        beta.textColor = [UIColor whiteColor];
        [self.view addSubview:beta];
        
        [self.view addConstraint:[NSLayoutConstraint centerHorizontal:beta inView:self.view]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:beta attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.logoImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20.0]];
    #endif
#endif
}

- (void)showLoadingIndicator {
    PROLogoLoadingView *loading = [PROLogoLoadingView newAutoLayoutView];
    loading.alpha = 0.5;
    [self.view addSubview:loading];
    [self.view addConstraint:[NSLayoutConstraint centerHorizontal:loading inView:self.view]];
    [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:loading offset:40.0 edges:UIRectEdgeTop]];
    [loading startAnimating];
}

@end
