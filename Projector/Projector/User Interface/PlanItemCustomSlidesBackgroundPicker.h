/*!
 * PlanItemCustomSlidesBackgroundPicker.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 2/23/15
 */

#ifndef Projector_PlanItemCustomSlidesBackgroundPicker_h
#define Projector_PlanItemCustomSlidesBackgroundPicker_h

#import "PROPickerTableViewController.h"
#import "PlanItemBackgroundPickerManager.h"

@interface PlanItemCustomSlidesBackgroundPicker : PROPickerTableViewController

@property (nonatomic, strong) PlanItemBackgroundPickerManager *picker;

@end

#endif
