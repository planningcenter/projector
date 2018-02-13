//
//  SongListViewController.h
//  Projector
//
//  Created by Peter Fokos on 11/14/14.
//

#import "PCOViewController.h"

@interface SongListViewController : PCOViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) PCOPlan *plan;
@property (nonatomic, weak) PCOItem *selectedItem;

@property (nonatomic, assign) PCOTableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchController;
@property (nonatomic, strong) NSString *searchString;

@end
