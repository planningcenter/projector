//
//  PlanEditorItemReorderViewController.h
//  Projector
//
//  Created by Peter Fokos on 11/7/14.
//

#import "PCOViewController.h"
#import "ItemEditorViewController.h"

@interface PlanEditorItemReorderViewController : PCOViewController  <UITableViewDataSource, UITableViewDelegate, ItemEditorViewControllerDelegate>

@property (nonatomic, weak) PCOPlan *plan;

@end
