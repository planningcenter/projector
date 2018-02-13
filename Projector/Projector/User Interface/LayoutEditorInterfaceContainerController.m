/*!
 * LayoutEditorInterfaceContainerController.m
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#import "LayoutEditorInterfaceContainerController.h"
#import "PROLogoLoadingView.h"

@interface LayoutEditorInterfaceContainerController ()

@end

@implementation LayoutEditorInterfaceContainerController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loadView {
    [super loadView];
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[PROAppDelegate delegate] isPad]) {
        return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.layout) {
        [self setChildLayout:self.layout];
    }
}

- (void)setLayout:(PCOSlideLayout *)layout {
    _layout = layout;
    [self setChildLayout:layout];
    
    self.currentTextLayout = layout.lyricTextLayout;
    self.currentSongLayout = layout.songInfoLayout;

    [[PCOCoreDataManager sharedManager] save:NULL];
    self.layout.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
    [self.layout.managedObjectContext.undoManager beginUndoGrouping];
    [self.layout.managedObjectContext.undoManager setActionName:@"Custom Layout Editing"];
}
- (void)setChildLayout:(PCOSlideLayout *)layout {
    for (UIViewController <LayoutEditorInterfaceContainerSubController> *controller in [self layoutSubControllers]) {
        [controller setLayout:layout];
    }
    for (id<LayoutEditorInterfaceContainerSubController> object in [self.objectHash allObjects]) {
        [object setLayout:layout];
    }
    [self updateUserInterfaceUpdateForObjectChange:nil];
}
- (void)setCurrentTextLayout:(PCOSlideTextLayout *)currentTextLayout {
    _currentTextLayout = currentTextLayout;
    [self setChildTextLayout:currentTextLayout];
}
- (void)setCurrentSongLayout:(PCOSlideTextLayout *)currentSongLayout {
    _currentSongLayout = currentSongLayout;
    [self setChildSongInfoLayout:currentSongLayout];
}
- (void)setChildTextLayout:(PCOSlideTextLayout *)childLayout {
    for (UIViewController <LayoutEditorInterfaceContainerSubController> *controller in [self layoutSubControllers]) {
        [controller updateCurrentTextLayout];
        [controller updateUserInterfaceForObjectChanges];
    }
    for (id<LayoutEditorInterfaceContainerSubController> object in [self.objectHash allObjects]) {
        [object updateCurrentTextLayout];
        [object updateUserInterfaceForObjectChanges];
    }
    [self updateUserInterfaceUpdateForObjectChange:nil];
}
- (void)setChildSongInfoLayout:(PCOSlideTextLayout *)childLayout {
    for (UIViewController <LayoutEditorInterfaceContainerSubController> *controller in [self layoutSubControllers]) {
        [controller updateCurrentTextLayout];
        [controller updateUserInterfaceForObjectChanges];
    }
    for (id<LayoutEditorInterfaceContainerSubController> object in [self.objectHash allObjects]) {
        [object updateCurrentTextLayout];
        [object updateUserInterfaceForObjectChanges];
    }
    [self updateUserInterfaceUpdateForObjectChange:nil];
}

- (void)updateUserInterfaceUpdateForObjectChange:(id)sender {
    [self updateUserInterfaceUpdateForObjectChange:sender animated:NO];
}
- (void)updateUserInterfaceUpdateForObjectChange:(id)sender animated:(BOOL)animated {
    void(^animation)(void) = ^{
        for (UIViewController <LayoutEditorInterfaceContainerSubController> *controller in [self layoutSubControllers]) {
            if (controller != sender) {
                [controller updateUserInterfaceForObjectChanges];
            }
        }
        for (id<LayoutEditorInterfaceContainerSubController> object in [self.objectHash allObjects]) {
            if (object != sender) {
                [object updateUserInterfaceForObjectChanges];
            }
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:animation];
    } else {
        [UIView performWithoutAnimation:animation];
    }
}

- (NSArray *)layoutSubControllers {
    NSArray *allControllers = [self _recursiveControllersForViewController:self];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:allControllers.count];
    
    for (UIViewController *controller in allControllers) {
        if ([controller conformsToProtocol:@protocol(LayoutEditorInterfaceContainerSubController)]) {
            [array addObject:controller];
        }

    }
    
    return [array copy];
}

- (NSArray *)_recursiveControllersForViewController:(UIViewController *)controller {
    NSMutableSet *subSet = [NSMutableSet setWithCapacity:10];
    
    [subSet addObject:controller];
    
    NSEnumerator *enumerator = [controller.childViewControllers objectEnumerator];
    UIViewController *subController = [enumerator nextObject];
    while (subController) {
        [subSet addObjectsFromArray:[self _recursiveControllersForViewController:subController]];
        subController = [enumerator nextObject];
    }
    
    return [subSet allObjects];
}

- (void)updatePreferredFontSize {
    [super updatePreferredFontSize];
    
    self.titleLabel.font = [UIFont headerDefaultFont];
}

- (NSHashTable *)objectHash {
    if (!_objectHash) {
        _objectHash = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:10];
    }
    return _objectHash;
}
- (void)registerObjectForChanges:(id<LayoutEditorInterfaceContainerSubController>)subController {
    [self.objectHash addObject:subController];
}

#pragma mark -
#pragma mark - Save
- (void)saveCurrentLayoutWithCompletion:(void(^)(NSError *))completion {
    [self.view endEditing:YES];
    
    void(^complete)(NSError *) = ^(NSError *error) {
        PCOError(error);
        if (completion) {
            completion(nil);
        }
    };
    
    if ([self.layout isNew]) {
        [[[PCOCoreDataManager sharedManager] layoutsController] postLayout:self.layout completion:complete];
    } else {
        [[[PCOCoreDataManager sharedManager] layoutsController] updateLayout:self.layout completion:complete];
    }
    
    
}


@end
