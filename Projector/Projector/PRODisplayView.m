/*!
 * PRODisplayView.m
 *
 *
 * Created by Skylar Schipper on 3/24/14
 */

#import "PRODisplayView.h"
#import "PRODisplayController.h"
#import "CATransaction+PCOKitAddition.h"
#import "PROSlideTextLabel.h"
#import "PRODisplayBackgroundImageView.h"
#import "PROLogoDisplayItem.h"
#import "PRODisplayViewActionButton.h"
#import "NSString+FileTypeAdditions.h"
#import "PCOSlideLayout.h"
#import "ProjectorP2P_SessionManager.h"
#import "UIFont+ProjectorBoldMaker.h"
#import "PRORecordingController.h"

@import AVFoundation;

static NSTimeInterval pro_defaultAnimationDuration = 0.2;
static NSString *const kBackgroundFadeInAnimation = @"background_fade_in";
static NSString *const kBackgroundFadeOutAnimation = @"background_fade_out";

@interface PRODisplayView ()

@property (nonatomic, weak) PCOLabel *alertLabel;

@property (nonatomic, weak, readwrite) AVPlayerLayer *playerLayer;

@property (nonatomic, weak) PRODisplayBackgroundImageView *backgroundImageView;

@property (nonatomic, weak) PROSlideTextLabel *textLabel;

@property (nonatomic, weak) PROSlideTextLabel *confidenceTextLabel;

@property (nonatomic, weak) PROSlideTextLabel *infoLabel;

@property (nonatomic, strong) id playerTimeObserver;

@property (nonatomic, weak, readonly) PROSlideTextLabel *lazyInfoLabel;

@property (nonatomic, weak) PRODisplayViewActionButton *alertButton;
@property (nonatomic, weak) PRODisplayViewActionButton *logoButton;
@property (nonatomic, weak) PRODisplayViewActionButton *blackButton;

@property (nonatomic, weak) NSLayoutConstraint *alertTopConstraint;
@property (nonatomic, weak) NSLayoutConstraint *logoTopConstraint;
@property (nonatomic, weak) NSLayoutConstraint *blackTopConstraint;

@end

@implementation PRODisplayView

- (void)initializeDefaults {
    [super initializeDefaults];
    self.staticView = NO;
    self.priority = PRODisplayViewPriorityScreen;
    self.clipsToBounds = YES;
    self.layer.needsDisplayOnBoundsChange = YES;
    self.backgroundAnimation = PRODisplayViewAnimateCrossFade;
    self.showActionButtons = NO;
    self.actionButtonsTopOffset = 4.0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setItem:(PRODisplayItem *)item {
    [self setItem:item animated:YES];
}
- (void)setItem:(PRODisplayItem *)item animated:(BOOL)animated {
    if (animated) {
        [self setItem:item animationType:PRODisplayViewAnimateCrossFade];
        return;
    }
    [self setItem:item animationType:PRODisplayViewAnimateNone];
}
- (void)setItem:(PRODisplayItem *)item animationType:(PRODisplayViewSlideAnimation)animationType {
    [self setItem:item animationType:animationType completion:nil];
}
- (void)setItem:(PRODisplayItem *)item animationType:(PRODisplayViewSlideAnimation)animationType completion:(void(^)(BOOL finished))completion {
    PRODisplayItem __block *fromItem = _item;
#pragma unused(fromItem)
    
    _item = item;
    
    self.contentMode = item.contentMode;
    
    BOOL animateText = (animationType != PRODisplayViewAnimateNone);
    
    NSInteger currentPlanItemIndex = item.indexPath.section;
    BOOL confidenceModeOn = [[ProjectorP2P_SessionManager sharedManager] useConfidenceModeAtPlanItemIndex:currentPlanItemIndex];
    

    if (confidenceModeOn) {
        self.backgroundColor = [UIColor blackColor];
        self.confidenceTextLabel.text = nil;
    }
    
    void(^animation)(void) = ^{
        if (animateText) {
            CATransition *animation = [CATransition animation];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionFade;
            animation.duration = pro_defaultAnimationDuration;
            [self.textLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
        }
        if (!confidenceModeOn) {
            self.backgroundColor = item.background.backgroundColor;
        }
        self.textLabel.text = item.text;
        [item.textLayout configureTextLabel:self.textLabel];
        self.textLabel.boundsChangedHandler = ^(PROSlideTextLabel *l, CGRect b) {
            [item.textLayout configureTextLabel:l];
        };
        if (confidenceModeOn) {
            self.backgroundColor = [UIColor blackColor];
            PCOSlideLayout *layout = [[[PCOCoreDataManager sharedManager] layoutsController] confidenceModeLayoutForServiceTypeID:item.serviceTypeID];
            PROSlideLayout *confidenceLayout = [[PROSlideLayout alloc] initWithLayout:layout.lyricTextLayout];
            [confidenceLayout prepareFont:^UIFont *(UIFont *font) {
                if (![font isBold] && [[ProjectorSettings userSettings] confidenceTextWeight] == ProjectorConfidenceTextWeightBold) {
                    return [font boldFont];
                }
                return font;
            }];
            self.textLabel.vertialAlignment = PROTextVertialAlignmentCenter;
            [confidenceLayout configureTextLabel:self.textLabel];

            if (item.confidenceText) {
                self.confidenceTextLabel.text = item.confidenceText;
                [confidenceLayout configureTextLabel:self.confidenceTextLabel];
                self.confidenceTextLabel.vertialAlignment = PROTextVertialAlignmentBottom;
            }
        } else {
            self.confidenceTextLabel.text = nil;
        }
        
        if (item.infoText.length > 0) {
            self.infoLabel.text = item.infoText;
            [item.infoLayout configureTextLabel:self.infoLabel];
            self.infoLabel.boundsChangedHandler = ^(PROSlideTextLabel *l, CGRect b) {
                [item.infoLayout configureTextLabel:l];
            };
            if (animateText) {
                CATransition *animation = [CATransition animation];
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                animation.type = kCATransitionFade;
                animation.duration = pro_defaultAnimationDuration;
                [self.infoLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
            }
        } else {
            [self.lazyInfoLabel removeFromSuperview];
        }
    };
    
    if (animationType == PRODisplayViewAnimateNone) {
        animation();
        if (completion) {
            completion(YES);
        }
    } else {
        [UIView animateWithDuration:pro_defaultAnimationDuration animations:animation completion:completion];
    }
    
    [self setNeedsDisplay];
}

- (BOOL)isPrimary {
    return ([[PRODisplayController sharedController] liveView] == self);
}
- (BOOL)isUpNext {
    return self.priority <= PRODisplayViewPriorityUpNext;
}

- (void)setHideLyrics:(BOOL)hideLyrics {
    _hideLyrics = hideLyrics;
    
    if (hideLyrics) {
        [UIView animateWithDuration:0.2 animations:^{
            self.textLabel.alpha = 0.0;
            self.lazyInfoLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.textLabel.alpha = 1.0;
            self.lazyInfoLabel.alpha = 1.0;
        }];
    }
}

- (void)setControlsView:(UIView *)controlsView {
    _controlsView = controlsView;
    [self insertSubview:controlsView atIndex:[self.subviews count]];
}

- (void)addViewBelowControlView:(UIView *)view {
    if (!self.controlsView) {
        [self addSubview:view];
    }
    else {
        [self insertSubview:view belowSubview:self.controlsView];
    }
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    
    _backgroundImageView.contentMode = contentMode;
}

- (void)setPriority:(NSUInteger)priority {
    _priority = priority;
    if (priority >= PRODisplayViewPriorityLiveScreen) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark -
#pragma mark - Lazy Loaders
- (PROSlideTextLabel *)textLabel {
    if (!_textLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        
        _textLabel = label;
        [self addViewBelowControlView:label];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:0.0 edges:UIRectEdgeAll]];
    }
    return _textLabel;
}

- (PROSlideTextLabel *)confidenceTextLabel {
    if (!_confidenceTextLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        label.seperatorLineOn = YES;
        _confidenceTextLabel = label;
        [self addViewBelowControlView:label];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:0.0 edges:UIRectEdgeAll]];
    }
    return _confidenceTextLabel;
}

- (PROSlideTextLabel *)infoLabel {
    if (!_infoLabel) {
        PROSlideTextLabel *label = [PROSlideTextLabel newAutoLayoutView];
        label.backgroundColor = [UIColor clearColor];
        
        _infoLabel = label;
        [self addViewBelowControlView:label];
        
        [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:0.0 edges:UIRectEdgeAll]];
    }
    return _infoLabel;
}
- (PROSlideTextLabel *)lazyInfoLabel {
    return _infoLabel;
}

- (UILabel *)recLabel {
    if (!_recLabel) {
        UILabel *label = [UILabel newAutoLayoutView];
        label.font = [UIFont boldDefaultFontOfSize_16];
        label.textColor = [UIColor redColor];
        label.text = @"REC";
        label.textAlignment = NSTextAlignmentLeft;
        label.hidden = YES;
        _recLabel = label;
        
        [self addSubview:label];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50.0]];
       _recLabel = label;
    }
    return _recLabel;
}

- (PCOButton *)cameraButton {
    if (!_cameraButton) {
        PCOButton *view = [PCOButton newAutoLayoutView];
        [view setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [view setImage:[UIImage imageNamed:@"camera-icon"] forState:UIControlStateNormal];
        view.hidden = YES;
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.recLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0]];
        _cameraButton = view;
    }
    return _cameraButton;
}

#pragma mark -
#pragma mark - Debug
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ {%lu, %@}",[super description],(unsigned long)self.priority,self.item];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    
    self.playerLayer.frame = layer.bounds;
}

#pragma mark -
#pragma mark - Defaults
+ (void)setDefaultAnimationDuration:(NSTimeInterval)defaultAnimationDuration {
    pro_defaultAnimationDuration = defaultAnimationDuration;
}
+ (NSTimeInterval)defaultAnimationDuration {
    return pro_defaultAnimationDuration;
}

- (void)displayAlert:(PROAlertView *)alertView {
    if (!alertView) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alertLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.alertLabel removeFromSuperview];
            self.alertLabel = nil;
        }];
        return;
    }
    
    [self.alertLabel removeFromSuperview];
    self.alertLabel = nil;
    
    CGFloat offset = MIN(floor(CGRectGetWidth(self.bounds) / 10.0), 10.0);
    CGFloat height = floor(CGRectGetHeight(self.bounds) / 16.0);
    
    PCOLabel *label = [PCOLabel newAutoLayoutView];
    label.font = [UIFont defaultFontOfSize:height];
    label.text = alertView.alertText;
    label.alpha = 0.0;
    label.insets = UIEdgeInsetsMake(0.0, 3.0, 0.0, 3.0);
    
    [alertView configureLabel:label];
    
    NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:6];
    
    self.alertLabel = label;
    [self addViewBelowControlView:label];
    
    // Top
    if (alertView.position == PROScreenTopLeftPosition) {
        [constraints addObjectsFromArray:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:offset edges:UIRectEdgeTop | UIRectEdgeLeft]];
    } else if (alertView.position == PROScreenTopMiddlePosition) {
        [constraints addObjectsFromArray:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:offset edges:UIRectEdgeTop]];
        [constraints addObject:[NSLayoutConstraint centerHorizontal:label inView:self]];
    } else if (alertView.position == PROScreenTopRightPosition) {
        [constraints addObjectsFromArray:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:offset edges:UIRectEdgeTop | UIRectEdgeRight]];
    }
    // Middle
    if (alertView.position == PROScreenMiddleLeftPosition) {
        [constraints addObjectsFromArray:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:offset edges:UIRectEdgeLeft]];
        [constraints addObject:[NSLayoutConstraint centerVertical:label inView:self]];
    } else if (alertView.position == PROScreenMiddleMiddlePosition) {
        [constraints addObjectsFromArray:[NSLayoutConstraint center:label inView:self]];
    } else if (alertView.position == PROScreenMiddleRightPosition) {
        [constraints addObject:[NSLayoutConstraint centerVertical:label inView:self]];
        [constraints addObjectsFromArray:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:offset edges:UIRectEdgeRight]];
    }
    // Bottom
    if (alertView.position == PROScreenBottomLeftPosition) {
        [constraints addObjectsFromArray:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:offset edges:UIRectEdgeBottom | UIRectEdgeLeft]];
    } else if (alertView.position == PROScreenBottomMiddlePosition) {
        [constraints addObjectsFromArray:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:offset edges:UIRectEdgeBottom]];
        [constraints addObject:[NSLayoutConstraint centerHorizontal:label inView:self]];
    } else if (alertView.position == PROScreenBottomRightPosition) {
        [constraints addObjectsFromArray:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:offset edges:UIRectEdgeBottom | UIRectEdgeRight]];
    }
    
    
    
    [self addConstraints:constraints];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alertLabel.alpha = 1.0;
    }];
}

- (BOOL)isAlertActive {
    return (self.alertLabel.superview && self.alertLabel.alpha > 0.0);
}

- (void)loadBackgroundImageViewIfNeeded {
    if (self.backgroundImageView) {
        return;
    }
    
    PRODisplayBackgroundImageView *view = [PRODisplayBackgroundImageView newAutoLayoutView];
    view.contentMode = self.contentMode;
    
    self.backgroundImageView = view;
    [self insertSubview:view atIndex:0];
    
    [self addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:view offset:0.0 edges:UIRectEdgeAll]];
}

#pragma mark -
#pragma mark - Background
- (AVPlayer *)backgroundPlayer {
    return self.playerLayer.player;
}
- (void)setBackgroundPlayer:(AVPlayer *)player {
    self.backgroundImageView.image = nil;
    if (!player) {
        [self removeVideoPlayerTimeObserver];
        self.playerLayer.player = nil;
        return;
    }
    if (!self.playerLayer) {
        [self setupPlayerLayerForPlayer:player animated:NO];
    } else {
        self.playerLayer.player = player;
    }
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notif {
    if (![self isPrimary] ) {
        return;
    }
    if ([[PRODisplayController sharedController] videoFinishedShouldItLoop] || [self.item isKindOfClass:[PROLogoDisplayItem class]]) {
        AVPlayerItem *item = notif.object;
        [item seekToTime:kCMTimeZero];
        [self videoPlay];
    }
}
- (void)setupPlayerLayerForPlayer:(AVPlayer *)player animated:(BOOL)animated {
    AVPlayerLayer *currentPlayerLayer = self.playerLayer;
    [self removeVideoPlayerTimeObserver];
    self.playerLayer = nil;
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.opacity = 0.0;
    layer.frame = self.layer.bounds;
    
    if (UIViewContentModeProjectorPreferred == UIViewContentModeScaleAspectFit) {
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
    } else {
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    [self.layer insertSublayer:layer atIndex:0];
    self.playerLayer = layer;
    
    void(^completion)(void) = ^{
        [currentPlayerLayer removeFromSuperlayer];
        [currentPlayerLayer.player pause];
    };
    
    if (self.backgroundAnimation != PRODisplayViewAnimateNone) {
        
        void(^trans)(void) = ^ {
            CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:PCOKeyPath(layer, opacity)];
            fadeIn.fromValue = @0.0;
            fadeIn.toValue = @1.0;
            layer.opacity = 1.0;
            [layer addAnimation:fadeIn forKey:kBackgroundFadeInAnimation];
            
            if (currentPlayerLayer && ![currentPlayerLayer animationForKey:kBackgroundFadeOutAnimation]) {
                CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:PCOKeyPath(currentPlayerLayer, opacity)];
                fadeOut.fromValue = @1.0;
                fadeOut.toValue = @0.0;
                currentPlayerLayer.opacity = 0.0;
                [currentPlayerLayer addAnimation:fadeOut forKey:kBackgroundFadeOutAnimation];
            }
        };
        
        [CATransaction transaction:trans duration:pro_defaultAnimationDuration completion:completion];
    }
}

- (void)displayBackground:(PRODisplayItemBackground *)background {
    self.backgroundColor = background.backgroundColor;
    self.backgroundImageView.image = nil;
    
    if ([self isPrimary] && ![self isUpNext]) {
        if ([[background.primaryBackgroundURL absoluteString] isImage]) {
            [self loadBackgroundImageViewIfNeeded];
            UIImage *image = [UIImage imageWithContentsOfFile:background.primaryBackgroundURL.path];
            self.backgroundImageView.image = image;
        } else if (background.primaryBackgroundURL) {
            AVPlayer *player = [AVPlayer playerWithURL:background.primaryBackgroundURL];
            [self setupPlayerLayerForPlayer:player animated:YES];
            
            if ([[PRORecordingController sharedController] isRecording]) {
                [self loadBackgroundImageViewIfNeeded];
                self.backgroundImageView.image = background.staticBackgroundImage;
            }
        }
    } else {
        [self loadBackgroundImageViewIfNeeded];
        
        self.backgroundImageView.image = background.staticBackgroundImage;
    }
    [self layoutIfNeeded];
}
- (void)clearBackground {
    self.backgroundColor = [UIColor blackColor];
    
    AVPlayerLayer *playerLayer = self.playerLayer;
    UIImageView *imageView = self.backgroundImageView;
    
    [self removeVideoPlayerTimeObserver];
    
    self.playerLayer = nil;
    self.backgroundImageView = nil;
    
    void(^completion)(void) = ^{
        [playerLayer removeFromSuperlayer];
        [imageView removeFromSuperview];
    };
    if (self.backgroundAnimation != PRODisplayViewAnimateNone) {
        void(^trans)(void) = ^ {
            if (playerLayer) {
                CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:PCOKeyPath(playerLayer, opacity)];
                fadeOut.fromValue = @1.0;
                fadeOut.toValue = @0.0;
                playerLayer.opacity = 0.0;
                [playerLayer addAnimation:fadeOut forKey:kBackgroundFadeOutAnimation];
            }
            if (imageView) {
                CABasicAnimation *imageFadeOut = [CABasicAnimation animationWithKeyPath:PCOKeyPath(imageView.layer, opacity)];
                imageFadeOut.fromValue = @1.0;
                imageFadeOut.toValue = @0.0;
                imageView.layer.opacity = 0.0;
                [imageView.layer addAnimation:imageFadeOut forKey:kBackgroundFadeOutAnimation];
            }
        };
        [CATransaction transaction:trans duration:pro_defaultAnimationDuration completion:completion];
    } else {
        completion();
    }
}

#pragma mark -
#pragma mark - Video playback methods

- (void)videoPlay {
    if (self.playerLayer.player) {
        [self.playerLayer.player play];
        
        CMTime interval = CMTimeMake(100, 1000); // 1/10 sec
        [self removeVideoPlayerTimeObserver];
        self.playerTimeObserver = [self.playerLayer.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PRODisplayViewVideoPlaybackTimeDidChangeNotification object:nil];
        }];
    }
}

- (void)videoPause {
    [self.playerLayer.player pause];
}

- (void)videoSeekToTimeInSeconds:(NSInteger)seconds {
    CMTime time = CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC);
    [self.playerLayer.player seekToTime:time completionHandler:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PRODisplayViewVideoPlaybackTimeDidChangeNotification object:nil];
    }];
}

- (BOOL)videoExists {
    if (self.playerLayer.player.currentItem) {
        return YES;
    }
    return NO;
}

- (BOOL)videoPlaying {
    if (self.playerLayer.player.rate > 0.0) {
        return YES;
    }
    return NO;
}

- (BOOL)videoPaused {
    if ([self videoPlaying]) {
        return NO;
    }
    return YES;
}

- (CGFloat)videoDurationInSeconds {
    CGFloat seconds = 0.0;
    if ([self videoExists]) {
        CMTime duration = self.playerLayer.player.currentItem.asset.duration;
        seconds = CMTimeGetSeconds(duration);
    }
    return seconds;
}

- (CGFloat)videoPositionInSeconds {
    CGFloat seconds = 0.0;
    if ([self videoExists]) {
        CMTime position = self.playerLayer.player.currentTime;
        seconds = CMTimeGetSeconds(position);
    }
    return seconds;
}

- (void)removeVideoPlayerTimeObserver {
    if (self.playerLayer.player && self.playerTimeObserver) {
        @try {
            // There is a weird issue here when enabling/disabling second screen that throws an exception.
            [self.playerLayer.player removeTimeObserver:self.playerTimeObserver];
            _playerTimeObserver = nil;
        }
        @catch (NSException *exception) {
            
        }
        self.playerTimeObserver = nil;
    }
}

// MARK: - Action Buttons
- (void)setShowActionButtons:(BOOL)showActionButtons {
    _showActionButtons = showActionButtons;
    
    if (!showActionButtons) {
        [self teardownActionButtonsIfNeeded];
    } else {
        [self setupActionButtonsIfNeeded];
    }
}
- (void)teardownActionButtonsIfNeeded {
    _alertButton.alpha = 0.0;
    _logoButton.alpha = 0.0;
    _blackButton.alpha = 0.0;
}
- (void)_teardownActionsButtons {
    [_alertButton removeFromSuperview];
    [_logoButton removeFromSuperview];
    [_blackButton removeFromSuperview];
    
    _alertButton = nil;
    _logoButton = nil;
    _blackButton = nil;
}
- (void)setupActionButtonsIfNeeded {
    [self _teardownActionsButtons];
    
    PRODisplayViewActionButton *alert = [[PRODisplayViewActionButton alloc] initWithTitle:NSLocalizedString(@"A", nil)];
    PRODisplayViewActionButton *logo = [[PRODisplayViewActionButton alloc] initWithTitle:NSLocalizedString(@"L", nil)];
    PRODisplayViewActionButton *black = [[PRODisplayViewActionButton alloc] initWithTitle:NSLocalizedString(@"B", nil)];
    
    _alertButton = alert;
    _logoButton = logo;
    _blackButton = black;
    
    [self addSubview:alert];
    [self addSubview:logo];
    [self addSubview:black];
    
    NSDictionary *metrics = @{
                              @"padding": @4.0
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(alert, logo, black);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormats:@[
                                                                            @"H:[alert]-padding-[logo]-padding-[black]-padding-|"
                                                                            ]
                                                                  metrics:metrics
                                                                    views:views]];
    
    NSLayoutConstraint *alertTop = [NSLayoutConstraint constraintWithItem:alert attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.actionButtonsTopOffset];
    NSLayoutConstraint *logoTop = [NSLayoutConstraint constraintWithItem:logo attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.actionButtonsTopOffset];
    NSLayoutConstraint *blackTop = [NSLayoutConstraint constraintWithItem:black attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.actionButtonsTopOffset];
    
    [self addConstraints:@[alertTop, logoTop, blackTop]];
    
    _alertTopConstraint = alertTop;
    _logoTopConstraint = logoTop;
    _blackTopConstraint = blackTop;
    
    [UIView performWithoutAnimation:^{
        alert.alpha = 0.0;
        logo.alpha = 0.0;
        black.alpha = 0.0;
        [self layoutIfNeeded];
    }];
    
    
    alert.alpha = 1.0;
    logo.alpha = 1.0;
    black.alpha = 1.0;
}

- (PRODisplayViewActionButton *)actionAlertButton {
    if (![self showActionButtons]) {
        return nil;
    }
    return _alertButton;
}
- (PRODisplayViewActionButton *)actionLogoButton {
    if (![self showActionButtons]) {
        return nil;
    }
    return _logoButton;
}
- (PRODisplayViewActionButton *)actionBlackButton {
    if (![self showActionButtons]) {
        return nil;
    }
    return _blackButton;
}

- (void)setActionButtonsTopOffset:(CGFloat)actionButtonsTopOffset {
    _actionButtonsTopOffset = actionButtonsTopOffset;
    self.alertTopConstraint.constant = actionButtonsTopOffset;
    self.logoTopConstraint.constant = actionButtonsTopOffset;
    self.blackTopConstraint.constant = actionButtonsTopOffset;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint([[self actionAlertButton] frame], point)) {
        return [self actionAlertButton];
    }
    if (CGRectContainsPoint([[self actionLogoButton] frame], point)) {
        return [self actionLogoButton];
    }
    if (CGRectContainsPoint([[self actionBlackButton] frame], point)) {
        return [self actionBlackButton];
    }
    if (!self.cameraButton.hidden && CGRectContainsPoint([[self cameraButton] frame], point)) {
        return [self cameraButton];
    }

    return [super hitTest:point withEvent:event];
}

@end

_PCO_EXTERN_STRING PRODisplayViewVideoPlaybackTimeDidChangeNotification = @"PRODisplayViewVideoPlaybackTimeDidChangeNotification";


