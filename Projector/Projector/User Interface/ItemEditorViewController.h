//
//  ItemEditorViewController.h
//  Projector
//
//  Created by Peter Fokos on 11/10/14.
//

#import "PCOViewController.h"

@protocol ItemEditorViewControllerDelegate

- (void)planItemWasSaved;

@end

@interface ItemEditorViewController : PCOViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<ItemEditorViewControllerDelegate> delegate;
@property (nonatomic, weak) PCOPlan *plan;
@property (nonatomic, weak) PCOItem *selectedItem;

@end
