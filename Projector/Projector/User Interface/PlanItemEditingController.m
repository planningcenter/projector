//
//  PlanItemEditingController.m
//  Projector
//
//  Created by Peter Fokos on 11/4/14.
//

#import "PlanItemEditingController.h"
#import "PROSlideManager.h"
#import "PCOAttachment.h"
#import "PCOSlideLayout.h"
#import "PCOStanza.h"
#import "PROSlideHelper.h"
#import "PCODispatchGroup.h"
#import "PROItemStanzaHelper.h"
#import "PCOCustomSlide.h"
#import "PROSlideHelper.h"
#import "ProjectorP2P_SessionManager.h"

id static _sharedEditingController = nil;

@implementation PlanItemEditingController

#pragma mark -
#pragma mark - Singleton

+ (instancetype)sharedController {
    @synchronized (self) {
        if (!_sharedEditingController) {
            _sharedEditingController = [[[self class] alloc] init];
        }
        return _sharedEditingController;
    }
}

#pragma mark -
#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark -
#pragma mark - Backgrounds

- (void)changeBackgroundToAttachment:(PCOAttachment *)attachment forItem:(PCOItem *)item inPlan:(PCOPlan *)plan {
    [self changeItem:item backgroundAttachment:attachment];
    [self saveEditingChangesLocally];
    [self saveBackgroundEditingChangesForItem:item inPlan:plan];
    [PCOEventLogger logEvent:@"Plan Item Background Changed"];
}
- (void)changeBackgroundToAttachment:(PCOAttachment *)attachment forSlide:(PCOCustomSlide *)slide item:(PCOItem *)item plan:(PCOPlan *)plan {
    [self changeSlide:slide backgroundAttachment:attachment];
    [self saveEditingChangesLocally];
    [PROSlideHelper saveCustomSlide:slide itemID:item.remoteId completion:nil];
    [PCOEventLogger logEvent:@"Custom Slide Background Changed"];
}

- (void)changeItem:(PCOItem *)item backgroundAttachment:(PCOAttachment *)attachment {
    // Need this for Black Background selection
    NSString *attachmentId = @"0";
    
    if (attachment) {
        attachmentId = attachment.attachmentId;
    }
    
    item.slideBackgroundAttachmentId = attachmentId;
    item.slideBackgroundAttachment = attachment;
    
    for (PCOCustomSlide *slide in item.customSlides) {
        slide.selectedBackgroundAttachment = nil;
    }
}
- (void)changeSlide:(PCOCustomSlide *)slide backgroundAttachment:(PCOAttachment *)attachment {
    slide.selectedBackgroundAttachment = attachment;
    slide.backgroundAttachmentId = attachment.attachmentId;
    
    if ([slide isNew]) {
        slide.label = [attachment displayFilename];
    }
}

- (void)saveEditingChangesLocally {
    [[PCOCoreDataManager sharedManager] save:NULL];
}

- (void)saveBackgroundEditingChangesForItem:(PCOItem *)item inPlan:(PCOPlan *)plan {
    if ([plan canEdit]) {
        [[[PCOCoreDataManager sharedManager] itemsController] saveSlideBackgroundChangeForItem:item completion:^(NSError *error) {
            [[ProjectorP2P_SessionManager sharedManager] serverSendPlanItemChanged:item];
            PCOError(error);
        }];
    } else {
        MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Can't change item background", nil)
                                                              message:NSLocalizedString(@"Your current permissions don't allow you to save media changes in this plan to the cloud. Your changes will be lost when you reload the plan.", nil)
                                                    cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
        [[PROSlideManager sharedManager] emptyCacheOfItem:item];
        [[NSNotificationCenter defaultCenter] postNotificationName:PlanItemBackgroundChangedNotification object:item.objectID];
    }
}

- (void)addMedia:(PCOMedia *)media toItem:(PCOItem *)item inPlan:(PCOPlan *)plan {
    [[[PCOCoreDataManager sharedManager] itemsController] addMedia:media toItem:item completion:^(NSError *error) {
        if (error) {
            MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't add media", nil) message:[error localizedDescription] cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
            [alertView show];
        }
    }];

}

- (void)warnIfNotEditorForPlan:(PCOPlan *)plan {
    if (![plan canEdit]) {
        MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Can't edit item background", nil)
                                                              message:NSLocalizedString(@"Your current permissions don't allow you to save media changes in this plan to the cloud. Your changes will be lost when you reload the plan.", nil)
                                                    cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }
}

#pragma mark -
#pragma mark - Layouts

- (void)changeLayoutOfItem:(PCOItem *)item toLayout:(PCOSlideLayout *)layout inPlan:(PCOPlan *)plan {
    item.selectedSlideLayoutId = layout.remoteId;
    item.selectedSlideLayout = layout;
    
    if ([plan canEdit]) {
        [[[PCOCoreDataManager sharedManager] itemsController] saveSelectedLayout:layout.remoteId planID:plan.remoteId itemID:item.remoteId completion:^(NSError *error) {
            if (error) {
                MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't save layout", nil) message:[error localizedDescription] cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
                [alertView show];
            } else {
                [[ProjectorP2P_SessionManager sharedManager] serverSendPlanItemChanged:item];
                [[PROSlideManager sharedManager] emptyCacheOfItem:item];
            }
        }];
    } else {
        MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Can't edit item layout", nil)
                                                              message:NSLocalizedString(@"Your current permissions don't allow you to save layout changes in this plan to the cloud. Your changes will be lost when you reload the plan.", nil)
                                                    cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
        [[PROSlideManager sharedManager] emptyCacheOfItem:item];
    }
}

#pragma mark -
#pragma mark - Arrangement Sequence

- (void)warnIfNotArrangementSequenceEditorForPlan:(PCOPlan *)plan {
    if (![plan canEdit]) {
        MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Can't save changes", nil)
                                                              message:NSLocalizedString(@"Your current permissions don't allow you to save sequence changes in this plan to the cloud. Your changes will be lost when you reload the plan.", nil)
                                                    cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }
}

- (void)saveArrangementSequenceEditingChangesForItem:(PCOItem *)item inPlan:(PCOPlan *)plan {
    [[PCOCoreDataManager sharedManager] save:NULL];
    
    if ([plan canEdit]) {
        [[[PCOCoreDataManager sharedManager] itemsController] saveSequenceChanges:item toArrangement:[item.saveSequenceToArrangement boolValue] completion:^(NSError *error) {
            [[ProjectorP2P_SessionManager sharedManager] serverSendPlanItemChanged:item];
            if (error) {
                [MCTAlertView showError:error];
            }
        }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ArrangementSequenceChangesNotification object:item];
}

#pragma mark -
#pragma mark - Slide Breaks

- (BOOL)saveSlideBreaksForItem:(PCOItem *)item inPlan:(PCOPlan *)plan withStanza:(PCOStanza *)stanza lyrics:(NSArray *)lyrics completionBlock:(void (^)(void))completionBlock {
    // clear out all the slide breaks
    
    NSUInteger linesPerSlide = [PROSlideItem numberOfLinesPerSlideForItem:item];
    
    [stanza autoGenerateSlideBreaksForLayoutWithDefaultLineCount:linesPerSlide];
    
    PCOSlideBreak *slideBreaks = [stanza slideBreakDictionaryWithNumberOfLinesPerSlide:linesPerSlide];
    
    if (!slideBreaks)
    {
        return NO;
    }
    
    [stanza removeAllSlideBreaksWithLineCount:linesPerSlide];
    
    //NSInteger slideNumber = 2;  // start at 2 to be sure 1st line will be called index 0
    NSInteger lineIndex = 0;
    
    // now put in all the slide breaks found skipping #1
    for (NSString *line in lyrics) {
        
        NSRange lineRange = [line rangeOfString:SlideNumberText];
        // is it a line break?
        if (lineRange.location != NSNotFound)
        {
            // ignore the first one
            if ([lyrics indexOfObject:line] > 0)
            {
                // should still be previous line index, so use it to enter break...
                [stanza insertSlideBreakAfterLine:lineIndex - 1 withLineCount:linesPerSlide];
            }
        }
        else
        {
            lineIndex++; // since this isn't a line break stand-in, bump the line index
        }
    }
    if ([plan canEdit]) {
        [[[PCOCoreDataManager sharedManager] itemsController] saveSlideBreaksForItem:item linesPerSlide:[PROSlideItem numberOfLinesPerSlideForItem:item] completion:^(NSError *error) {
            [[ProjectorP2P_SessionManager sharedManager] serverSendPlanItemChanged:item];
            [PROItemStanzaHelper clearCache];
            if (error) {
                MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't save slide breaks", nil) message:[error localizedDescription] cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
                [alertView show];
            }
            completionBlock();
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:ArrangementSequenceChangesNotification object:item];
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark - Lyrics Text

- (void)saveLyrics:(NSString *)lyrics forItem:(PCOItem *)item inPlan:(PCOPlan *)plan {
    if ([plan canEdit]) {
        [PROSlideHelper saveChordChart:lyrics item:item completion:^(NSError *error) {
            PCOError(error);
            [[[PCOCoreDataManager sharedManager] itemsController] updateSlideSequenceAndSectionsForItem:item completion:^(NSError *error) {
                [[ProjectorP2P_SessionManager sharedManager] serverSendPlanItemChanged:item];
                PCOError(error);
                if (error) {
                    MCTAlertView *alert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Oops...", nil)
                                                                      message:NSLocalizedString(@"Looks like something broke.  Please try again.", nil)
                                                            cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
                    [alert show];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:ArrangementSequenceChangesNotification object:item];
            }];
        }];
    }
}

#pragma mark -
#pragma mark - Custom Slides

- (void)warnIfNotCustomSlideEditorForPlan:(PCOPlan *)plan {
    if (![plan canEdit]) {
        MCTAlertView *alertView = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Can't save changes", nil)
                                                              message:NSLocalizedString(@"Your current permissions don't allow you to save custom slide changes in this plan to the cloud. Your changes will be lost when you reload the plan.", nil)
                                                    cancelButtonTitle:NSLocalizedString(@"Ok", nil)];
        [alertView show];
    }
}


- (void)saveCustomSlides:(NSArray *)slideIds deletedSlideIds:(NSArray *)deletedSlideIds forItem:(PCOItem *)item inPlan:(PCOPlan *)plan completionBlock:(void (^)(void))completionBlock {
    [[PCOCoreDataManager sharedManager] save:NULL];
    
    if (![plan canEdit]) {
        [[PROSlideManager sharedManager] emptyCacheOfItem:item];
        [[NSNotificationCenter defaultCenter] postNotificationName:PlanItemBackgroundChangedNotification object:item.objectID];
        completionBlock();
        return;
    }
    
    for (NSNumber *slideId in deletedSlideIds) {
        [PROSlideHelper deleteCustomSlide:slideId itemID:item.remoteId completion:^(NSError *error) {
            PCOError(error);
        }];
    }
    
    void(^saveSlideOrder)(void) = ^ {
        [PROSlideHelper saveCustomSlideOrder:item completion:^(NSError *error) {
            PCOError(error);
            
            [[PROSlideManager sharedManager] emptyCacheOfItem:item];
            [[ProjectorP2P_SessionManager sharedManager] serverSendPlanItemChanged:item];

            if (error) {
                MCTAlertView *errorAlert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't save slides", nil)
                                                                       message:[error localizedDescription]
                                                             cancelButtonTitle:NSLocalizedString(@"OK", nil)];
                [errorAlert show];
            } else if (completionBlock) {
                completionBlock();
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PlanItemBackgroundChangedNotification object:item.objectID];
        }];
    };
    
    if (slideIds.count > 0) {
        PCODispatchGroup *group = [PCODispatchGroup create];
        
        
        NSError __block *_error = nil;
        for (NSManagedObjectID *slideObjectID in slideIds) {
            PCOCustomSlide *slide = [[PCOCoreDataManager sharedManager] objectWithID:slideObjectID inContext:item.managedObjectContext];
            [group enter];
            [PROSlideHelper saveCustomSlide:slide itemID:item.remoteId completion:^(NSError *error) {
                if (!_error) {
                    _error = error;
                }
                [group leave];
            }];
        }
        
        [group wait:^{
            if (_error) {
                MCTAlertView *errorAlert = [[MCTAlertView alloc] initWithTitle:NSLocalizedString(@"Couldn't save slides", nil)
                                                                       message:[_error localizedDescription]
                                                             cancelButtonTitle:NSLocalizedString(@"OK", nil)];
                [errorAlert show];
            } else {
                saveSlideOrder();
            }
        }];
    } else {
        saveSlideOrder();
    }
}




@end

_PCO_EXTERN_STRING PlanItemBackgroundChangedNotification = @"PlanItemBackgroundChangedNotification";
_PCO_EXTERN_STRING PlanItemLayoutChangedNotification = @"PlanItemLayoutChangedNotification";
_PCO_EXTERN_STRING ArrangementSequenceChangesNotification = @"ArrangementSequenceChangesNotification";
_PCO_EXTERN_STRING SlideNumberText =  @">>> Slide";
