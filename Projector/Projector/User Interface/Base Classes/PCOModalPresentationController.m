/*!
 * PCOModalPresentationController.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 10/23/14
 */

#import "PCOModalPresentationController.h"

@interface PCOModalPresentationController ()

@end

@implementation PCOModalPresentationController

- (BOOL)shouldRemovePresentersView {
    return NO;
}
- (BOOL)shouldPresentInFullscreen {
    return NO;
}

- (void)presentationTransitionWillBegin {
    NSLog(@"%d %s",__LINE__,__PRETTY_FUNCTION__);
}
- (void)presentationTransitionDidEnd:(BOOL)completed {
    NSLog(@"%d %s",__LINE__,__PRETTY_FUNCTION__);
}
- (void)dismissalTransitionWillBegin {
    NSLog(@"%d %s",__LINE__,__PRETTY_FUNCTION__);
}
- (void)dismissalTransitionDidEnd:(BOOL)completed {
    NSLog(@"%d %s",__LINE__,__PRETTY_FUNCTION__);
}

@end
