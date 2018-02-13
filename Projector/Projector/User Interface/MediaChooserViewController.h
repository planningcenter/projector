//
//  MediaChooserViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/8/14.
//

#import "PROLogoPickerAddLogoCollectionViewController.h"
#import "PlanItemBackgroundPickerManager.h"

@interface MediaChooserViewController : PROLogoPickerAddLogoCollectionViewController

@property (nonatomic, strong) PlanItemBackgroundPickerManager *picker;

@end
