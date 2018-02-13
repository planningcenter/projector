//
//  MediaChooserAllMediaViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/9/14.
//

#import "LogoPickerAllMediaViewController.h"
#import "PlanItemBackgroundPickerManager.h"

@interface MediaChooserAllMediaViewController : LogoPickerAllMediaViewController

@property (nonatomic, strong) PlanItemBackgroundPickerManager *picker;

@end
