//
//  LESLyricsEditorTextShadowOffsetCell.h
//  Projector
//
//  Created by Skylar Schipper on 6/23/14.
//

#import "LayoutEditorSidebarBaseTableViewCell.h"

@interface LESLyricsEditorTextShadowOffsetCell : LayoutEditorSidebarBaseTableViewCell

- (void)setSize:(CGSize)size;
- (CGSize)size;

@property (nonatomic, copy) void(^sizePickerHandler)(CGSize);

@end
