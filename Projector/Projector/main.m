//
//  main.m
//  Projector
//
//  Created by Skylar Schipper on 3/12/14.
//

#import <UIKit/UIKit.h>

#import "PROAppDelegate_phone.h"
#import "PROAppDelegate_pad.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([PROAppDelegate_pad class]));
        }
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PROAppDelegate_phone class]));
    }
}
