//
//  NSString+LDGeminiMD5.m
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/12.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "NSString+LDGeminiMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LDGeminiMD5)

+ (NSString *)geminiMD5WithArray:(NSArray<NSString *> *)stringArray {
    NSString *md5 = @"";

    NSMutableString *toMd5String = [[NSMutableString alloc] initWithString:@""];
    for (NSString *string in stringArray) {
        if (![string isKindOfClass:[NSString class]]) {
            continue;
        }
        [toMd5String appendString:string];
    }
    md5 = [toMd5String geminiMD5];

    return md5 ? : @"";
}

- (NSString *)geminiMD5 {
    const char* originalString = [self UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16

    CC_MD5(originalString, (uint)strlen(originalString), digist);
    NSMutableString* outPutString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];

    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutString appendFormat:@"%02x", digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }

    return [outPutString lowercaseString];
}

@end
