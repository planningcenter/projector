//
//  PRORecordingsListViewController.h
//  Projector
//
//  Created by Peter Fokos on 4/15/15.
//

#import "PCOViewController.h"
#import "PRORecordingController.h"

@protocol PRORecordingsListViewControllerDelegate <NSObject>

- (void)updateNavButtons;

@end

@interface PRORecordingsListViewController : PCOViewController <UITableViewDataSource, UITableViewDelegate, PRORecordingControllerDelegate>

@property (nonatomic, assign) id<PRORecordingsListViewControllerDelegate> delegate;

@end
