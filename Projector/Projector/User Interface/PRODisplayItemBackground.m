/*!
 * PRODisplayItemBackground.m
 *
 *
 * Created by Skylar Schipper on 7/15/14
 */

#import "PRODisplayItemBackground.h"
#import "OSDCrypto.h"

@interface PRODisplayItemBackground ()

@end

@implementation PRODisplayItemBackground

- (instancetype)init {
    self = [super init];
    if (self) {
        self.forceBackgroundRefresh = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Not sure if this will fix the cache:willEvictObject: but this is the only place where our code is executing.
// So here's to hoping.
- (void)dealloc {
    _staticBackgroundImage = nil;
}

- (UIImage *)staticBackgroundImage {
    if (!_staticBackgroundImage && self.staticBackgroundURL) {
        _staticBackgroundImage = [UIImage imageWithContentsOfFile:[self.staticBackgroundURL path]];
    }
    return _staticBackgroundImage;
}

- (NSString *)primaryURLHash {
    if (self.primaryBackgroundURL) {
        return [OSDCrypto MD5Data:[[self.primaryBackgroundURL absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (self.staticBackgroundURL) {
        return [OSDCrypto MD5Data:[[self.staticBackgroundURL absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return nil;
}

- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: %p",NSStringFromClass(self.class),self];
    
    [string appendFormat:@" color: (%@)",self.backgroundColor];
    [string appendFormat:@" URL: %@",self.primaryBackgroundURL];
    [string appendFormat:@" STAT: %@",self.staticBackgroundURL];
    [string appendFormat:@" force: %i",[self shouldForceBackgroundRefresh]];
    
    return [string stringByAppendingString:@" >"];
}

@end
