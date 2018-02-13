/*!
 * PROLogoPickerAddLogoSubViewController.h
 *
 *
 * Created by Skylar Schipper on 6/30/14
 */

#ifndef PROLogoPickerAddLogoSubViewController_h
#define PROLogoPickerAddLogoSubViewController_h

#import "PROPickerTableViewController.h"

#import "LogoPickerMediaDisplayCell.h"

@interface PROLogoPickerAddLogoSubViewController : PROPickerTableViewController

@property (nonatomic, weak) PCOPlan *plan;

- (BOOL)showSearchBar;

- (void)updateSearchString:(NSString *)searchString final:(BOOL)final;

@end

PCO_EXTERN_STRING LogoPickerMediaDisplayCellIdentifier;

#endif
