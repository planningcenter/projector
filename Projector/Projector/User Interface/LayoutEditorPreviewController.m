/*!
 * LayoutEditorPreviewController.m
 *
 *
 * Created by Skylar Schipper on 5/15/14
 */

#import "LayoutEditorPreviewController.h"

#import "PCOSlideLayout.h"

#import "PROSlideLayout.h"
#import "PROSlideTextLabel.h"
#import "PROLayoutPreviewEdgeInsetsView.h"

#import "LayoutEditorInterfaceContainerController.h"
#import "LayoutEditorSidebarTabController.h"

#import "LayoutEditorMobileContainerController.h"

@interface LayoutEditorPreviewController () <PROLayoutPreviewEdgeInsetsViewDelegate>

@property (nonatomic, weak) PCOView *containerView;
@property (nonatomic, weak) PCOView *decorationView;
@property (nonatomic, weak) PCOView *previewView;
@property (nonatomic, weak) PROSlideTextLabel *textLabel;
@property (nonatomic, weak) PROSlideTextLabel *infoLabel;

@property (nonatomic, weak) PCOSlideLayout *layout;

@property (nonatomic, weak) PCOSlideTextLayout *textLayout;
@property (nonatomic, weak) PCOSlideTextLayout *infoLayout;

@property (nonatomic, weak) PROLayoutPreviewEdgeInsetsView *edgeInsetsView;

@end

@implementation LayoutEditorPreviewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor layoutControllerPreviewBackgroundColor];
    
    PCOKitLazyLoad(self.textLabel);
    self.decorationView.backgroundColor = pco_kit_GRAY(8.0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSongInfo) name:LayoutEditorSidebarTabControllerShowSongInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSongInfo) name:LayoutEditorSidebarTabControllerHideSongInfoNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateUserInterfaceForObjectChanges];
}

- (void)updateUserInterfaceForObjectChanges {
    [UIView performWithoutAnimation:^{
        [self.view layoutIfNeeded];
        
        self.previewView.backgroundColor = self.layout.backgroundColor;
        
        PROSlideLayout *layout = [[PROSlideLayout alloc] initWithLayout:self.layout.lyricTextLayout];
        self.textLabel.text = [PROSlideTextLabel sampleLyricTextWithMaxLines:[self.layout.lyricTextLayout.defaultLinesPerSlide integerValue]];
        [layout configureTextLabel:self.textLabel];
        
        if ([self isSongInfoShowing]) {
            PROSlideLayout *infoLayout = [[PROSlideLayout alloc] initWithLayout:self.layout.songInfoLayout];
            
            [infoLayout configureTextLabel:self.infoLabel];
            
            self.edgeInsetsView.insets = self.infoLabel.textInsets;
        } else {
            self.edgeInsetsView.insets = self.textLabel.textInsets;
        }
        self.edgeInsetsView.color = [self.previewView.backgroundColor contrastColor];
        
        [self.view layoutIfNeeded];
    }];
}

- (PCOView *)decorationView {
    if (!_decorationView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.layer.borderColor = [pco_kit_RGB(50,53,64) CGColor];
        view.layer.borderWidth = 1.0;
        view.layer.cornerRadius = 3.0;
        
        _decorationView = view;
        [self.view insertSubview:view belowSubview:self.containerView];
        
        CGFloat offset = 8.0;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.previewView attribute:NSLayoutAttributeTop multiplier:1.0 constant:-offset]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.previewView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-offset]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.previewView attribute:NSLayoutAttributeRight multiplier:1.0 constant:offset]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.previewView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:offset]];
    }
    return _decorationView;
}
- (PCOView *)containerView {
    if (!_containerView) {

        CGFloat offset = 24.0;
        
        if (![[PROAppDelegate delegate] isPad]) {
            offset = 4.0;
        }
        
        PCOView *view = [PCOView newAutoLayoutView];
        
        _containerView = view;
        [self.view addSubview:view];
        
        [self.view addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:offset edges:UIRectEdgeAll]];
    }
    return _containerView;
}
- (PCOView *)previewView {
    if (!_previewView) {
        PCOView *view = [PCOView newAutoLayoutView];
        view.backgroundColor = [UIColor blackColor];
        
        _previewView = view;
        [self.containerView addSubview:view];
        
        ProjectorAspectRatio aspect = [[ProjectorSettings userSettings] aspectRatio];
        
        [self.containerView addConstraint:[NSLayoutConstraint centerViewHorizontalyInSuperview:view]];
        
        NSLayoutConstraint *centerVert = [NSLayoutConstraint centerViewVerticalyInSuperview:view];
        centerVert.priority = UILayoutPriorityDefaultHigh;
        [self.containerView addConstraint:centerVert];
        
        for (NSLayoutConstraint *constraint in [NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeTop | UIRectEdgeBottom]) {
            constraint.priority = UILayoutPriorityDefaultHigh;
            [self.containerView addConstraint:constraint];
        }
        
        NSLayoutConstraint *leftEdge = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *rightEdge = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];

        if (aspect == ProjectorAspectRatio_16_9) {
            leftEdge.priority = 999;
            rightEdge.priority = 999;
        }
        else if (![[PROAppDelegate delegate] isPad]) {
            leftEdge.priority = UILayoutPriorityDefaultLow;
            rightEdge.priority = UILayoutPriorityDefaultLow;
        }

        [self.containerView addConstraint:leftEdge];
        [self.containerView addConstraint:rightEdge];
        
        
        [self.containerView addConstraint:ProjectorCreateAspectConstraint(aspect, view)];
    }
    return _previewView;
}
- (PROSlideTextLabel *)textLabel {
    if (!_textLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = NO;
        label.text = [PROSlideTextLabel sampleLyricText];
        
        _textLabel = label;
        [self.previewView addSubview:label];
        [self.previewView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:0.0 edges:UIRectEdgeAll]];
    }
    return _textLabel;
}
- (PROSlideTextLabel *)infoLabel {
    if (!_infoLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = NO;
        label.text = [NSString stringWithFormat:NSLocalizedString(@"It Is Well With My Soul\nPhilip Paul Bliss and Horatio G. Spafford\nPublic Domain\nCCL # %@", nil),[[PCOOrganization current] ccliNumber]];
        
        _infoLabel = label;
        [self.previewView addSubview:label];
        [self.previewView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:0.0 edges:UIRectEdgeAll]];
    }
    return _infoLabel;
}
- (PROLayoutPreviewEdgeInsetsView *)edgeInsetsView {
    if (!_edgeInsetsView) {
        PROLayoutPreviewEdgeInsetsView *view = [PROLayoutPreviewEdgeInsetsView newAutoLayoutView];
        view.backgroundColor = [UIColor clearColor];
        view.delegate = self;
        
        _edgeInsetsView = view;
        [self.previewView insertSubview:view belowSubview:self.textLabel];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        
        [self.previewView addConstraints:@[top,left,bottom,right]];
    }
    return _edgeInsetsView;
}

- (void)updateCurrentTextLayout {
    
}

- (void)showSongInfo {
    self.infoLabel.alpha = 1.0;
    [self updateUserInterfaceForObjectChanges];
}
- (void)hideSongInfo {
    [_infoLabel removeFromSuperview];
    _infoLabel = nil;
    [self updateUserInterfaceForObjectChanges];
}
- (BOOL)isSongInfoShowing {
    return (_infoLabel.alpha > 0.0);
}

#pragma mark -
#pragma mark - PROLayoutPreviewEdgeInsetsViewDelegate
- (void)insetView:(PROLayoutPreviewEdgeInsetsView *)view didChangeInsets:(UIEdgeInsets)insets {
    CGFloat width = CGRectGetHeight(self.previewView.bounds);
    CGFloat height = CGRectGetHeight(self.previewView.bounds);
    CGFloat top = (insets.top / height) * 100;
    CGFloat bottom = (insets.bottom / height) * 100;
    CGFloat left = (insets.left / width) * 100;
    CGFloat right = (insets.right / width) * 100;
    
    PCOSlideTextLayout *textLayout = self.layout.lyricTextLayout;
    if ([self isSongInfoShowing]) {
        textLayout = self.layout.songInfoLayout;
    }
    
    textLayout.marginTop = @(top);
    textLayout.marginBottom = @(bottom);
    textLayout.marginLeft = @(left);
    textLayout.marginRight = @(right);
    
    if ([self.parentViewController respondsToSelector:@selector(updateUserInterfaceUpdateForObjectChange:animated:)]) {
        [((LayoutEditorInterfaceContainerController *)self.parentViewController) updateUserInterfaceUpdateForObjectChange:nil animated:YES];
    }
}

@end
