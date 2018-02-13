//
//  PlanItemSequenceViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/22/14.
//

#import "PCOViewController.h"

@interface PlanItemSequenceViewController : PCOViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) PCOItem *selectedItem;
@property (nonatomic, weak) PCOPlan *plan;
@property (nonatomic, strong) PCOStanza *stanza;

@end
