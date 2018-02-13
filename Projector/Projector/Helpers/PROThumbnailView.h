//
//  PROSlideThumbnail.h
//  
//
//  Created by Skylar Schipper on 4/10/14.
//
//

#ifndef PROSlideThumbnail_h
#define PROSlideThumbnail_h

#import "PCOView.h"
#import "PROSlideTextLabel.h"

@interface PROThumbnailView : PCOView

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak, readonly) PCOView *slideNameView;

@property (nonatomic, weak) PROSlideTextLabel *textLabel;
@property (nonatomic, weak) PROSlideTextLabel *infoLabel;

+ (void)setThumbnailViewNameHeight:(CGFloat)height;
+ (CGFloat)thumbnailViewNameHeight;

@end

#endif
