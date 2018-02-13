//
//  UIColor+PROColors.m
//  Projector
//
//  Created by Skylar Schipper on 3/13/14.
//

#import "UIColor+PROColors.h"
#import "PCOKitColors.h"

#define __color(r,g,b,a) ({\
    static UIColor *color;\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        color = pco_kit_RGBA(r,g,b,a);\
    });\
    color;\
})
#define _color(r,g,b) __color(r,g,b,1.0)
#define __color_hex(hex, a) ({\
    static UIColor *color;\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        color = pco_kit_HEXA(hex,a);\
    });\
    color;\
})

@implementation UIColor (PROColors)

+ (UIColor *)projectorOrangeColor {
    return __color(246,156,27,1.0);
}
+ (UIColor *)projectorBlackColor {
    return __color(20,20,22,1.0);
}
+ (UIColor *)projectorDeleteColor {
    return __color(197,80,61, 1.0);
}
+ (UIColor *)projectorConfirmColor {
    return __color(117,184,107, 1.0);
}

+ (UIColor *)sidebarDetailsTextColor {
    return __color(103,104,112, 1.0);
}
+ (UIColor *)sidebarCellTintColor {
    return __color(65,66,78,1.0);
}
+ (UIColor *)sidebarBackgroundColor {
    return __color(20,20,22,1.0);
}
+ (UIColor *)sidebarLightBackgroundColor {
    return __color(33,33,35,1.0);
}
+ (UIColor *)sidebarTextColor {
    return __color(157,158,165,1.0);
}
+ (UIColor *)sidebarCellBackgroundColor {
    return __color(28,28,32,1.0);
}
+ (UIColor *)sidebarCellSeparatorColor {
    return __color(36,36,41, 1.0);
}
+ (UIColor *)sidebarRoundButtonsOffColor {
    return __color(72,72,80, 1.0);
}
+ (UIColor *)sidebarHeaderFooterTextColor {
    return __color(89,90,97, 1.0);
}

+ (UIColor *)navigationBarDefaultColor {
    return __color(41,42,47,1.0);
}
+ (UIColor *)navigationBarDefaultTintColor {
    return __color(119,121,126, 1.0);
}

+ (UIColor *)planGridBackgroundColor {
    return __color(37,38,43, 1.0);
}
+ (UIColor *)planGridSectionHeaderBackgroundColor {
    return __color(30,29,34, 1.0);
}
+ (UIColor *)planGridSectionHeaderOffTextColor {
    return __color_hex(0x64646D, 1.0);
}
+ (UIColor *)planGridSectionHeaderButtonOnColor {
    return __color_hex(0x78787A, 1.0);
}
+ (UIColor *)planGridSectionHeaderItemHeaderBackgroundColor {
    return __color_hex(0x37373F, 1.0);
}
+ (UIColor *)planGridSectionHeaderItemHeaderTextColor {
    return __color_hex(0x909196, 1.0);
}

+ (UIColor *)planOutputBackgroundColor {
    return __color(28,27,32, 1.0);
}
+ (UIColor *)planOutputButtonOffBackgroundColor {
    return __color(67,68,73, 1.0);
}
+ (UIColor *)planOutputCurrentBarTintColor {
    return __color(112,112,120, 1.0);
}
+ (UIColor *)planOutputSlateColor {
    return __color(92,94,114, 1.0);
}

+ (UIColor *)nextUpItemBlueColor {
    return __color(0,175,238,1.0);
}
+ (UIColor *)currentItemGreenColor {
    return __color(127,231,120, 1.0);
}

+ (UIColor *)modalViewBackgroundColor {
    return __color(35,36,41, 1.0);
}
+ (UIColor *)modalViewStrokeColor {
    return __color(82,81,92, 1.0);
}
+ (UIColor *)modalViewHeaderViewBackgroundColor {
    return __color(25,26,31, 1.0);
}
+ (UIColor *)modalViewTextEntryBackgroundColor {
    return __color(58,61,66, 1.0);
}
+ (UIColor *)modalViewTextColor {
    return __color(164,165,175, 1.0);
}
+ (UIColor *)modalBackgroundTextColor {
    return __color(97,97,110, 1.0);
}
+ (UIColor *)modalPositionSelectedStrokeColor {
    return __color(176,234,165, 1.0);
}
+ (UIColor *)modalPositionPickerBackgroundColor {
    return __color(29,28,33, 1.0);
}
+ (UIColor *)modalPositionTextColor {
    return __color(188,188,196, 1.0);
}
+ (UIColor *)modalTextLabelTextColor {
    return __color(139,139,151, 1.0);
}
+ (UIColor *)modalTextStyleStrokeColor {
    return __color(98,162,87, 1.0);
}
+ (UIColor *)modalTextStyleBackgroundColor {
    return __color(41,53,44, 1.0);
}

+ (UIColor *)layoutListSectionHeaderColor {
    return __color_hex(0x181819, 1.0);
}
+ (UIColor *)layoutListSectionStrokeColor {
    return __color_hex(0x46464d, 1.0);
}

+ (UIColor *)layoutControllerToolbarBackgroundColor {
    return _color(31,31,35);
}
+ (UIColor *)layoutControllerToolbarDoneButtonColor {
    return [self projectorOrangeColor];
}
+ (UIColor *)layoutControllerPreviewBackgroundColor {
    return [self layoutEditorBackgroundColor];
}
+ (UIColor *)layoutEditorSidebarTitleBackgroundColor {
    return _color(23,23,25);
}
+ (UIColor *)layoutEditorSidebarTitleTextColor {
    return _color(179,180,187);
}
+ (UIColor *)layoutEditorSidebarSectionHeaderBackgroundColor {
    return _color(8,8,8);
}
+ (UIColor *)layoutEditorSidebarSectionHeaderTextColor {
    return _color(76,74,81);
}
+ (UIColor *)layoutEditorSidebarColorPickerHexTextColor {
    return _color(84,88,91);
}
+ (UIColor *)layoutEditorSidebarColorPickerHexTextEntryTextColor {
    return _color(124,125,129);
}
+ (UIColor *)layoutEditorSidebarColorPickerHexTextEntryBackgroundColor {
    return _color(21,21,23);
}
+ (UIColor *)layoutEditorSidebarColorPickerHexTextEntryStrokeColor {
    return _color(51,54,58);
}
+ (UIColor *)layoutEditorSidebarControlStrokeColor {
    return _color(62,61,74);
}
+ (UIColor *)layoutEditorSidebarTableViewBackgroundColor {
    return _color(18,18,19);
}
+ (UIColor *)layoutEditorSidebarTableViewValueTextColor {
    return _color(200.0, 200.0, 200.0);
}

+ (UIColor *)layoutEditorTabTextColor {
    return _color(90,90,96);
}
+ (UIColor *)layoutEditorBackgroundColor {
    return _color(28,28,32);
}

+ (UIColor *)layoutEditorSettingsBackgroundColor {
    return [self sidebarCellBackgroundColor];
}

+ (UIColor *)layoutEditorPresetsTextColor {
    return [self layoutEditorSidebarSectionHeaderTextColor];
}

+ (UIColor *)sessionsTintColor {
    return _color(255,150,65);
}

+ (UIColor *)sessionsCellNormalBackgroundColor {
    return _color(36,36,38);
}

+ (UIColor *)sessionsHeaderTextColor {
    return _color(85,85,92);
}

+ (UIColor *)sessionsClientTextColor {
    return _color(189,189,195);
}

+ (UIColor *)sessionsAvailableSessionsTextColor {
    return _color(94,95,102);
}

+ (UIColor *)sessionsInfoTextColor {
    return _color(130,130,143);
}

+ (UIColor *)sessionsMirrorModeColor {
    return _color(242,143,63);
}

+ (UIColor *)sessionsConfidenceColor {
    return _color(255,73,69);
}

+ (UIColor *)sessionsNoLyricsColor {
    return _color(72,147,176);
}

+ (UIColor *)logoPickerStrokeColor {
    return _color(89,89,98);
}
+ (UIColor *)logoPickerCellTextColor {
    return _color(104,105,121);
}

+ (UIColor *)captializedTextHeaderBackgroundColor {
    return _color(24,24,25);
}
+ (UIColor *)captializedTextHeaderTextColor {
    return _color(70,70,77);
}

+ (UIColor *)mediaSelectedCellTitleColor {
    return _color(203,203,203);
}
+ (UIColor *)mediaSelectedCellSubTitleColor {
    return _color(90,90,105);
}
+ (UIColor *)mediaSelectedCellBackgroundColor {
    return _color(42,42,47);
}
+ (UIColor *)mediaSelectedCellSelectedColor {
    return _color(62,62,67);
}
+ (UIColor *)mediaStepperCellStepperColor {
    return _color(78,78,90);
}
+ (UIColor *)mediaTableViewSeparatorColor {
    return _color(14,14,16);
}


+ (UIColor *)sequenceInstructionsViewBackgroundColor {
    return _color(39,38,43);
}
+ (UIColor *)sequenceInstructionsViewTextColor {
    return _color(116,118,138);
}

+ (UIColor *)sequenceTableViewBorderColor {
    return _color(92,93,103);
}
+ (UIColor *)sequenceTableCellTitleColor {
    return _color(134,134,146);
}

+ (UIColor *)sequenceTableCellBackgroundColor {
    return _color(33,32,37);
}
+ (UIColor *)sequenceTableCellSelectedColor {
    return _color(55,56,60);
}
+ (UIColor *)sequenceTableViewSeparatorColor {
    return _color(49,50,55);
}

+ (UIColor *)elementsTableCellBackgroundColor {
    return _color(31,30,35);
}
+ (UIColor *)elementsTableCellSelectedColor {
    return _color(51,50,55);
}
+ (UIColor *)elementsTableViewSeparatorColor {
    return _color(15,16,17);
}

+ (UIColor *)lyricsEditorBackgroundColor {
    return _color(36,35,40);
}
+ (UIColor *)lyricsTextViewBackgroundColor {
    return _color(60,61,66);
}
+ (UIColor *)lyricsTextViewOutlineColor {
    return _color(16,18,23);
}
+ (UIColor *)lyricsTextViewTextColor {
    return _color(166,166,176);
}

+ (UIColor *)customSlideSaveButtonColor {
    return _color(116,184,106);
}

+ (UIColor *)customSlidesListBackgroundColor {
    return _color(36,35,40);
}
+ (UIColor *)customSlidesDragAreaBackgroundColor {
    return _color(52,52,60);
}
+ (UIColor *)customSlidesBorderColor {
    return _color(88,88,98);
}
+ (UIColor *)customSlidesCellBackgroundColor {
    return _color(30,29,34);
}
+ (UIColor *)customSlidesCellTextColor {
    return _color(128,128,140);
}
+ (UIColor *)customSlidesTableViewSelectedColor {
    return _color(50,49,54);
}
+ (UIColor *)customSlidesTableViewSeparatorColor {
    return _color(56,56,64);
}
+ (UIColor *)customSlidesDeleteTextColor {
    return _color(196,80,61);
}
+ (UIColor *)customSlidesDeleteColor {
    return _color(221,78,74);
}

+ (UIColor *)mobilePlanViewBlackColor {
    return __color_hex(0x17171A, 1.0);
}
+ (UIColor *)mobileGridViewBackgroundColor {
    return __color_hex(0x1C1C20, 1.0);
}
+ (UIColor *)mobilePlanViewStrokeColor {
    return __color_hex(0x1F1F23, 1.0);
}
+ (UIColor *)mobilePlanViewTopBarTintColor {
    return __color_hex(0x5A5962, 1.0);
}
+ (UIColor *)mobileGridViewCellTitleBackgroundColor {
    return __color_hex(0x17161B, 1.0);
}
+ (UIColor *)mobileGridViewCellTitleTextColor {
    return __color_hex(0xFD963E, 1.0);
}

@end
