/*!
 * FilesListTableViewBaseCell.h
 *
 *
 * Created by Skylar Schipper on 8/5/14
 */

#ifndef FilesListTableViewBaseCell_h
#define FilesListTableViewBaseCell_h

#import "PROSlideDeleteTableViewCell.h"

@interface FilesListTableViewBaseCell : PROSlideDeleteTableViewCell

@property (nonatomic) uint64_t identifier;

@property (nonatomic) CGFloat progress;

@end

PCO_EXTERN_STRING FilesListTableViewBaseCellIdentifier;
PCO_EXTERN_STRING FilesListTableViewBaseCellDownloadIdentifier;

#endif
