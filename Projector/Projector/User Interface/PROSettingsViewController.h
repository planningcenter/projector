/*!
 * PROSettingsViewController.h
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#ifndef PROSettingsViewController_h
#define PROSettingsViewController_h

#import "PCOTableViewController.h"
#import "ProjectorSettings.h"
#import "PROKeyboardInputHandler.h"

@interface PROSettingsViewController : PCOTableViewController <PCOKeyboarInputHandlerDelegate>

@property (nonatomic, weak) PROKeyboardInputHandler *inputHandler;

@end

#endif
