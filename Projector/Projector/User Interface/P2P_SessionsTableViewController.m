//
//  P2P_SessionsTableViewController.m
//  Projector
//
//  Created by Peter Fokos on 6/18/14.
//

#import "P2P_SessionsTableViewController.h"

#import "ProjectorP2P_SessionManager.h"

#import "CreateSessionTableViewHeaderView.h"
#import "CreateSessionTableViewCellZero.h"
#import "ConnectedClientTableViewCell.h"

#import "ConnectToSessionTableViewHeaderView.h"
#import "AvailableSessionTableViewCell.h"
#import "P2P_Device.h"
#import "UIColor+PROColors.h"
#import "PCOLiveController.h"
#import <Crashlytics/Crashlytics.h>
#import "PROSlideManager.h"

#define CRASH_INFO_BUTTON 1

typedef NS_ENUM(NSInteger, SessionCellType) {
    SessionCellTypeLiveCell     = 0,
    SessionCellTypeZeroCell     = 1,
};

@interface P2P_SessionsTableViewController ()

@property (nonatomic) BOOL showSessionInfo;
@property (nonatomic, strong) NSArray *availableServers;
@property (nonatomic, strong) NSArray *connectedDevices;

@end

@implementation P2P_SessionsTableViewController

#pragma mark -
#pragma mark - View Controller Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.separatorColor = [UIColor blackColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PServerCreatedNotification:) name:P2PServerCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PClientCreatedNotification:) name:P2PClientCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PLostPeerNotification:) name:P2PLostPeerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PFoundPeerNotification:) name:P2PFoundPeerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionConnectedNotification:) name:P2PSessionConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionDisconnectedNotification:) name:P2PSessionDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionClientCouldNotConnectNotification:) name:P2PSessionClientCouldNotConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionStateChangedNotification:) name:P2PSessionStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(P2PSessionStateChangedNotification:) name:PCOLiveStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(planWasUpdated:) name:PCOPlanUpdatedNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setPlanAndUpdateStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerCellsForTableView:(PCOTableView *)tableView {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [tableView registerClass:[CreateSessionTableViewCellZero class] forCellReuseIdentifier:@"CreateSessionTableViewCellZero"];
    [tableView registerClass:[ConnectedClientTableViewCell class] forCellReuseIdentifier:@"ConnectedClientTableViewCell"];
    [tableView registerClass:[AvailableSessionTableViewCell class] forCellReuseIdentifier:@"AvailableSessionTableViewCell"];
}

- (void)planWasUpdated:(NSNotification *)notif {
    [self setPlanAndUpdateStatus];
}

#pragma mark -
#pragma mark - P2P Notification Handler Methods

- (void)P2PSessionStateChangedNotification:(NSNotification *)notif {
    [self.tableView reloadData];
}

- (void)P2PServerCreatedNotification:(NSNotification *)notif {
    [self.tableView reloadData];
}

- (void)P2PClientCreatedNotification:(NSNotification *)notif {
    [self.tableView reloadData];
}

- (void)P2PLostPeerNotification:(NSNotification *)notif {
    [self animatedRefresh];
}

- (void)P2PFoundPeerNotification:(NSNotification *)notif {
    [self animatedRefresh];
}

- (void)P2PSessionConnectedNotification:(NSNotification *)notif {
    [self animatedRefresh];
}

- (void)P2PSessionDisconnectedNotification:(NSNotification *)notif {
    [self animatedRefresh];
}

- (void)P2PSessionClientCouldNotConnectNotification:(NSNotification *)notif {
    NSString *title = NSLocalizedString(@"Could Not Connect", nil);
    MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:title message:NSLocalizedString(@"Could not connect to the Session, please try again.", nil) cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
    [alert show];
}

#pragma mark -
#pragma mark - Tableview Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    _availableServers = nil;
    _connectedDevices = nil;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSInteger clients = 2;

        if ([[ProjectorP2P_SessionManager sharedManager] isServer]) {
            clients += [self.connectedDevices count];
            if (clients == 2) {
                clients = 3;
            }
        }
        return clients;
    }
    NSInteger servers = [self.availableServers count];
    if (servers == 0) {
        servers = 1;
    }
    return servers;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case SessionCellTypeLiveCell:
                if ([[ProjectorP2P_SessionManager sharedManager] isServer]) {
                    return [AvailableSessionTableViewCell heightForCellConnected:NO];
                }
                return 0;
                break;
            case SessionCellTypeZeroCell:
                return [CreateSessionTableViewCellZero heightForCellWithSessionStarted:[[ProjectorP2P_SessionManager sharedManager] isServer]];
                break;
            default:
                return [AvailableSessionTableViewCell heightForCellConnected:NO];
                break;
        }
    }
    if ([self validIndex:indexPath.row intoArray:self.availableServers]) {
        P2P_Device *device = [self.availableServers objectAtIndex:indexPath.row];
        if (device.peerId == [ProjectorP2P_SessionManager sharedManager].connectedServerDevice.peerId &&
            [ProjectorP2P_SessionManager sharedManager].connectedServerDevice.status == P2P_Device_Status_Connected) {
            return [AvailableSessionTableViewCell heightForCellConnected:YES];
        }
    }
    return [AvailableSessionTableViewCell heightForCellConnected:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        height = [CreateSessionTableViewHeaderView heightForViewWithInfoShowing:self.showSessionInfo];
    }
    else {
        height = [ConnectToSessionTableViewHeaderView heightForView];
    }
    return height;
}

- (NSString *)statusString:(NSString *)statusString addInitials:(BOOL)addInitials {
    NSString *finalString = statusString;
#if DEBUG
    if (addInitials) {
        finalString = [NSString stringWithFormat:@"%@ - %@", finalString, [[ProjectorP2P_SessionManager sharedManager] protocolInitials]];
    }
#endif
    return finalString;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL addInitials = YES;
    if (section == 0) {
        CreateSessionTableViewHeaderView *view = [[CreateSessionTableViewHeaderView alloc] init];
        [view.infoButton addTarget:self action:@selector(toggleSessionInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        view.imageView.transform = CGAffineTransformIdentity;
        view.statusLabel.textColor = [UIColor sessionsTintColor];
        
        if (self.showSessionInfo) {
            view.infoButton.tintColor = HEX(0x9d9dad);
        } else {
            view.infoButton.tintColor = [UIColor sidebarCellTintColor];
        }
        
        if ([[ProjectorP2P_SessionManager sharedManager] isServer]) {
            view.statusLabel.text = [self statusString:NSLocalizedString(@"End Session", nil) addInitials:addInitials];
            [view.startButton addTarget:self action:@selector(toggleServerSessionAction:) forControlEvents:UIControlEventTouchUpInside];
            view.imageView.transform = CGAffineTransformMakeRotation(M_PI_4);
        } else if ([[ProjectorP2P_SessionManager sharedManager] isConnectedClient]) {
            if ([ProjectorP2P_SessionManager sharedManager].connectedServerDevice.status == P2P_Device_Status_Connecting) {
                view.statusLabel.text = [self statusString:NSLocalizedString(@"Connecting to Session...", nil) addInitials:addInitials];
            }
            else {
                view.statusLabel.text = [self statusString:NSLocalizedString(@"Leave Session", nil) addInitials:addInitials];
            }
            view.statusColor = [self colorForClientMode];
            [view.startButton addTarget:self action:@selector(disconnectFromServerAction:) forControlEvents:UIControlEventTouchUpInside];
            view.imageView.transform = CGAffineTransformMakeRotation(M_PI_4);
        } else {
            view.statusLabel.text = [self statusString:NSLocalizedString(@"Start Session", nil) addInitials:addInitials];
            [view.startButton addTarget:self action:@selector(toggleServerSessionAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        return view;
    }
    ConnectToSessionTableViewHeaderView *view = [[ConnectToSessionTableViewHeaderView alloc] init];
    view.nameLabel.alpha = 1.0;
    if ([[ProjectorP2P_SessionManager sharedManager] isServer]) {
        view.nameLabel.alpha = 0.3;
    }
    return view;
}

- (UITableViewCell *)serverCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == SessionCellTypeZeroCell) {
        CreateSessionTableViewCellZero *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateSessionTableViewCellZero"];
        return cell;
    }
    ConnectedClientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectedClientTableViewCell"];
    [cell.switchControl removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    if (indexPath.row == SessionCellTypeLiveCell) {
        
        cell.switchControl.hidden = YES;
        cell.contentView.alpha = 0.3;

        if ([[PCOLiveController sharedController] canControl]) {
            PCOLiveStatus *status = [PCOLiveController sharedController].liveStatus;
            if ([status isControlled]) {
                NSNumber *currentUserId = [PCOUserData current].userId;
                if ([status isControlledByUserId:currentUserId]) {
                    cell.switchControl.hidden = NO;
                    cell.switchControl.on = YES;
                    cell.contentView.alpha = 1.0;
                    [cell.switchControl addTarget:self action:@selector(pcoLiveSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                }
                else {
                    cell.switchControl.hidden = YES;
                    cell.contentView.alpha = 0.3;
                }
            }
            else {
                cell.switchControl.on = NO;
                cell.switchControl.hidden = NO;
                [cell.switchControl addTarget:self action:@selector(pcoLiveSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                cell.contentView.alpha = 1.0;
            }
        }
        [cell setNeedsUpdateConstraints];
        
        cell.nameLabel.text = NSLocalizedString(@"Control Services Live", nil);
    }
    else {
        if ([self.connectedDevices count] == 0) {
            cell.nameLabel.text = NSLocalizedString(@"No Connections", nil);
            cell.switchControl.hidden = YES;
        }
        else {
            P2P_Device *device = nil;
            NSInteger row = indexPath.row - 2;
            if ([self validIndex:row intoArray:self.connectedDevices]) {
                device = [self.connectedDevices objectAtIndex:row];
            }
            cell.nameLabel.text = device.name;
            cell.switchControl.hidden = NO;
            cell.contentView.alpha = 1.0;
            cell.switchControl.tag = indexPath.row;
            [cell.switchControl addTarget:self action:@selector(clientContolSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
            cell.switchControl.on = NO;
            if ([[[ProjectorP2P_SessionManager sharedManager] controlledByClientPeerId] isEqualToString:device.name]) {
                cell.switchControl.on = YES;
            }
        }
    }
    return cell;
}

- (UITableViewCell *)clientCellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    AvailableSessionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AvailableSessionTableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor sessionsCellNormalBackgroundColor];
    cell.textLabel.font = [UIFont defaultFontOfSize_14];
    cell.detailTextLabel.font = [UIFont defaultFontOfSize_12];
    cell.nameLabel.textColor = [UIColor sessionsAvailableSessionsTextColor];
    cell.cloudButton.hidden = YES;
    cell.connected = NO;
    
    if ([[ProjectorP2P_SessionManager sharedManager] isServer]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    cell.clientMode = [ProjectorP2P_SessionManager sharedManager].clientMode;
    
    NSArray *avaiableServers = self.availableServers;
    if ([self validIndex:indexPath.row intoArray:avaiableServers]) {
        P2P_Device *device = [avaiableServers objectAtIndex:indexPath.row];
        cell.nameLabel.text = device.name;
        if (device.peerId && [device.peerId isEqualToString:[ProjectorP2P_SessionManager sharedManager].connectedServerDevice.peerId]) {
            cell.cloudButton.hidden = NO;
            if ([ProjectorP2P_SessionManager sharedManager].connectedServerDevice.status == P2P_Device_Status_Connecting) {
                cell.cloudButton.tintColor = [UIColor sessionsAvailableSessionsTextColor];
                cell.nameLabel.textColor = [UIColor sessionsAvailableSessionsTextColor];
            }
            else {
                cell.connected = YES;
                UIColor *tintColor = [self colorForClientMode];
                cell.cloudButton.tintColor = tintColor;
                cell.nameLabel.textColor = tintColor;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else {
        cell.nameLabel.text = NSLocalizedString(@"No Sessions", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.cloudButton addTarget:self action:@selector(disconnectFromServerAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mirrorButton addTarget:self action:@selector(setMirrorModeAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.confidenceButton addTarget:self action:@selector(setConfidenceModeAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.noLyricsButton addTarget:self action:@selector(setNoLyricsModeAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.contentView.alpha = 1.0;
    if ([[ProjectorP2P_SessionManager sharedManager] isServer]) {
        cell.contentView.alpha = 0.3;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        return [self serverCellForTableView:tableView indexPath:indexPath];
    }
    return [self clientCellForTableView:tableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![[ProjectorP2P_SessionManager sharedManager] isServer]) {
        if ([self validIndex:indexPath.row intoArray:self.availableServers]) {
            P2P_Device *server = [self.availableServers objectAtIndex:indexPath.row];
            if (server.status == P2P_Device_Status_NotConnected) {
                if (![[ProjectorP2P_SessionManager sharedManager] connectedServerDevice]) {
                    [[ProjectorP2P_SessionManager sharedManager] connectToServer:server];
                    [tableView reloadData];
                }
                else {
                    NSString *title = NSLocalizedString(@"Session In Progress", nil);
                    MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:title message:NSLocalizedString(@"Please leave the current session before starting another.", nil) cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
                    [alert show];
                }
            }
        }
    }
//    #TODO: Need to put up a dialog asking if they want to close their server and connect to a client
}

#pragma mark -
#pragma mark - Action Methods

- (void)toggleServerSessionAction:(id)sender {
    if (![[PROSlideManager sharedManager] plan]) {
        NSString *title = NSLocalizedString(@"Can't Start Session", nil);
        MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:title message:NSLocalizedString(@"Please load a plan before starting a session.", nil) cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alert show];
        return;
    }

    [self.tableView beginUpdates];
    if ([[ProjectorP2P_SessionManager sharedManager] isServer]) {
        [[ProjectorP2P_SessionManager sharedManager] closeServerSession];
        [[PCOLiveController sharedController] releaseControlOfLiveSessionByUserId:[PCOUserData current].userId];
    }
    else {
        [[ProjectorP2P_SessionManager sharedManager] createNewServerSession];
        [self setPlanAndUpdateStatus];
    }
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSRangeFromString(@"0,2")];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCOLiveStateChangedNotification object:nil];
}

- (void)toggleSessionInfoAction:(id)sender {
    //=================
#if CRASH_INFO_BUTTON
//    [[Crashlytics sharedInstance] crash];
#endif
    //=================
    [[ProjectorP2P_SessionManager sharedManager] serverSendPlayLogo];
    [self.tableView beginUpdates];
    self.showSessionInfo = !self.showSessionInfo;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)clientContolSwitchValueChanged:(id)sender {
    NSLog(@"clientContolSwitchValueChanged");
    PROSwitch *controlSwitch = (PROSwitch *)sender;
    NSUInteger row = controlSwitch.tag - 2;
    if ([self validIndex:row intoArray:self.connectedDevices]) {
        P2P_Device *device = [self.connectedDevices objectAtIndex:row];
        [[P2P_SessionManager sharedManager] setControlledByClientPeerId:device.name];
        [PCOEventLogger logEvent:@"Sessions - Toggled Client Control"];
    }
}


- (void)disconnectFromServerAction:(id)sender {
    if ([[P2P_SessionManager sharedManager] isConnectedClient]) {
        [[P2P_SessionManager sharedManager] disconnectFromServer:[[P2P_SessionManager sharedManager] connectedServerDevice]];
    }
}

- (void)setMirrorModeAction:(id)sender {
    [PCOEventLogger logEvent:@"Sessions - Set Mirror Mode"];
    [[ProjectorP2P_SessionManager sharedManager] setClientMode:P2PClientModeMirror];
    [self.tableView reloadData];
}

- (void)setConfidenceModeAction:(id)sender {
    [PCOEventLogger logEvent:@"Sessions - Set Confidence Mode"];
    [[ProjectorP2P_SessionManager sharedManager] setClientMode:P2PClientModeConfidence];
    [self.tableView reloadData];
}

- (void)setNoLyricsModeAction:(id)sender {
    [PCOEventLogger logEvent:@"Sessions - Set No Lyrics Mode"];
    [[ProjectorP2P_SessionManager sharedManager] setClientMode:P2PClientModeNoLyrics];
    [self.tableView reloadData];
}

- (void)pcoLiveSwitchValueChanged:(id)sender {
    PCOLiveStatus *status = [PCOLiveController sharedController].liveStatus;
    NSNumber *currentUserId = [PCOUserData current].userId;
    if ([status isControlledByUserId:currentUserId]) {
        [PCOEventLogger logEvent:@"Sessions - Control Services Live Off"];
        [[PCOLiveController sharedController] updateStatusWithControlledByName:@"" controlledById:nil];
    }
    else {
        [PCOEventLogger logEvent:@"Sessions - Control Services Live On"];
        [[PCOLiveController sharedController] updateStatusWithControlledByName:[[PCOUserData current] fullName] controlledById:currentUserId];
    }
    [[PCOLiveController sharedController] takeControlOfLiveSessionWithSuccessCompletion:^(PCOLiveStatus *status) {
        [self.tableView reloadData];
    } errorCompletion:^(NSError *error) {
        PCOLogError(@"PCOLiveSwitchValueChangedError: %@", [error localizedDescription]);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCOLiveStateChangedNotification object:nil];
}

#pragma mark -
#pragma mark - Helper Methods

- (UIColor *)colorForClientMode {
    UIColor *tintColor = [UIColor sessionsAvailableSessionsTextColor];
    switch ([ProjectorP2P_SessionManager sharedManager].clientMode) {
        case P2PClientModeNone:
            break;
        case P2PClientModeMirror:
            tintColor = [UIColor sessionsMirrorModeColor];
            break;
        case P2PClientModeConfidence:
            tintColor = [UIColor sessionsConfidenceColor];
            break;
        case P2PClientModeNoLyrics:
            tintColor = [UIColor sessionsNoLyricsColor];
            break;
        default:
            break;
    }
    return tintColor;
}

- (void)animatedRefresh {
    if ([[self.navigationController viewControllers] firstObject] == self) {
        [self.tableView beginUpdates];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSRangeFromString(@"0,2")];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else {
        [self.tableView reloadData];
    }
}

- (void)setPlanAndUpdateStatus {
    [[PCOLiveController sharedController] setLivePlan:[[PROSlideManager sharedManager] plan]];
    [[PCOLiveController sharedController] setCurrentUserId:[PCOUserData current].userId];
    [[PCOLiveController sharedController] getLiveStatusWithSuccessCompletion:^(PCOLiveStatus *status) {
        [self.tableView reloadData];
    } errorCompletion:^(NSError *error) {
        
    }];
}

- (NSArray *)availableServers {
    if (!_availableServers) {
        _availableServers = [[P2P_SessionManager sharedManager] availableServers];
    }
    return _availableServers;
}

- (NSArray *)connectedDevices {
    if (!_connectedDevices) {
        _connectedDevices = [[ProjectorP2P_SessionManager sharedManager] connectedDevices];
        NSLog(@"connected devices: %@", _connectedDevices);
    }
    return _connectedDevices;
}

- (BOOL)validIndex:(NSInteger)index intoArray:(NSArray *)array {
    if (index < (NSInteger)[array count]) {
        return YES;
    }
    return NO;
}

@end
