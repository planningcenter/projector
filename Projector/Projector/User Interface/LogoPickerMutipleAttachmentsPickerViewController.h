/*!
 * LogoPickerMutipleAttachmentsPickerViewController.h
 *
 *
 * Created by Skylar Schipper on 7/10/14
 */

#ifndef LogoPickerMutipleAttachmentsPickerViewController_h
#define LogoPickerMutipleAttachmentsPickerViewController_h

#import "PROLogoPickerAddLogoSubViewController.h"

@interface LogoPickerMutipleAttachmentsPickerViewController : PROLogoPickerAddLogoSubViewController

@property (nonatomic, strong) NSArray *attachments;

@property (nonatomic, strong) PCOMedia *selectedMedia;

@property (nonatomic, copy) void (^pickerHandler)(PCOAttachment *, PCOMedia *);

@end

#endif
