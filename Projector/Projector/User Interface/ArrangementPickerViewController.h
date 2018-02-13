//
//  ArrangementPickerViewController.h
//  Projector
//
//  Created by Peter Fokos on 11/18/14.
//

#import "PCOViewController.h"

@interface ArrangementPickerViewController : PCOViewController  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) PCOItem *selectedItem;
@property (nonatomic, weak) PCOSong *song;

@end
