/*!
 * LayoutEditorSidebarTabController.m
 *
 *
 * Created by Skylar Schipper on 6/11/14
 */

#import "LayoutEditorSidebarTabController.h"
#import "PCOKeyValueStore.h"
#import "LayoutEditorSidebarNavigationSwitcher.h"

static NSString *const kLayoutEditorSidebarTabControllerLastTab = @"kLayoutEditorSidebarTabControllerLastTab";

@interface LayoutEditorSidebarTabController ()

@property (nonatomic, weak) LayoutEditorSidebarNavigationSwitcher *switcher;

@property (nonatomic, weak) PCOSlideLayout *layout;
@property (nonatomic, weak) PCOSlideTextLayout *textLayout;

@property (nonatomic, weak) UIViewController *currentContentController;

@end

@implementation LayoutEditorSidebarTabController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor projectorBlackColor];
    
    LayoutEditorSidebarNavigationSwitcher *switcher = [[LayoutEditorSidebarNavigationSwitcher alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    [switcher addTarget:self action:@selector(controlValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    self.switcher = switcher;
    self.navigationItem.titleView = switcher;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:NULL];
    
    NSNumber *number = [[PCOKeyValueStore defaultStore] objectForKey:kLayoutEditorSidebarTabControllerLastTab];
    if ([number isEqualToNumber:@1]) {
        [self presentLyricsAnimated:NO];
    } else if ([number isEqualToNumber:@2]) {
        [self presentSongInfoAnimated:NO];
    } else {
        [self presentGeneralAnimated:NO];
    }
}

- (void)presentGeneralAnimated:(BOOL)animated {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"LayoutEditorSidebarGeneralStoryboard" bundle:[NSBundle mainBundle]];
    
    self.switcher.section = LayoutEditorSidebarNavigationSwitcherSectionGeneral;
    
    [[PCOKeyValueStore defaultStore] setObject:@0 forKey:kLayoutEditorSidebarTabControllerLastTab];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LayoutEditorSidebarTabControllerHideSongInfoNotification object:self];
    
    [self presentContentViewController:[story instantiateInitialViewController] animated:animated completion:^{
        self.switcher.section = LayoutEditorSidebarNavigationSwitcherSectionGeneral;
    }];
}
- (void)presentLyricsAnimated:(BOOL)animated {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"LayoutEditorSidebarLyricsStoryboard" bundle:[NSBundle mainBundle]];
    
    self.switcher.section = LayoutEditorSidebarNavigationSwitcherSectionLyrics;
    
    [[PCOKeyValueStore defaultStore] setObject:@1 forKey:kLayoutEditorSidebarTabControllerLastTab];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LayoutEditorSidebarTabControllerHideSongInfoNotification object:self];
    
    [self presentContentViewController:[story instantiateInitialViewController] animated:animated completion:^{
        self.switcher.section = LayoutEditorSidebarNavigationSwitcherSectionLyrics;
    }];
}
- (void)presentSongInfoAnimated:(BOOL)animated {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"LayoutEditorSidebarSongInfoStoryboard" bundle:[NSBundle mainBundle]];
    
    self.switcher.section = LayoutEditorSidebarNavigationSwitcherSectionSongInfo;
    
    [[PCOKeyValueStore defaultStore] setObject:@2 forKey:kLayoutEditorSidebarTabControllerLastTab];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LayoutEditorSidebarTabControllerShowSongInfoNotification object:self];
    
    [self presentContentViewController:[story instantiateInitialViewController] animated:animated completion:^{
        self.switcher.section = LayoutEditorSidebarNavigationSwitcherSectionSongInfo;
    }];
}

- (void)presentContentViewController:(UIViewController *)controller animated:(BOOL)flag completion:(void (^)(void))completion {
    UIViewController *oldContent = self.currentContentController;
    
    [oldContent willMoveToParentViewController:nil];
    
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    controller.view.alpha = 0.0;
    
    if (controller) {
        [self addChildViewController:controller];
        [self.view addSubview:controller.view];
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:controller.view offset:0.0 edges:UIRectEdgeAll]];
        
        [self.view layoutIfNeeded];
        
        self.currentContentController = controller;
        
        self.title = controller.title;
    }
    
    void(^animation)(void) = ^ {
        controller.view.alpha = 1.0;
        oldContent.view.alpha = 0.0;
    };
    void(^finalize)(BOOL) = ^(BOOL finished) {
        [controller didMoveToParentViewController:self];
        [oldContent.view removeFromSuperview];
        [oldContent removeFromParentViewController];
        [oldContent didMoveToParentViewController:nil];
        if (completion) {
            completion();
        }
    };
    
    if (flag) {
        [UIView animateWithDuration:0.2 animations:animation completion:finalize];
    } else {
        [UIView performWithoutAnimation:animation];
        finalize(YES);
    }
}

- (IBAction)controlValueChangedAction:(id)sender {
    if (self.switcher.section == LayoutEditorSidebarNavigationSwitcherSectionGeneral) {
        [self presentGeneralAnimated:YES];
    }
    if (self.switcher.section == LayoutEditorSidebarNavigationSwitcherSectionLyrics) {
        [self presentLyricsAnimated:YES];
    }
    if (self.switcher.section == LayoutEditorSidebarNavigationSwitcherSectionSongInfo) {
        [self presentSongInfoAnimated:YES];
    }
}

- (void)updateUserInterfaceForObjectChanges {
    
}


- (void)updateCurrentTextLayout {
    
}

@end


_PCO_EXTERN_STRING LayoutEditorSidebarTabControllerShowSongInfoNotification = @"LayoutEditorSidebarTabControllerShowSongInfoNotification";
_PCO_EXTERN_STRING LayoutEditorSidebarTabControllerHideSongInfoNotification = @"LayoutEditorSidebarTabControllerHideSongInfoNotification";

