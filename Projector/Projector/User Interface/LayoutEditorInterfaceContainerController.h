/*!
 * LayoutEditorInterfaceContainerController.h
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#ifndef LayoutEditorInterfaceContainerController_h
#define LayoutEditorInterfaceContainerController_h

#import "PCOViewController.h"

#import "PCOSlideLayout.h"
#import "PCOSlideTextLayout.h"

@protocol LayoutEditorInterfaceContainerSubController;

@interface LayoutEditorInterfaceContainerController : PCOViewController

@property (nonatomic, strong) NSHashTable *objectHash;

@property (nonatomic, weak) PCOSlideLayout *layout;
@property (nonatomic, weak) PCOSlideTextLayout *currentTextLayout;
@property (nonatomic, weak) PCOSlideTextLayout *currentSongLayout;

@property (weak, nonatomic) IBOutlet UIView *titleBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) UIActivityIndicatorView *loadingView;

- (void)registerObjectForChanges:(id<LayoutEditorInterfaceContainerSubController>)subController;

- (void)updateUserInterfaceUpdateForObjectChange:(id)sender;
- (void)updateUserInterfaceUpdateForObjectChange:(id)sender animated:(BOOL)animated;

- (NSArray *)layoutSubControllers;
- (void)saveCurrentLayoutWithCompletion:(void(^)(NSError *))completion;

@end

@protocol LayoutEditorInterfaceContainerSubController <NSObject>

@required
- (void)setLayout:(PCOSlideLayout *)layout;
@required
- (void)setTextLayout:(PCOSlideTextLayout *)textLayout;
@required
- (void)updateUserInterfaceForObjectChanges;
@required
- (void)updateCurrentTextLayout;

@end

#endif
