/*!
 * LogoPickerPlanMediaViewController.h
 *
 *
 * Created by Skylar Schipper on 6/30/14
 */

#ifndef LogoPickerPlanMediaViewController_h
#define LogoPickerPlanMediaViewController_h

#import "PROLogoPickerAddLogoSubViewController.h"

@interface LogoPickerPlanMediaViewController : PROLogoPickerAddLogoSubViewController

@property (nonatomic, strong) NSDictionary *attachments;

- (NSString *)attachmentsKeyForIndex:(NSInteger)index;

@end

#endif
