/*!
 * PROHEXColorStringNormalizer.m
 *
 *
 * Created by Skylar Schipper on 6/12/14
 */

#import "PROHEXColorStringNormalizer.h"

@interface PROHEXColorStringNormalizer ()

@end

@implementation PROHEXColorStringNormalizer

+ (NSString *)normalizeString:(NSString *)string {
    string = [[string stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    
    if (string.length == 0) {
        return @"000000";
    }
    
    if ([self isValidHexString:string]) {
        return string;
    }
    
    string = [self replaceInvalidHexCharacters:string];
    
    if ([self isValidHexString:string]) {
        return string;
    }
    
    string = [self fixHexStringLength:string];
    
    if ([self isValidHexString:string]) {
        return string;
    }
    
    return @"000000";
}

+ (BOOL)isValidHexString:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"^#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$" options:NSRegularExpressionAnchorsMatchLines error:&error];
        if (error) {
            NSLog(@"Failed to parse hex string: %@",error);
        }
    });
    NSUInteger matchCount = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, string.length)];
    return (matchCount == 1);
}

+ (NSString *)replaceInvalidHexCharacters:(NSString *)string {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:@"([^#a-fA-F0-9])" options:NSRegularExpressionAnchorsMatchLines error:&error];
        if (error) {
            NSLog(@"Failed to parse hex replace regex string: %@",error);
        }
    });
    return [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];
}

+ (NSString *)fixHexStringLength:(NSString *)string {
    if (string.length == 3 || string.length == 6) {
        return string;
    }
    
    if (string.length > 6) {
        return [string substringToIndex:6];
    }
    
    if (string.length == 1) {
        return [NSString stringWithFormat:@"%@%@%@%@%@%@",string,string,string,string,string,string];
    }
    
    if (string.length == 2) {
        return [NSString stringWithFormat:@"%@%@%@",string,string,string];
    }
    
    while (string.length < 6) {
        string = [NSString stringWithFormat:@"%@0",string];
    }
    
    return string;
}

+ (BOOL)getRed:(double_t *)red green:(double_t *)green blue:(double_t *)blue forString:(NSString *)string {
    NSString *hexString = [self normalizeString:string];
    
    if (hexString.length == 3) {
        NSString *tR = [hexString substringWithRange:NSMakeRange(0, 1)];
        NSString *tG = [hexString substringWithRange:NSMakeRange(1, 1)];
        NSString *tB = [hexString substringWithRange:NSMakeRange(2, 1)];
        hexString = [NSString stringWithFormat:@"%@%@%@%@%@%@",tR,tR,tG,tG,tB,tB];
    }
    
    if (hexString.length != 6) {
        return NO;
    }
    
    NSString *redString = [hexString substringWithRange:NSMakeRange(0, 2)];
    NSString *greenString = [hexString substringWithRange:NSMakeRange(2, 2)];
    NSString *blueString = [hexString substringWithRange:NSMakeRange(4, 2)];
    
    if (![[NSScanner scannerWithString:[NSString stringWithFormat:@"0x%@",redString]] scanHexDouble:red]) {
        return NO;
    }
    if (![[NSScanner scannerWithString:[NSString stringWithFormat:@"0x%@",greenString]] scanHexDouble:green]) {
        return NO;
    }
    if (![[NSScanner scannerWithString:[NSString stringWithFormat:@"0x%@",blueString]] scanHexDouble:blue]) {
        return NO;
    }
    
    return YES;
}

@end

#if TARGET_OS_IPHONE

@implementation PROHEXColorStringNormalizer (PROMobile)

+ (UIColor *)colorFromString:(NSString *)string {
    double_t red = 0.0;
    double_t green = 0.0;
    double_t blue = 0.0;
    
    if ([self getRed:&red green:&green blue:&blue forString:string]) {
        return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:1.0];
    }
    
    return [UIColor blackColor];
}

@end

#endif
