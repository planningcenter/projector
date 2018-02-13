//
//  MediaChooserAllMediaMediaTypeDisplayController.h
//  Projector
//
//  Created by Peter Fokos on 10/9/14.
//

#import "LogoPickerAllMediaMediaTypeDisplayController.h"
#import "PlanItemBackgroundPickerManager.h"

@interface MediaChooserAllMediaMediaTypeDisplayController : LogoPickerAllMediaMediaTypeDisplayController

@property (nonatomic, strong) PlanItemBackgroundPickerManager *picker;

@end
