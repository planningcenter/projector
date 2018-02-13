//
//  CustomSlidesListViewController.h
//  Projector
//
//  Created by Peter Fokos on 10/15/14.
//

#import "PCOViewController.h"
#import "CustomSlidesEditorViewController.h"


@interface CustomSlidesListViewController : PCOViewController <UITableViewDataSource, UITableViewDelegate, CustomSlidesEditorViewControllerDelegate>

@property (nonatomic, weak) PCOItem *selectedItem;
@property (nonatomic, weak) PCOPlan *plan;

@end
