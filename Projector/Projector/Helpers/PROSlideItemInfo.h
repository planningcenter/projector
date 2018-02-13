//
//  PROSlideItemInfo.h
//  Projector
//
//  Created by Skylar Schipper on 11/19/14.
//

#ifndef Projector_PROSlideItemInfo_h
#define Projector_PROSlideItemInfo_h

typedef struct PROSlideItemInfo {
    UIEdgeInsets insets;
    CGFloat      fontSize;
    NSUInteger   lineCount;
    BOOL         performSmartFormatting;
} PROSlideItemInfo;

FOUNDATION_STATIC_INLINE NSString *NSStringFromPROSlideItemInfo(PROSlideItemInfo info) {
    return [NSString stringWithFormat:@"{%@, %f, %tu, %i}",NSStringFromUIEdgeInsets(info.insets),info.fontSize,info.lineCount,info.performSmartFormatting];
}

#endif
