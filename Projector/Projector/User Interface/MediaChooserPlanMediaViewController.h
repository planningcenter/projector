//
//  MediaChooserPlanMediaViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/9/14.
//

#import "LogoPickerPlanMediaViewController.h"
#import "PlanItemBackgroundPickerManager.h"

@interface MediaChooserPlanMediaViewController : LogoPickerPlanMediaViewController

@property (nonatomic, strong) PlanItemBackgroundPickerManager *picker;

@end
