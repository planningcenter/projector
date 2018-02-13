/*!
 * PROSidebarTableHeaderView.m
 * Projector
 *
 *
 * Created by Skylar Schipper on 12/19/14
 */

#import "PROSidebarTableHeaderView.h"

@interface PROSidebarTableHeaderView ()

@end

@implementation PROSidebarTableHeaderView

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [UILabel newAutoLayoutView];
        label.font = [UIFont defaultFontOfSize_14];
        label.textColor = [UIColor sessionsHeaderTextColor];
        label.textAlignment = NSTextAlignmentLeft;
        
        _titleLabel = label;
        [self.contentView addSubview:label];
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:10.0 edges:UIRectEdgeLeft]];
        [self.contentView addConstraints:[NSLayoutConstraint offsetViewEdgesInSuperview:label offset:4.0 edges:UIRectEdgeBottom]];
    }
    return _titleLabel;
}

- (UILabel *)textLabel {
    return nil;
}

@end

_PCO_EXTERN_STRING PROSidebarTableHeaderViewIdentifier = @"PROSidebarTableHeaderViewIdentifier";
