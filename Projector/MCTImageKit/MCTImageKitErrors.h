//
//  MCTImageKitErrors.h
//  Projector
//
//  Created by Skylar Schipper on 10/9/14.
//

#ifndef MCTImageKit_MCTImageKitErrors_h
#define MCTImageKit_MCTImageKitErrors_h

@import Foundation;

FOUNDATION_EXTERN
NSString *const MCTImageKitErrorDomain;

typedef NS_ENUM(NSInteger, MCTImageKitError) {
    MCTImageKitErrorUnknown       = 0,
    MCTImageKitErrorContextCreate = 1,
    MCTImageKitErrorPerformScale  = 2
};

#endif
