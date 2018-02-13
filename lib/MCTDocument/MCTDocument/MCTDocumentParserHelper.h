/*!
 * MCTDocumentParserHelper.h
 *
 * Created by Skylar Schipper on 3/28/14
 */

#ifndef MCTDocumentParserHelper_h
#define MCTDocumentParserHelper_h

#import <Foundation/Foundation.h>

@interface MCTDocumentParserHelper : NSObject

+ (NSString *)fixWidth:(NSString *)string;
+ (NSString *)fixHeight:(NSString *)string;
+ (NSString *)fixTop:(NSString *)string;
+ (NSString *)fixLeft:(NSString *)string;
+ (NSString *)fixSize:(NSString *)string;
+ (NSString *)fixTopOffset:(NSString *)string;

@end

#endif
