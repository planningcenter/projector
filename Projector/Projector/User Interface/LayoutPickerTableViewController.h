/*!
 * LayoutPickerTableViewController.h
 *
 *
 * Created by Skylar Schipper on 5/13/14
 */

#ifndef LayoutPickerTableViewController_h
#define LayoutPickerTableViewController_h

#import "PROPickerTableViewController.h"

@class PlanOutputViewController;

@interface LayoutPickerTableViewController : PROPickerTableViewController

@property (nonatomic, strong) NSArray *defaultLayouts;
@property (nonatomic, strong) NSArray *customLayouts;
@property (nonatomic, weak) PCOServiceType *serviceType;

- (PCOSlideLayout *)layoutForIndexPath:(NSIndexPath *)indexPath;

@end

PCO_EXTERN_STRING LayoutPickerDidPickNewLayoutNotification;

#endif
