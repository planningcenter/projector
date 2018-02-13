/*!
 * FileInfoViewController.h
 * Projector
 *
 *
 * Created by Skylar Schipper on 11/10/14
 */

#ifndef Projector_FileInfoViewController_h
#define Projector_FileInfoViewController_h

#import "PCOViewController.h"
#import "PROSlideshow.h"

@protocol FileInfoViewControllerDelegate;

@interface FileInfoViewController : PCOViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *fileInfo;
@property (nonatomic, strong) PROSlideshow *slideshow;

@property (nonatomic, weak) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)deleteButtonAction:(id)sender;

@property (nonatomic, assign) id<FileInfoViewControllerDelegate> delegate;

@end

@protocol FileInfoViewControllerDelegate <NSObject>

- (void)fileInfoViewController:(FileInfoViewController *)controller shouldDeleteFile:(NSDictionary *)fileInfo;

@end

#endif
