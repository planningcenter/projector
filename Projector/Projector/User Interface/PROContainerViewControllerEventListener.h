//
//  PROContainerViewControllerEventListener.h
//  Projector
//
//  Created by Skylar Schipper on 3/24/14.
//

#ifndef Projector_PROContainerViewControllerEventListener_h
#define Projector_PROContainerViewControllerEventListener_h

@class PROPlanContainerViewController;
@class PRODisplayItem;

@protocol PROContainerViewControllerEventListener <NSObject>

@optional
/**
 *  Called whenever the reciever is added to the event listeners.
 *
 *  There is no removal call because objects are stored weakly and can be removed by dealocation.
 */
- (void)registerForController:(PROPlanContainerViewController *)controller;

@optional
- (void)currentPlayingIndexPathWillChange:(NSIndexPath *)indexPath;
- (void)currentPlayingIndexPathDidChange:(NSIndexPath *)indexPath;

- (void)nextUpIndexPathWillChange:(NSIndexPath *)indexPath;
- (void)nextUpIndexPathDidChange:(NSIndexPath *)indexPath;

- (void)userInterfaceWillRefresh;

- (void)currentItemWillChange:(PRODisplayItem *)currentItem;
- (void)currentItemDidChange:(PRODisplayItem *)currentItem;

- (void)upNextItemWillChange:(PRODisplayItem *)nextItem;
- (void)upNextItemDidChange:(PRODisplayItem *)nextItem;

@end

#endif
