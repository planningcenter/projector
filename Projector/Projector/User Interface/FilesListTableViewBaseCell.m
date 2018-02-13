/*!
 * FilesListTableViewBaseCell.m
 *
 *
 * Created by Skylar Schipper on 8/5/14
 */

#import "FilesListTableViewBaseCell.h"
#import "PROSidebarDetailsCell.h"

@interface FilesListTableViewBaseCell ()

@property (nonatomic, weak) PCOView *progressView;

@end

@implementation FilesListTableViewBaseCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (void)initializeDefaults {
    [super initializeDefaults];
    
    [PROSidebarDetailsCell configureCell:self];;
    
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    self.progress = 0.0;
    self.identifier = 0;
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleLabel.font = [UIFont defaultFontOfSize_14];
    self.subTitleLabel.font = [UIFont defaultFontOfSize:10.0];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.progress = 0.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.progress > 0.0) {
        self.progressView.frame = ({
            CGRect frame = CGRectZero;
            CGFloat h = 2.0;
            frame.origin.y = CGRectGetHeight(self.contentView.bounds) - h;
            frame.size.height = h;
            frame.size.width = CGRectGetWidth(self.contentView.bounds) * self.progress;
            frame;
        });
    }
    
    [super layoutSubviews];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    if (progress <= 0.0) {
        [_progressView removeFromSuperview];
        _progressView = nil;
    }
    
    [self setNeedsLayout];
}

- (PCOView *)progressView {
    if (!_progressView) {
        PCOView *view = [[PCOView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor projectorOrangeColor];
        
        _progressView = view;
        [self.contentView addSubview:view];
    }
    return _progressView;
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
}

@end

_PCO_EXTERN_STRING FilesListTableViewBaseCellIdentifier = @"FilesListTableViewBaseCellIdentifier";
_PCO_EXTERN_STRING FilesListTableViewBaseCellDownloadIdentifier = @"FilesListTableViewBaseCellDownloadIdentifier";
