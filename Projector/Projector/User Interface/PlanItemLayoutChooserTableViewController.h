//
//  PlanItemLayoutChooserTableViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/10/14.
//

#import "LayoutPickerTableViewController.h"

@interface PlanItemLayoutChooserTableViewController : LayoutPickerTableViewController

@property (nonatomic, weak) PCOItem *selectedItem;
@property (nonatomic, weak) PCOPlan *plan;

@end
