/*!
 * LayoutEditorSidebarNavigationSwitcher.m
 *
 *
 * Created by Skylar Schipper on 6/25/14
 */

#import "LayoutEditorSidebarNavigationSwitcher.h"

@interface LayoutEditorSidebarNavigationSwitcher ()

@property (nonatomic, weak) PCOButton *generalButton;
@property (nonatomic, weak) PCOButton *lyricsButton;
@property (nonatomic, weak) PCOButton *songsButton;

@end

@implementation LayoutEditorSidebarNavigationSwitcher

- (void)initializeDefaults {
    [super initializeDefaults];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                            @"V:|-pad-[general]-pad-|",
                                                                            @"V:|-pad-[lyrics]-pad-|",
                                                                            @"V:|-pad-[songs]-pad-|",
                                                                            @"H:|[general]-pad-[lyrics(==general)]-pad-[songs(==general)]|"
                                                                            ]
                                                                  metrics:@{
                                                                            @"pad": @6
                                                                            }
                                                                    views:@{
                                                                            @"general": self.generalButton,
                                                                            @"lyrics": self.lyricsButton,
                                                                            @"songs":self.songsButton
                                                                            }]];
    
    self.section = LayoutEditorSidebarNavigationSwitcherSectionGeneral;
}

- (PCOButton *)newDefaultButton {
    PCOButton *button = [PCOButton newAutoLayoutView];
    button.titleLabel.font = [UIFont defaultFontOfSize_14];
    [button setBackgroundColor:[UIColor projectorBlackColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blackColor] forState:UIControlStateSelected | UIControlStateHighlighted];
    [button addTarget:self action:@selector(userButtonInteractionAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor projectorOrangeColor] forState:UIControlStateSelected];
    
    return button;
}
- (PCOButton *)generalButton {
    if (!_generalButton) {
        PCOButton *button = [self newDefaultButton];
        [button setTitle:NSLocalizedString(@"General", nil) forState:UIControlStateNormal];
        _generalButton = button;
        [self addSubview:button];
    }
    return _generalButton;
}
- (PCOButton *)lyricsButton {
    if (!_lyricsButton) {
        PCOButton *button = [self newDefaultButton];
        [button setTitle:NSLocalizedString(@"Lyrics", nil) forState:UIControlStateNormal];
        _lyricsButton = button;
        [self addSubview:button];
    }
    return _lyricsButton;
}
- (PCOButton *)songsButton {
    if (!_songsButton) {
        PCOButton *button = [self newDefaultButton];
        [button setTitle:NSLocalizedString(@"Song Info", nil) forState:UIControlStateNormal];
        _songsButton = button;
        [self addSubview:button];
    }
    return _songsButton;
}

#pragma mark -
#pragma mark - Actions
- (void)userButtonInteractionAction:(id)sender {
    if (sender == self.generalButton) {
        [self setSection:LayoutEditorSidebarNavigationSwitcherSectionGeneral userInteraction:YES];
    }
    if (sender == self.lyricsButton) {
        [self setSection:LayoutEditorSidebarNavigationSwitcherSectionLyrics userInteraction:YES];
    }
    if (sender == self.songsButton) {
        [self setSection:LayoutEditorSidebarNavigationSwitcherSectionSongInfo userInteraction:YES];
    }
}

#pragma mark -
#pragma mark - Setters
- (void)setSection:(LayoutEditorSidebarNavigationSwitcherSection)section {
    [self setSection:section userInteraction:NO];
}
- (void)setSection:(LayoutEditorSidebarNavigationSwitcherSection)section userInteraction:(BOOL)userInteraction {
    _section = section;
    self.generalButton.selected = NO;
    self.lyricsButton.selected = NO;
    self.songsButton.selected = NO;
    switch (section) {
        case LayoutEditorSidebarNavigationSwitcherSectionGeneral:
            self.generalButton.selected = YES;
            break;
        case LayoutEditorSidebarNavigationSwitcherSectionLyrics:
            self.lyricsButton.selected = YES;
            break;
        case LayoutEditorSidebarNavigationSwitcherSectionSongInfo:
            self.songsButton.selected = YES;
            break;
        default:
            break;
    }
    if (userInteraction) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
