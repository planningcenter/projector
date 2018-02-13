/*!
 * ProjectorSettings.m
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#import "ProjectorSettings.h"
#import "PCOKeyValueStore.h"

static NSString *const kProjectorUserSettingsScope = @"user_settings";

@interface ProjectorSettings ()

@property (nonatomic, strong) NSMutableSet *changeKeySet;

@end

@implementation ProjectorSettings

+ (instancetype)userSettings {
    static ProjectorSettings *settings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [[[self class] alloc] init];
    });
    return settings;
}

// MARK: - Aspect
- (void)setAspectRatio:(ProjectorAspectRatio)ratio {
    [self setObject:@(ratio) forKey:kProjectorDefaultAspectRatioSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorDefaultAspectRatioSetting object:self];
}
- (ProjectorAspectRatio)aspectRatio {
    return [[self objectForKey:kProjectorDefaultAspectRatioSetting] unsignedIntegerValue];
}

// MARK: - Grid Size
- (void)setGridSize:(ProjectorGridSize)gridSize {
    [self setObject:@(gridSize) forKey:kProjectorGrideSizeSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorGrideSizeSetting object:self];
}
- (ProjectorGridSize)gridSize {
    return [[self objectForKey:kProjectorGrideSizeSetting] unsignedIntegerValue];
}

// MARK: - Keyboard Type
- (void)setAlertKeyboardType:(UIKeyboardType)type {
    [self setObject:@(type) forKey:kProjectorAlertKeyboardTypeSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorAlertKeyboardTypeSetting object:self];
}
- (UIKeyboardType)alertKeyboardType {
    return [[self objectForKey:kProjectorAlertKeyboardTypeSetting] integerValue];
}

// MARK: - Content Mode
- (void)setPreferredContentMode:(UIViewContentMode)preferredContentMode {
    if (preferredContentMode == UIViewContentModeScaleAspectFill) {
        [self setObject:@1 forKey:kProjectorPreferredContentModeSetting];
    } else {
        [self setObject:@0 forKey:kProjectorPreferredContentModeSetting];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorPreferredContentModeSetting object:self];
}
- (UIViewContentMode)preferredContentMode {
    NSNumber *number = [self objectForKey:kProjectorPreferredContentModeSetting];
    if (!number || [number isEqualToNumber:@0]) {
        return UIViewContentModeScaleAspectFit;
    }
    return UIViewContentModeScaleAspectFill;
}

// MARK: - Confidence Text Weight
- (void)setConfidenceTextWeight:(ProjectorConfidenceTextWeight)confidenceTextWeight {
    [self setObject:@(confidenceTextWeight) forKey:kProjectorConfidenceTextWeightSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorConfidenceTextWeightSetting object:self];
}
- (ProjectorConfidenceTextWeight)confidenceTextWeight {
    return [[self objectForKey:kProjectorConfidenceTextWeightSetting] unsignedIntegerValue];
}

// MARK: - File Duration
- (void)setFileStorageDuration:(ProjectorFileStorageDuration)duration {
    [self setObject:@(duration) forKey:kProjectorFileStorageDurationSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorFileStorageDurationSetting object:self];
}
- (ProjectorFileStorageDuration)fileStorageDuration {
    return [[self objectForKey:kProjectorFileStorageDurationSetting] unsignedIntegerValue];
}

// MARK: - Second Screen
- (void)setSecondScreenEnabled:(BOOL)flag {
    [self setObject:@(flag) forKey:kProjectorSecondScreenEnabledSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorSecondScreenEnabledSetting object:self];
}
- (BOOL)secondScreenEnabled {
    return [[self objectForKey:kProjectorSecondScreenEnabledSetting] boolValue];
}

// MARK: - Game Kit
- (void)setUseGamekitProtocol:(BOOL)useGamekitProtocol {
    [self setObject:@(useGamekitProtocol) forKey:kProjectorProtocolGameKitSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorProtocolGameKitSetting object:self];
}
- (BOOL)useGamekitProtocol {
    return [[self objectForKey:kProjectorProtocolGameKitSetting] boolValue];
}

// MARK: - Pusher
- (void)setUsePusherProtocol:(BOOL)usePusherProtocol {
    [self setObject:@(usePusherProtocol) forKey:kProjectorProtocolPusherSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorProtocolPusherSetting object:self];
}
- (BOOL)usePusherProtocol {
    return [[self objectForKey:kProjectorProtocolPusherSetting] boolValue];
}

// MARK: - Mutlipeer
- (void)setUseMultipeerProtocol:(BOOL)useMultipeerProtocol {
    [self setObject:@(useMultipeerProtocol) forKey:kProjectorProtocolMultipeerSetting];
    [[NSNotificationCenter defaultCenter] postNotificationName:kProjectorProtocolMultipeerSetting object:self];
}
- (BOOL)useMultipeerProtocol {
    return [[self objectForKey:kProjectorProtocolMultipeerSetting] boolValue];
}

// MARK: - fwd Key String
- (void)setForwardKeyString:(NSString *)forwardKeyString {
    [self setObject:forwardKeyString forKey:kProjectorKeyboardFwdKeyStringSetting];
}
-(NSString *)forwardKeyString {
    return [self objectForKey:kProjectorKeyboardFwdKeyStringSetting];
}

// MARK: - bk Key String
- (void)setBackKeyString:(NSString *)backKeyString {
    [self setObject:backKeyString forKey:kProjectorKeyboardBkKeyStringSetting];
}
-(NSString *)backKeyString {
    return [self objectForKey:kProjectorKeyboardBkKeyStringSetting];
}

// MARK: - B key for Black
- (void)setBKeyTriggersBlack:(BOOL)bKeyTriggersBlack {
    [self setObject:@(bKeyTriggersBlack) forKey:kProjectorKeyboardBKeyForBlackSetting];
}
- (BOOL)bKeyTriggersBlack {
    return [[self objectForKey:kProjectorKeyboardBKeyForBlackSetting] boolValue];
}

// MARK: - L key for Logo
- (void)setLKeyTriggersLogo:(BOOL)lKeyTriggersLogo {
    [self setObject:@(lKeyTriggersLogo) forKey:kProjectorKeyboardLKeyForLogoSetting];
}
- (BOOL)lKeyTriggersLogo {
    return [[self objectForKey:kProjectorKeyboardLKeyForLogoSetting] boolValue];
}

// MARK: - Space key for Next
- (void)setSpaceTriggersNext:(BOOL)spaceTriggersNext {
    [self setObject:@(spaceTriggersNext) forKey:kProjectorKeyboardSpaceKeyForNextSetting];
}
- (BOOL)spaceTriggersNext {
    return [[self objectForKey:kProjectorKeyboardSpaceKeyForNextSetting] boolValue];
}

// MARK: - C key for Clear Lyrics
- (void)setCKeyClearsLyrics:(BOOL)cKeyClearsLyrics {
    [self setObject:@(cKeyClearsLyrics) forKey:kProjectorKeyboardCKeyForClearSetting];
}
- (BOOL)cKeyClearsLyrics {
    return [[self objectForKey:kProjectorKeyboardCKeyForClearSetting] boolValue];
}

// MARK: - Set defaults
+ (void)setDefaultValues {
    if (![self.userSettings objectForKey:kProjectorDefaultAspectRatioSetting]) {
        [self.userSettings setAspectRatio:ProjectorAspectRatio_16_9];
    }
    if (![self.userSettings objectForKey:kProjectorSecondScreenEnabledSetting]) {
        [self.userSettings setSecondScreenEnabled:YES];
    }
    if (![self.userSettings objectForKey:kProjectorAlertKeyboardTypeSetting]) {
        [self.userSettings setAlertKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    }
    if (![self.userSettings objectForKey:kProjectorPreferredContentModeSetting]) {
        [self.userSettings setPreferredContentMode:UIViewContentModeScaleAspectFit];
    }
    if (![self.userSettings objectForKey:kProjectorFileStorageDurationSetting]) {
        [self.userSettings setFileStorageDuration:ProjectorFileStorageDurationTwoWeeks];
    }
    if (![self.userSettings objectForKey:kProjectorProtocolGameKitSetting]) {
        [self.userSettings setUseGamekitProtocol:YES];
    }
    if (![self.userSettings objectForKey:kProjectorProtocolPusherSetting]) {
        [self.userSettings setUsePusherProtocol:YES];
    }
    if (![self.userSettings objectForKey:kProjectorProtocolMultipeerSetting]) {
        [self.userSettings setUseMultipeerProtocol:YES];
    }
    if (![self.userSettings objectForKey:kProjectorKeyboardFwdKeyStringSetting]) {
        [self.userSettings setForwardKeyString:@""];
    }
    if (![self.userSettings objectForKey:kProjectorKeyboardBkKeyStringSetting]) {
        [self.userSettings setBackKeyString:@""];
    }
    if (![self.userSettings objectForKey:kProjectorKeyboardBKeyForBlackSetting]) {
        [self.userSettings setBKeyTriggersBlack:YES];
    }
    if (![self.userSettings objectForKey:kProjectorKeyboardLKeyForLogoSetting]) {
        [self.userSettings setLKeyTriggersLogo:YES];
    }
    if (![self.userSettings objectForKey:kProjectorKeyboardSpaceKeyForNextSetting]) {
        [self.userSettings setSpaceTriggersNext:YES];
    }
    if (![self.userSettings objectForKey:kProjectorKeyboardCKeyForClearSetting]) {
        [self.userSettings setCKeyClearsLyrics:YES];
    }
    if (![self.userSettings objectForKey:kProjectorGrideSizeSetting]) {
        [self.userSettings setGridSize:ProjectorGridSizeNormal];
    }
    if (![self.userSettings objectForKey:kProjectorConfidenceTextWeightSetting]) {
        [self.userSettings setConfidenceTextWeight:ProjectorConfidenceTextWeightNormal];
    }
    
    [self.userSettings notifyChangedSettings];
}

// MARK: - Subclass hooks for setting/getting values
- (void)setPrimitiveValue:(id)object forKey:(NSString *)key {
    [self.changeKeySet addObject:key];
    [[PCOKeyValueStore defaultStore] setObject:object forKey:key scope:kProjectorUserSettingsScope];
}
- (id)primitiveValueForKey:(NSString *)key {
    return [[PCOKeyValueStore defaultStore] objectForKey:key scope:kProjectorUserSettingsScope];
}

// MARK: - Setting Change Tracking
- (NSMutableSet *)changeKeySet {
    if (!_changeKeySet) {
        _changeKeySet = [NSMutableSet set];
    }
    return _changeKeySet;
}
- (void)notifyChangedSettings {
    NSArray *changes = [self.changeKeySet allObjects];
    _changeKeySet = nil;
    if (changes.count > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ProjectorSettingsDidChangeNotification object:self userInfo:@{kProjectorSettingsChangedKeys: PCOSafe(changes)}];
    }
}


@end

_PCO_EXTERN_STRING ProjectorSettingsDidChangeNotification = @"ProjectorSettingsDidChangeNotification";
_PCO_EXTERN_STRING kProjectorSettingsChangedKeys = @"kProjectorSettingsChangedKeys";

_PCO_EXTERN_STRING kProjectorDefaultAspectRatioSetting = @"kProjectorDefaultAspectRatioSetting";
_PCO_EXTERN_STRING kProjectorAlertKeyboardTypeSetting = @"kProjectorAlertKeyboardTypeSetting";
_PCO_EXTERN_STRING kProjectorPreferredContentModeSetting = @"kProjectorPreferredContentModeSetting";
_PCO_EXTERN_STRING kProjectorSecondScreenEnabledSetting = @"kProjectorSecondScreenEnabledSetting";
_PCO_EXTERN_STRING kProjectorFileStorageDurationSetting = @"kProjectorFileStorageDurationSetting";
_PCO_EXTERN_STRING kProjectorProtocolGameKitSetting = @"kProjectorProtocolGameKitSetting";
_PCO_EXTERN_STRING kProjectorProtocolPusherSetting = @"kProjectorProtocolPusherSetting";
_PCO_EXTERN_STRING kProjectorProtocolMultipeerSetting = @"kProjectorProtocolMultipeerSetting";
_PCO_EXTERN_STRING kProjectorConfidenceTextWeightSetting = @"kProjectorConfidenceTextWeightSetting";


_PCO_EXTERN_STRING kProjectorKeyboardBKeyForBlackSetting = @"kProjectorKeyboardBKeyForBlackSetting";
_PCO_EXTERN_STRING kProjectorKeyboardLKeyForLogoSetting = @"kProjectorKeyboardLKeyForLogoSetting";
_PCO_EXTERN_STRING kProjectorKeyboardSpaceKeyForNextSetting = @"kProjectorKeyboardSpaceKeyForNextSetting";
_PCO_EXTERN_STRING kProjectorKeyboardCKeyForClearSetting = @"kProjectorKeyboardCKeyForClearSetting";
_PCO_EXTERN_STRING kProjectorKeyboardFwdKeyStringSetting = @"kProjectorKeyboardFwdKeyStringSetting";
_PCO_EXTERN_STRING kProjectorKeyboardBkKeyStringSetting = @"kProjectorKeyboardBkKeyStringSetting";
_PCO_EXTERN_STRING kProjectorGrideSizeSetting = @"kProjectorGrideSizeSetting";

