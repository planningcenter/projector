/*!
 * ProjectorSettings.h
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#ifndef ProjectorSettings_h
#define ProjectorSettings_h

@import Foundation;
@import UIKit;

#import "PCOCocoaKeyValueObject.h"

#import "ProjectorHelpers.h"

@interface ProjectorSettings : PCOCocoaKeyValueObject

+ (instancetype)userSettings;

@property (nonatomic) ProjectorAspectRatio aspectRatio;
@property (nonatomic) UIKeyboardType alertKeyboardType;
@property (nonatomic) UIViewContentMode preferredContentMode;
@property (nonatomic) ProjectorFileStorageDuration fileStorageDuration;
@property (nonatomic) ProjectorGridSize gridSize;
@property (nonatomic) ProjectorConfidenceTextWeight confidenceTextWeight;
@property (nonatomic) BOOL secondScreenEnabled;

@property (nonatomic) BOOL useGamekitProtocol;
@property (nonatomic) BOOL usePusherProtocol;
@property (nonatomic) BOOL useMultipeerProtocol;

@property (nonatomic) BOOL bKeyTriggersBlack;
@property (nonatomic) BOOL lKeyTriggersLogo;
@property (nonatomic) BOOL spaceTriggersNext;
@property (nonatomic) BOOL cKeyClearsLyrics;

@property (nonatomic) NSString *forwardKeyString;
@property (nonatomic) NSString *backKeyString;

+ (void)setDefaultValues;

- (void)notifyChangedSettings;

@end

PCO_EXTERN_STRING ProjectorSettingsDidChangeNotification;
PCO_EXTERN_STRING kProjectorSettingsChangedKeys;

PCO_EXTERN_STRING kProjectorDefaultAspectRatioSetting;
PCO_EXTERN_STRING kProjectorAlertKeyboardTypeSetting;
PCO_EXTERN_STRING kProjectorPreferredContentModeSetting;
PCO_EXTERN_STRING kProjectorSecondScreenEnabledSetting;
PCO_EXTERN_STRING kProjectorFileStorageDurationSetting;
PCO_EXTERN_STRING kProjectorGrideSizeSetting;
PCO_EXTERN_STRING kProjectorConfidenceTextWeightSetting;

PCO_EXTERN_STRING kProjectorProtocolGameKitSetting;
PCO_EXTERN_STRING kProjectorProtocolPusherSetting;
PCO_EXTERN_STRING kProjectorProtocolMultipeerSetting;

PCO_EXTERN_STRING kProjectorKeyboardBKeyForBlackSetting;
PCO_EXTERN_STRING kProjectorKeyboardLKeyForLogoSetting;
PCO_EXTERN_STRING kProjectorKeyboardSpaceKeyForNextSetting;
PCO_EXTERN_STRING kProjectorKeyboardCKeyForClearSetting;
PCO_EXTERN_STRING kProjectorKeyboardFwdKeyStringSetting;
PCO_EXTERN_STRING kProjectorKeyboardBkKeyStringSetting;

#define UIViewContentModeProjectorPreferred [[ProjectorSettings userSettings] preferredContentMode]

#endif
