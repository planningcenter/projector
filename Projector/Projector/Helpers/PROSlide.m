/*!
 * PROSlide.m
 *
 *
 * Created by Skylar Schipper on 7/22/14
 */

#import "PROSlide.h"

#import "PROThumbnailView.h"
#import "PROSlideData.h"
#import "PROSlideLayout.h"
#import "PCOSlideLayout.h"

static NSCache * _slideImageCache = nil;

@interface PROSlide ()

@property (nonatomic, readwrite) NSInteger slideIndex;
@property (nonatomic, readwrite) NSInteger orderPosition;
@property (nonatomic, strong, readwrite) NSManagedObjectID *itemID;
@property (nonatomic, strong) PROThumbnailView *thumbnail;

@property (nonatomic, strong, readwrite) PROSlideLayout *textLayout;
@property (nonatomic, strong, readwrite) PROSlideLayout *titleLayout;
@property (nonatomic, strong, readwrite) PROSlideLayout *infoLayout;


@end

@implementation PROSlide

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _slideImageCache = [[NSCache alloc] init];
    });
}

+ (void)flushImageMemCache {
    [_slideImageCache removeAllObjects];
}

- (instancetype)initWithItem:(PCOItem *)item slide:(PROSlideData *)slide textLayout:(PROSlideLayout *)textLayout titleLayout:(PROSlideLayout *)titleLayout infoLayout:(PROSlideLayout *)infoLayout slideIndex:(NSInteger)slideIndex {
    self = [super init];
    if (self) {
        self.slideIndex = slideIndex;
        self.orderPosition = slide.orderPosition;
        [self setTextLayout:textLayout titleLayout:titleLayout infoLayout:infoLayout];
        [self pro_configureSlideForItem:item];
        [self pro_configureSlideForSlide:slide];
    }
    return self;
}

- (void)pro_configureSlideForItem:(PCOItem *)item {
    if ([item obtainPermanentID]) {
        self.itemID = [item objectID];
    }
    
    if (!item.selectedSlideLayout && item.selectedSlideLayoutId) {
        item.selectedSlideLayout = [PCOSlideLayout findFirstWithPredicate:[NSPredicate predicateWithFormat:@"remoteId == %@",item.selectedSlideLayoutId] inContext:item.managedObjectContext];
    }
    
    if (item.selectedSlideLayout) {
        self.backgroundColor = item.selectedSlideLayout.backgroundColor;
        
        if (!self.textLayout) {
            self.textLayout = [[PROSlideLayout alloc] initWithLayout:item.selectedSlideLayout.lyricTextLayout];
        }
        if (!self.titleLayout) {
            self.titleLayout = [[PROSlideLayout alloc] initWithLayout:item.selectedSlideLayout.titleTextLayout];
        }
        if (!self.infoLayout) {
            self.infoLayout = [[PROSlideLayout alloc] initWithLayout:item.selectedSlideLayout.songInfoLayout];
        }
    }
    
    self.serviceTypeID = item.plan.serviceTypeId;
}
- (void)pro_configureSlideForSlide:(PROSlideData *)slide {
    if (!slide) {
        return;
    }
    self.continueFromPrevious = slide.continuesFromPrevious;
    
    if (slide.title) {
        self.label = slide.title;
        if (self.continueFromPrevious) {
            self.label = [self.label stringByAppendingString:NSLocalizedString(@" (cont)", nil)];
        }
    }
    
    if (slide.body) {
        self.text = slide.body;
    }
}

- (void)setTextLayout:(PROSlideLayout *)textLayout titleLayout:(PROSlideLayout *)titleLayout infoLayout:(PROSlideLayout *)infoLayout {
    self.textLayout = [textLayout copy];
    self.titleLayout = [titleLayout copy];
    self.infoLayout = [infoLayout copy];
}

- (UIView *)thumbnailView {
    
//    NSLog(@"Using Thumbnail");
    if (self.thumbnail) {
        [self.thumbnail removeFromSuperview];
        return self.thumbnail;
    }
    
    welf();
    
    self.thumbnail = [[PROThumbnailView alloc] initWithFrame:CGRectZero];
    self.thumbnail.backgroundColor = self.backgroundColor;
    self.thumbnail.contentMode = self.contentMode;
    
    if (self.backgroundThumbnailURL) {
        self.thumbnail.backgroundImage = [_slideImageCache objectForKey:self.backgroundThumbnailURL.path compute:^id(id key) {
            return [UIImage imageWithContentsOfFile:key];
        }];
    }
    
    self.thumbnail.title = self.label;
    
    if (self.text.length > 0) {
        self.thumbnail.textLabel.text = self.text;
        [self.titleLayout configureTextLabel:self.thumbnail.textLabel];
        self.thumbnail.textLabel.boundsChangedHandler = ^(PROSlideTextLabel *label, CGRect bounds) {
            [welf.textLayout configureTextLabel:label];
            if (welf.copyright) {
                [welf.infoLayout configureTextLabel:self.thumbnail.infoLabel];
            }
        };
    }
    
    if (self.copyright) {
        self.thumbnail.infoLabel.text = self.copyright;
        [self.infoLayout configureTextLabel:self.thumbnail.infoLabel];
    }

    return self.thumbnail;
}


- (UIColor *)backgroundColor {
    if (!_backgroundColor) {
        _backgroundColor = [UIColor blackColor];
    }
    return _backgroundColor;
}

@end
