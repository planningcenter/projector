/*!
 * MCTDocumentParserHelper.m
 *
 * Created by Skylar Schipper on 3/28/14
 */

#import "MCTDocumentParserHelper.h"

@interface MCTDocumentParserHelper ()

@end

@implementation MCTDocumentParserHelper

+ (NSString *)fixWidth:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"width:\\s?(\\d+);" options:0 error:&error];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });
    return [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"width: $1px;"];
}
+ (NSString *)fixHeight:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"height:\\s?(\\d+);" options:0 error:nil];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });
    return [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"height: $1px;"];
}
+ (NSString *)fixTop:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"top:\\s?(\\d+);" options:0 error:nil];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });
    return [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"top: $1px;"];
}
+ (NSString *)fixLeft:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"left:\\s?(\\d+);" options:0 error:nil];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });
    return [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"left: $1px;"];
}
+ (NSString *)fixSize:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"size:\\s?(\\d+);" options:0 error:nil];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });
    return [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@"size: $1px;"];
}
+ (NSString *)fixTopOffset:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"<div\\s?class=\"slide\".*?(top:\\s?\\d+;).*?>" options:NSRegularExpressionAnchorsMatchLines error:&error];
        if (error) {
            NSLog(@"Regex Error: %@",error);
        }
    });

    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    if (result.range.location == NSNotFound) {
        return string;
    }

    if (result.numberOfRanges <= 1) {
        return string;
    }

    return [string stringByReplacingCharactersInRange:[result rangeAtIndex:1] withString:@""];
}

@end
