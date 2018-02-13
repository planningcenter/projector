/*!
 * PROSettingsViewController.m
 *
 *
 * Created by Skylar Schipper on 3/14/14
 */

#import "PROSettingsViewController.h"
#import "PROSettingsSwitchCell.h"

static NSString *const PROSettingsSwitchCellIdentifier = @"PROSettingsSwitchCellIdentifier";
static NSString *const PROSettingsKeyboardInputCellIdentifier = @"PROSettingsKeyboardInputCellIdentifier";

typedef NS_ENUM(NSInteger, SettingsSections) {
    SettingsSectionOfflineMode  = 0,
    SettingsSectionAspect       = 1,
    SettingsSectionGridSize     = 2,
    SettingsSectionConfidence   = 3,
    SettingsSectionKeyboard     = 4,
    SettingsSectionPedals       = 5,
    SettingsSectionSessions     = 6,
    SettingsSectionFileStorage  = 7,
    SettingsSectionSecondScreen = 8,
    SettingsSections_Count      = 9
};

@interface KeyboardInputCell : PCOTableViewCell

@property (nonatomic, weak) PCOLabel *portLabel;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

@end


@interface PROSettingsViewController ()

@end

@implementation PROSettingsViewController

- (void)loadView {
    [super loadView];
    [PCOEventLogger logEvent:@"Settings - Entered"];

    self.title = NSLocalizedString(@"Settings", nil);
    
    self.tableView.backgroundColor = [UIColor projectorBlackColor];
    self.tableView.separatorColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupInputHandler];
}

- (void)setupInputHandler {
    [self.inputHandler becomeFirstResponder];
    [self.inputHandler.keyboardInputs removeAllObjects];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ProjectorSettings userSettings] notifyChangedSettings];
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[PROSettingsSwitchCell class] forCellReuseIdentifier:PROSettingsSwitchCellIdentifier];
    [tableView registerClass:[KeyboardInputCell class] forCellReuseIdentifier:PROSettingsKeyboardInputCellIdentifier];
    [tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"test"];
}

#pragma mark -
#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SettingsSections_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SettingsSectionSessions) {
        return 3;
    }
    if (section == SettingsSectionAspect) {
        return 2;
    }
    if (section == SettingsSectionKeyboard) {
        return 2;
    }
    if (section == SettingsSectionPedals) {
        return 6;
    }
    if (section == SettingsSectionSecondScreen) {
        return 1;
    }
    if (section == SettingsSectionFileStorage) {
        return 4;
    }
    if (section == SettingsSectionGridSize) {
        return 3;
    }
    if (section == SettingsSectionConfidence) {
        return 2;
    }
    if (section == SettingsSectionOfflineMode) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PCOTableViewCell *cell = nil;
    
    if (indexPath.section == SettingsSectionAspect) {
        cell = [tableView dequeueReusableCellWithIdentifier:PCOTableViewControllerDefaultCellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"16:9", nil);
            if ([[ProjectorSettings userSettings] aspectRatio] == ProjectorAspectRatio_16_9) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.text = NSLocalizedString(@"4:3", nil);
            if ([[ProjectorSettings userSettings] aspectRatio] == ProjectorAspectRatio_4_3) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    if (indexPath.section == SettingsSectionKeyboard) {
        cell = [tableView dequeueReusableCellWithIdentifier:PCOTableViewControllerDefaultCellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Number", nil);
            if ([[ProjectorSettings userSettings] alertKeyboardType] == UIKeyboardTypeNumbersAndPunctuation) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Text", nil);
            if ([[ProjectorSettings userSettings] alertKeyboardType] == UIKeyboardTypeAlphabet) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    if (indexPath.section == SettingsSectionSecondScreen) {
        cell = [tableView dequeueReusableCellWithIdentifier:PROSettingsSwitchCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"Enabled", nil);
        PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
        sCell.on = [[PROSecondScreenController sharedController] isSecondScreenEnabled];
        sCell.valueChanged = ^(BOOL value) {
            [[PROSecondScreenController sharedController] setSecondScreenEnabled:value];
        };
    }
    if (indexPath.section == SettingsSectionSessions) {
        cell = [tableView dequeueReusableCellWithIdentifier:PROSettingsSwitchCellIdentifier forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Game Kit", nil);
            PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
            sCell.on = [[ProjectorSettings userSettings] useGamekitProtocol];
            sCell.valueChanged = ^(BOOL value) {
                [[ProjectorSettings userSettings] setUseGamekitProtocol:value];
            };
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Pusher", nil);
            PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
            sCell.on = [[ProjectorSettings userSettings] usePusherProtocol];
            sCell.valueChanged = ^(BOOL value) {
                [[ProjectorSettings userSettings] setUsePusherProtocol:value];
            };
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Multipeer", nil);
            PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
            sCell.on = [[ProjectorSettings userSettings] useMultipeerProtocol];
            sCell.valueChanged = ^(BOOL value) {
                [[ProjectorSettings userSettings] setUseMultipeerProtocol:value];
            };
        }
    }
    if (indexPath.section == SettingsSectionPedals) {
        if (indexPath.row < 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:PROSettingsSwitchCellIdentifier forIndexPath:indexPath];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:PROSettingsKeyboardInputCellIdentifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"\"B\" key triggers black screen", nil);
            PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
            sCell.on = [[ProjectorSettings userSettings] bKeyTriggersBlack];
            sCell.valueChanged = ^(BOOL value) {
                [[ProjectorSettings userSettings] setBKeyTriggersBlack:value];
            };
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"\"L\" key triggers logo", nil);
            PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
            sCell.on = [[ProjectorSettings userSettings] lKeyTriggersLogo];
            sCell.valueChanged = ^(BOOL value) {
                [[ProjectorSettings userSettings] setLKeyTriggersLogo:value];
            };
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"\"C\" key clears lyrics", nil);
            PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
            sCell.on = [[ProjectorSettings userSettings] cKeyClearsLyrics];
            sCell.valueChanged = ^(BOOL value) {
                [[ProjectorSettings userSettings] setCKeyClearsLyrics:value];
            };
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Space bar advances slide", nil);
            PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
            sCell.on = [[ProjectorSettings userSettings] spaceTriggersNext];
            sCell.valueChanged = ^(BOOL value) {
                [[ProjectorSettings userSettings] setSpaceTriggersNext:value];
            };
        }
        if (indexPath.row == 4) {
            KeyboardInputCell *kbCell = (KeyboardInputCell *)cell;
            kbCell.target = nil;
            kbCell.selector = NULL;
            
            kbCell.textLabel.text = NSLocalizedString(@"Pedal next key: ", nil);
            kbCell.portLabel.text = [[ProjectorSettings userSettings] forwardKeyString];
            kbCell.portLabel.font = [UIFont defaultFontOfSize_16];

            kbCell.target = [ProjectorSettings userSettings];
            kbCell.selector = @selector(setForwardKeyString:);
        }
        if (indexPath.row == 5) {
            KeyboardInputCell *kbCell = (KeyboardInputCell *)cell;
            kbCell.target = nil;
            kbCell.selector = NULL;
            
            kbCell.textLabel.text = NSLocalizedString(@"Pedal previous key: ", nil);
            kbCell.portLabel.text = [[ProjectorSettings userSettings] backKeyString];
            kbCell.portLabel.font = [UIFont defaultFontOfSize_16];
            
            kbCell.target = [ProjectorSettings userSettings];
            kbCell.selector = @selector(setBackKeyString:);
        }
    }
    if (indexPath.section == SettingsSectionFileStorage) {
        cell = [tableView dequeueReusableCellWithIdentifier:PCOTableViewControllerDefaultCellIdentifier forIndexPath:indexPath];
        
        if (indexPath.row == ProjectorFileStorageDurationOneWeek) {
            cell.textLabel.text = NSLocalizedString(@"One Week", nil);
        } else if (indexPath.row == ProjectorFileStorageDurationTwoWeeks) {
            cell.textLabel.text = NSLocalizedString(@"Two Weeks", nil);
        } else if (indexPath.row == ProjectorFileStorageDurationThreeWeeks) {
            cell.textLabel.text = NSLocalizedString(@"Three Weeks", nil);
        } else if (indexPath.row == ProjectorFileStorageDurationFourWeeks) {
            cell.textLabel.text = NSLocalizedString(@"Four Weeks", nil);
        }
        
        if (indexPath.row == [[ProjectorSettings userSettings] fileStorageDuration]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    if (indexPath.section == SettingsSectionGridSize) {
        cell = [tableView dequeueReusableCellWithIdentifier:PCOTableViewControllerDefaultCellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Small", nil);
            if ([[ProjectorSettings userSettings] gridSize] == ProjectorGridSizeSmall) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Normal", nil);
            if ([[ProjectorSettings userSettings] gridSize] == ProjectorGridSizeNormal) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.text = NSLocalizedString(@"Large", nil);
            if ([[ProjectorSettings userSettings] gridSize] == ProjectorGridSizeLarge) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    
    if (indexPath.section == SettingsSectionConfidence) {
        cell = [tableView dequeueReusableCellWithIdentifier:PCOTableViewControllerDefaultCellIdentifier forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Normal", nil);
            if ([[ProjectorSettings userSettings] confidenceTextWeight] == ProjectorConfidenceTextWeightNormal) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Bold", nil);
            if ([[ProjectorSettings userSettings] confidenceTextWeight] == ProjectorConfidenceTextWeightBold) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }

    if (indexPath.section == SettingsSectionOfflineMode) {
        cell = [tableView dequeueReusableCellWithIdentifier:PROSettingsSwitchCellIdentifier forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Force Offline Mode", nil);
            PROSettingsSwitchCell *sCell = (PROSettingsSwitchCell *)cell;
            sCell.on = [PCOServer forceOfflineMode];
            sCell.valueChanged = ^(BOOL value) {
                [PCOServer setForceOfflineMode:value];
            };
        }
    }
    
    cell.textLabel.font = [UIFont defaultFontOfSize_16];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = HEX(0x25262B);
    
    return (cell) ?: [[PCOTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

#pragma mark -
#pragma mark - Actions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SettingsSectionPedals) {
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (indexPath.section == SettingsSectionAspect) {
        if (indexPath.row == 0) {
            if ([[ProjectorSettings userSettings] aspectRatio] != ProjectorAspectRatio_16_9) {
                [[ProjectorSettings userSettings] setAspectRatio:ProjectorAspectRatio_16_9];
            }
        } else {
            if ([[ProjectorSettings userSettings] aspectRatio] != ProjectorAspectRatio_4_3) {
                [[ProjectorSettings userSettings] setAspectRatio:ProjectorAspectRatio_4_3];
            }
        }
    }
    
    if (indexPath.section == SettingsSectionKeyboard) {
        if (indexPath.row == 0) {
            [[ProjectorSettings userSettings] setAlertKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        } else if (indexPath.row == 1) {
            [[ProjectorSettings userSettings] setAlertKeyboardType:UIKeyboardTypeAlphabet];
        }
    }
    
    if (indexPath.section == SettingsSectionFileStorage) {
        [[ProjectorSettings userSettings] setFileStorageDuration:(ProjectorFileStorageDuration)indexPath.row];
    }
    
    if (indexPath.section == SettingsSectionGridSize) {
        if (indexPath.row == 0) {
            if ([[ProjectorSettings userSettings] gridSize] != ProjectorGridSizeSmall) {
                [[ProjectorSettings userSettings] setGridSize:ProjectorGridSizeSmall];
            }
        } else if (indexPath.row == 1) {
            if ([[ProjectorSettings userSettings] gridSize] != ProjectorGridSizeNormal) {
                [[ProjectorSettings userSettings] setGridSize:ProjectorGridSizeNormal];
            }
        } else {
            if ([[ProjectorSettings userSettings] gridSize] != ProjectorGridSizeLarge) {
                [[ProjectorSettings userSettings] setGridSize:ProjectorGridSizeLarge];
            }
        }
    }
    
    if (indexPath.section == SettingsSectionConfidence) {
        if (indexPath.row == 0) {
            if ([[ProjectorSettings userSettings] confidenceTextWeight] != ProjectorConfidenceTextWeightNormal) {
                [[ProjectorSettings userSettings] setConfidenceTextWeight:ProjectorConfidenceTextWeightNormal];
            }
        } else {
            if ([[ProjectorSettings userSettings] confidenceTextWeight] != ProjectorConfidenceTextWeightBold) {
                [[ProjectorSettings userSettings] setConfidenceTextWeight:ProjectorConfidenceTextWeightBold];
            }
        }
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -
#pragma mark - Headers
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SettingsSectionAspect) {
        return NSLocalizedString(@"Aspect Ratio", nil);
    }
    if (section == SettingsSectionKeyboard) {
        return NSLocalizedString(@"Alert Keyboard Type", nil);
    }
    if (section == SettingsSectionSecondScreen) {
        return NSLocalizedString(@"Presentation Display", nil);
    }
    if (section == SettingsSectionPedals) {
        return NSLocalizedString(@"Pedal/Keyboard Control", nil);
    }
    if (section == SettingsSectionSessions) {
        return NSLocalizedString(@"Session Protocols", nil);
    }
    if (section == SettingsSectionFileStorage) {
        return NSLocalizedString(@"Delete unused files after", nil);
    }
    if (section == SettingsSectionGridSize) {
        return NSLocalizedString(@"Grid Size", nil);
    }
    if (section == SettingsSectionConfidence) {
        return NSLocalizedString(@"Confidence Mode Text", nil);
    }
    if (section == SettingsSectionOfflineMode) {
        return NSLocalizedString(@"Offline Mode", nil);
    }
    return nil;
}

#pragma mark -
#pragma mark - Footers

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == SettingsSectionSecondScreen) {
        return 80;
    }
    if (section == SettingsSectionFileStorage) {
        return 46;
    }
    if (section == SettingsSectionSessions) {
        return 46;
    }
    if (section == SettingsSectionOfflineMode) {
        return 46;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"test"];
    
    view.textLabel.font = [UIFont systemFontOfSize:14];
    view.textLabel.numberOfLines = 0;
    view.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == SettingsSectionSecondScreen) {
        return NSLocalizedString(@"Leave presentation display enabled for normal use. Disable it to show the Projector interface on your external display for training purposes.", nil);
    }
    if (section == SettingsSectionFileStorage) {
        return NSLocalizedString(@"You can manually delete files at any time by sliding them from right to left in the sidebar.", nil);
    }
    if (section == SettingsSectionSessions) {
        return NSLocalizedString(@"Used for advanced troubleshooting. It's usually best to leave them all on.", nil);
    }
    if (section == SettingsSectionOfflineMode) {
        return NSLocalizedString(@"Force Projector to behave as if it were in offline mode.", nil);
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"test"];
    
    view.textLabel.font = [UIFont systemFontOfSize:14];
    view.textLabel.numberOfLines = 0;
    view.textLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    
    return view;
}

#pragma mark -
#pragma mark - Text Input
- (PROKeyboardInputHandler *)inputHandler {
    if (!_inputHandler) {
        PROKeyboardInputHandler *handler = [[PROKeyboardInputHandler alloc] initWithDelegate:self];
        _inputHandler = handler;
        [self.view addSubview:handler];
    }
    return _inputHandler;
}

- (void)keyboardInputHandler:(PROKeyboardInputHandler *)inputHandler didRecieveKeyboardCommand:(UIKeyCommand *)keyboardCommand {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if (indexPath.section == SettingsSectionPedals) {
        if (indexPath.row == 4) {
            [[ProjectorSettings userSettings] setForwardKeyString:keyboardCommand.input];
        } else if (indexPath.row == 5) {
            [[ProjectorSettings userSettings] setBackKeyString:keyboardCommand.input];
        }
        [self reloadTableView];
    }
}

@end

#pragma mark -
#pragma mark - Keyboard Input Cell

@implementation KeyboardInputCell

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)initializeDefaults {
    [super initializeDefaults];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.portLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *metrics = @{
                              @"left": @(self.separatorInset.left)
                              };
    NSDictionary *views = @{
                            @"title": self.textLabel,
                            @"port": self.portLabel
                            };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                            @"H:|-left-[title]-[port]-left-|",
                                                                            @"V:|[title]|",
                                                                            @"V:|[port]|"
                                                                            ]
                                                                  metrics:metrics
                                                                    views:views]];
    
    [self.textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (PCOLabel *)portLabel {
    if (!_portLabel) {
        PCOLabel *pl = [PCOLabel newAutoLayoutView];
        pl.backgroundColor = [UIColor clearColor];
        pl.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        pl.textColor = [UIColor projectorOrangeColor];
        pl.textAlignment = NSTextAlignmentRight;
        _portLabel = pl;
        [self.contentView addSubview:pl];
    }
    return _portLabel;
}

@end


