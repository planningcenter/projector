//
//  EditArrangementSequenceViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/15/14.
//

#import "PCOViewController.h"

@interface EditArrangementSequenceViewController : PCOViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) PCOItem *selectedItem;
@property (nonatomic, weak) PCOPlan *plan;

@end

