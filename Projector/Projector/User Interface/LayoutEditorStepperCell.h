/*!
 * LayoutEditorStepperCell.h
 *
 *
 * Created by Skylar Schipper on 6/10/14
 */

#ifndef LayoutEditorStepperCell_h
#define LayoutEditorStepperCell_h

#import "PCOTableViewCell.h"

typedef NS_ENUM(NSUInteger, LayoutEditorStepperStyle) {
    LayoutEditorStepperStyleInteger = 0,
    LayoutEditorStepperStyleFloat   = 1
};

@interface LayoutEditorStepperCell : PCOTableViewCell

@property (nonatomic, strong) NSNumber *maxValue;
@property (nonatomic, strong) NSNumber *minValue;

@property (nonatomic, strong) NSNumber *value;

@property (nonatomic) LayoutEditorStepperStyle stepperStyle;

@property (nonatomic, copy) void(^valueChangeHandler)(LayoutEditorStepperCell *cell, NSNumber *value);

@end

PCO_EXTERN_STRING kLayoutEditorStepperCellIdentifier;

#endif
