//
//  PROUIOptimization.m
//  Projector
//
//  Created by Peter Fokos on 3/20/15.
//

#import "PROUIOptimization.h"

typedef NS_ENUM(NSInteger, PROState) {
    PROStatenInit                   = 0,
    PROStateColdStart               = 1,
    PROStatePlanSet                 = 2,
    PROStatePlanUpdating            = 3,
    PROStatePlanUpdated             = 4,
    PROStateLayoutsUpdating         = 5,
    PROStateLayoutsUpdated          = 6,
    PROStateRunning                 = 7,
    PROStateWarmStart               = 8,
    PROStateUIFullReloadStarted     = 9,
    PROStateUIFullReloadFinished    = 10,
};

@interface PROUIOptimization () {
    BOOL freshPlan;
    BOOL planUpdated;
    BOOL layoutsUpdated;
    BOOL gridHasDrawnOnce;
}

@property (nonatomic) PROState currentState;
@property (nonatomic) BOOL lowMemoryWarning;
@property (nonatomic, strong)   NSTimer *lastStateChange;

@property (nonatomic) NSInteger lastSection;
@property (nonatomic) NSInteger lastRow;

@end

@implementation PROUIOptimization

+ (instancetype)sharedOptimizer {
    static PROUIOptimization *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentState = PROStatenInit;
    }
    return self;
}

#pragma mark -
#pragma mark - App state reporters

- (void)setCurrentState:(PROState)currentState {
    _currentState = currentState;
    OptiEventLog(@"PROUIOptimization currentState: %@", [self currentStateDescription]);
}
- (void)appColdStarted {
    self.currentState = PROStateColdStart;
}

- (void)appWarmStarted {
    
}

- (void)loadingAFreshPlan {
    freshPlan = YES;
    planUpdated = NO;
    layoutsUpdated = NO;
}

- (void)planWasSet {
    self.currentState = PROStatePlanSet;
}

- (void)planStartedUpdating {
    self.currentState = PROStatePlanUpdating;
}

- (void)planFinishedUpdating {
    self.currentState = PROStatePlanUpdated;
    planUpdated = YES;
}

- (void)layoutStartedUpdating {
    self.currentState = PROStateLayoutsUpdating;
    layoutsUpdated = NO;
}

- (void)layoutFinishedUpdating {
    self.currentState = PROStateLayoutsUpdated;
    layoutsUpdated = YES;
}

- (BOOL)wasFreshPlan {
    BOOL result = freshPlan;
    freshPlan = NO;
    return result;
}

#pragma mark -
#pragma mark - Reload Requestors

- (BOOL)shouldGridReload {
    BOOL result = [self shouldGridReloadNoLog];
    if (result) {
        OptiEventLog(@"Allowing a Full reload on state: %@", [self currentStateDescription]);
    }
    else {
        OptiEventLog(@"NOT ALLOWING FULL RELOAD");
    }
    return result;
}

- (BOOL)shouldGridReloadNoLog {
    BOOL result = NO;
    
    switch (self.currentState) {
        case PROStatenInit:
        case PROStateColdStart:
        case PROStateWarmStart:
        case PROStatePlanUpdating:
        case PROStateLayoutsUpdating:
        case PROStateUIFullReloadStarted:
            result = NO;
            break;

        case PROStatePlanSet:
        case PROStatePlanUpdated:
        case PROStateLayoutsUpdated:
        case PROStateUIFullReloadFinished:
        case PROStateRunning:
            if (planUpdated && layoutsUpdated) {
                result = YES;
            }
            else {
                result = NO;
            }
            break;
            
        default:
            break;
    }
    return result;
}

- (BOOL)shouldGridReloadSection {
    if (gridHasDrawnOnce && planUpdated && layoutsUpdated) {
        if (self.currentState != PROStateUIFullReloadStarted) {
            OptiEventLog(@"Allowing a Section reload on state: %@", [self currentStateDescription]);
            return YES;
        }
    }
    OptiEventLog(@"NOT ALLOWING A SECTION RELOAD");
    return NO;
}

#pragma mark -
#pragma mark - Reload Reporters and Queries

- (void)startedFullUIReload {
    self.lastSection = 0;
    self.lastRow = 0;
    self.currentState = PROStateUIFullReloadStarted;
    gridHasDrawnOnce = NO;
}

- (void)finishedFullUIReload {
    self.currentState = PROStateUIFullReloadFinished;
    gridHasDrawnOnce = YES;
}

- (BOOL)isFullUIReloading {
    if (self.currentState == PROStateUIFullReloadStarted) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - Helpers

- (NSString *)currentStateDescription {
    NSString *stateString = @"";
    
    switch (self.currentState) {
        case PROStatenInit:
            stateString = @"PROStatenInit";
            break;
            
        case PROStateColdStart:
            stateString = @"PROStateColdStart";
            break;
            
        case PROStatePlanSet:
            stateString = @"PROStatePlanSet";
            break;
            
        case PROStatePlanUpdating:
            stateString = @"PROStatePlanUpdating";
            break;
            
        case PROStatePlanUpdated:
            stateString = @"PROStatePlanUpdated";
            break;
            
        case PROStateLayoutsUpdating:
            stateString = @"PROStateLayoutsUpdating";
            break;
            
        case PROStateUIFullReloadStarted:
            stateString = @"PROStateUIFullReloadStarted";
            break;
            
        case PROStateLayoutsUpdated:
            stateString = @"PROStateLayoutsUpdated";
            break;
            
        case PROStateWarmStart:
            stateString = @"PROStateWarmStart";
            break;
            
        case PROStateUIFullReloadFinished:
            stateString = @"PROStateUIFullReloadFinished";
            break;
            
        case PROStateRunning:
            stateString = @"PROStateRunning";
            break;
            
        default:
            break;
    }
    return stateString;
}

- (void)setNumberOfRows:(NSInteger)rows inSection:(NSInteger)section {
    if (rows > 0) {
        if (section > self.lastSection) {
            self.lastSection = section;
            self.lastRow = rows - 1;
            OptiEventLog(@"Last Section: %d, Last Row: %d", self.lastSection, self.lastRow);
        }
    }
}

- (BOOL)isLastCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.lastSection && indexPath.row == self.lastRow) {
        return YES;
    }
    return NO;
}

- (BOOL)isLastSection:(NSInteger)section {
    if (section == self.lastSection) {
        return YES;
    }
    return NO;
}


@end

_PCO_EXTERN_STRING PROUIOptimization_Full_Reload_Notification = @"PROUIOptimization_Full_Reload_Notification";
_PCO_EXTERN_STRING PROUIOptimization_Section_Reload_Notification = @"PROUIOptimization_Section_Reload_Notification";

