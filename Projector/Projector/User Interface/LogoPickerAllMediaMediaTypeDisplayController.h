/*!
 * LogoPickerAllMediaMediaTypeDisplayController.h
 *
 *
 * Created by Skylar Schipper on 7/7/14
 */

#ifndef LogoPickerAllMediaMediaTypeDisplayController_h
#define LogoPickerAllMediaMediaTypeDisplayController_h

#import "PROLogoPickerAddLogoSubViewController.h"

#import "PCOMediaType.h"

@interface LogoPickerAllMediaMediaTypeDisplayController : PROLogoPickerAddLogoSubViewController

@property (nonatomic, weak) PCOMediaType *mediaType;
@property (nonatomic, strong) NSArray *media;

+ (NSSet *)compatibleAttachmentTypes;

@end

#endif
