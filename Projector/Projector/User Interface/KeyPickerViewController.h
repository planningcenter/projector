//
//  KeyPickerViewController.h
//  Projector
//
//  Created by Peter Fokos on 11/18/14.
//

#import "PCOViewController.h"

@interface KeyPickerViewController : PCOViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) PCOItem *selectedItem;

@end
