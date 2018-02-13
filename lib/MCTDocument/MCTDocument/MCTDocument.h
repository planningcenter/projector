//
//  MCTDocument.h
//  MCTDocument
//
//  Created by Skylar Schipper on 3/27/14.
//

#ifndef MCTDocument_MCTDocument_h
#define MCTDocument_MCTDocument_h

@import Foundation;
@import MobileCoreServices;
@import UIKit;
@protocol MCTDocumentParser;

#import "MCTDocumentSlide.h"

@interface MCTDocument : NSObject

#pragma mark -
#pragma mark - Meta
@property(nonatomic, assign, readonly) NSUInteger count;

#pragma mark -
#pragma mark - Initialization
- (instancetype)initWithFilePath:(NSString *)filePath;
@property(nonatomic, strong, readonly) NSString *filePath;

@property(nonatomic, strong, readonly) NSString *documentPath;
@property(nonatomic, strong, readonly) NSDictionary *userInfo;

#pragma mark -
#pragma mark - Parsing
@property(nonatomic, assign, readonly, getter=isParsing) BOOL parsing;
@property(nonatomic, strong, readonly) id<MCTDocumentParser> parser;

- (void)parseWithCompletion:(void (^)(MCTDocument *document, NSError *error))completion;
- (id<MCTDocumentParser>)newParserForFileWithMimeType:(NSString *)mimeType;
+ (NSString *)mimeTypeForExtention:(NSString *)extention;

+ (NSString *)documentsPath;

- (NSString *)MD5Checksum;

- (MCTDocumentSlide *)slideForIndex:(NSInteger)index;
- (MCTDocumentSlide *)newSlideForIndex:(NSInteger)index;

- (BOOL)isParsed;

@end

OBJC_EXTERN NSString *const MCTDocumentErrorDomain;
OBJC_EXTERN NSString *const kMCTDocumentInfoUUID;
OBJC_EXTERN NSString *const kMCTDocumentInfoCreated;
OBJC_EXTERN NSString *const kMCTDocumentSlidePath;
OBJC_EXTERN NSString *const kMCTDocumentSlideCount;
OBJC_EXTERN NSString *const kMCTDocumentMimeType;

@protocol MCTDocumentParser <NSObject>

@required
- (void)setTargetPath:(NSString *)targetPath;

- (void)parseHTML:(NSString *)HTML javascriptResults:(NSDictionary *)javascriptResults;

- (NSString *)textEncoding;
- (NSDictionary *)infoDictionary;

- (BOOL)writeToTargetPath:(NSError **)error;

- (NSInteger)count;

@optional
- (NSDictionary *)webViewJavaScript;

@end

#endif
