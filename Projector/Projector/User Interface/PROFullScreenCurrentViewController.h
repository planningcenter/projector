/*!
 * PROFullScreenCurrentViewController.h
 *
 *
 * Created by Skylar Schipper on 7/21/14
 */

#ifndef PROFullScreenCurrentViewController_h
#define PROFullScreenCurrentViewController_h

#import "PCOViewController.h"
#import "NowPlayingFullScreenControlView.h"
#import "PROLogoPickerViewController.h"
#import "PROKeyboardInputHandler.h"

@class PRODisplayView;

typedef NS_ENUM(NSUInteger, FSControlType) {
    FSControlTypeNextSlide          = 0,
    FSControlTypePreviousSilde      = 1,
    FSControlTypeLyricsOff          = 2,
    FSControlTypeLyricsOn           = 3,
    FSControlTypeTogglePlayPause    = 4,
    FSControlTypeAlertDialog        = 5,
    FSControlTypeLogoScreen         = 6,
    FSControlTypeBlackScreen        = 7,
};

typedef NS_ENUM(NSUInteger, FSSlideTitleType) {
    FSSlideTitleTypeCurrent         = 0,
    FSSlideTitleTypePrevious        = 1,
    FSSlideTitleTypeNext            = 2,
};

@protocol PROFullScreenCurrentViewControllerDelegate

// Data Source
- (VideoPlayState)fullScreenVideoPlayState;
- (NSString *)fullScreenTimeLeftLabelText;
- (NSString *)fullScreenSlideTitleText:(FSSlideTitleType)slideTitleType;

// Delegate
- (void)fullScreenExecuteControlType:(FSControlType)controlType;
- (BOOL)shouldPresentLogoPicker;

@end

@interface PROFullScreenCurrentViewController : PCOViewController <UIGestureRecognizerDelegate, PROLogoPickerViewControllerDelegate, PCOKeyboarInputHandlerDelegate>

@property (nonatomic, assign) id<PROFullScreenCurrentViewControllerDelegate> delegate;

@property (nonatomic, weak) PCOPlan *plan;

- (void)presentCurrentFromFrame:(CGRect)frame;
- (void)refreshScreenComponents;

@end

#endif
