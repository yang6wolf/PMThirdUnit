//
//  NSString+NLDAddition.m
//  LDEventCollection
//
//  Created by SongLi on 6/2/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSString+NLDAddition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NLDAddition)

- (NSString *)NLD_md5String
{
    if ([self length] == 0) {
        return nil;
    }
    
    const char *value = self.UTF8String;
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }
    return outputString.copy;
}

+ (nullable NSString *)NLD_RandomUUIDString
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return uuidString;
}

- (nonnull NSString *)NLD_removeSwiftModule
{
    if ([self rangeOfString:@"."].location != NSNotFound) {
        NSArray *stringComponents = [self componentsSeparatedByString:@"."];
        if (stringComponents.count == 2) {
            return stringComponents[1];
        }
    }
    
    return self;
}

@end
