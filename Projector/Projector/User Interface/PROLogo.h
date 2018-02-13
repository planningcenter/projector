/*!
 * PROLogo.h
 *
 *
 * Created by Skylar Schipper on 6/26/14
 */

#ifndef PROLogo_h
#define PROLogo_h

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, PROLogoThumbnailGenerator) {
    PROLogoThumbnailGeneratorUseFile = 0,
    PROLogoThumbnailGeneratorVideo   = 1,
};

@interface PROLogo : NSObject

@property (nonatomic, strong, readonly) NSString *UUID;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSDate *addedDate;
@property (nonatomic, strong) NSString *attachmentID;
@property (nonatomic, strong) NSNumber *mediaID;
@property (nonatomic, strong) NSString *localizedName;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSString *mimeType;

- (NSURL *)fileURL;
- (NSURL *)fileThumbnailURL;

- (void)loadWithCompletion:(void(^)(NSData *, NSError *))completion;
- (void)loadThumbnailWithCompletion:(void(^)(UIImage *, NSError *))completion;

- (BOOL)destroy:(NSError **)error;

- (BOOL)save:(NSError **)error;
- (BOOL)saveWithData:(NSData *)data error:(NSError **)error;
- (BOOL)saveWithFile:(NSURL *)fileURL error:(NSError **)error;

- (BOOL)fileExists:(NSError **)error;

+ (NSString *)logoFilePath;
+ (NSArray *)allLogos;
+ (void)clear;

+ (PROLogo *)logoForUUID:(NSString *)UUID;

@property (nonatomic, strong, readonly) NSProgress *progress;
- (void)downloadFileFromURL:(NSURL *)URL mimeType:(NSString *)mimeType thumbnailGenerator:(PROLogoThumbnailGenerator)generator;

- (void)cancelDownload;
- (BOOL)finishFileDownloadIfNeeded;

@end

PCO_EXTERN_STRING PROLogoErrorDomain;

PCO_EXTERN_STRING PROLogoDownloadProgressUpdatedNotification;
PCO_EXTERN_STRING PROLogoDownloadProgressCompletedNotification;
PCO_EXTERN_STRING PROLogoThubnailGenerationCompletedNotification;

#endif
