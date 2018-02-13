//
//  PlanItemSettingsViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/8/14.
//

#import "PCOTableViewController.h"

@interface PlanItemSettingsViewController : PCOTableViewController

@property (nonatomic, weak) PCOItem *selectedItem;
@property (nonatomic, weak) PCOPlan *plan;

@end

