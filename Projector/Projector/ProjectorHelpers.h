//
//  ProjectorHelpers.h
//  Projector
//
//  Created by Skylar Schipper on 3/14/14.
//

#ifndef Projector_ProjectorHelpers_h
#define Projector_ProjectorHelpers_h

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSUInteger, ProjectorAspectRatio) {
    ProjectorAspectRatio_16_9  = 0,
    ProjectorAspectRatio_4_3   = 1,
};
NS_INLINE float_t ProjectorAspectForRatio(ProjectorAspectRatio ratio) {
    if (ratio == ProjectorAspectRatio_4_3) {
        return 1.333333333;
    }
    return 1.777777778;
}
NS_INLINE NSLayoutConstraint *ProjectorCreateAspectConstraint(ProjectorAspectRatio ratio, UIView *view) {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:ProjectorAspectForRatio(ratio) constant:0.0];
}

typedef NS_ENUM(NSUInteger, ProjectorGridSize) {
    ProjectorGridSizeNormal = 0,
    ProjectorGridSizeLarge  = 1,
    ProjectorGridSizeSmall  = 2
};
typedef NS_ENUM(NSUInteger, ProjectorConfidenceTextWeight) {
    ProjectorConfidenceTextWeightNormal = 0,
    ProjectorConfidenceTextWeightBold   = 1,
};

typedef NS_ENUM (NSUInteger, ProjectorFileStorageDuration) {
    ProjectorFileStorageDurationOneWeek    = 0, // 8 days
    ProjectorFileStorageDurationTwoWeeks   = 1, // 15 days
    ProjectorFileStorageDurationThreeWeeks = 2, // 22 days
    ProjectorFileStorageDurationFourWeeks  = 3  // 29 days
};
NS_INLINE NSTimeInterval ProjectorFileStorageDurationInterval(ProjectorFileStorageDuration duration) {
    switch (duration) {
        case ProjectorFileStorageDurationOneWeek:
            return 0xA8C00;
            break;
        case ProjectorFileStorageDurationTwoWeeks:
            return 0x13C680;
            break;
        case ProjectorFileStorageDurationThreeWeeks:
            return 0x1D0100;
            break;
        case ProjectorFileStorageDurationFourWeeks:
            return 0x263B80;
            break;
        default:
            break;
    }
    return MAXFLOAT;
}

#endif
