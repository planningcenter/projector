/*!
 * SplashScreenViewController.h
 *
 *
 * Created by Skylar Schipper on 3/13/14
 */

#ifndef SplashScreenViewController_h
#define SplashScreenViewController_h

#import "PCOViewController.h"

@interface SplashScreenViewController : PCOViewController

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *picoImageView;

- (void)showLoadingIndicator;

@end

#endif
