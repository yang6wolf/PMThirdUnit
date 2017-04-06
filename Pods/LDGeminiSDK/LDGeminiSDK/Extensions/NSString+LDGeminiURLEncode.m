//
//  NSString+LDGeminiURLEncode.m
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/13.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "NSString+LDGeminiURLEncode.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LDGeminiURLEncode)

- (NSString *)geminiURLEncodedString {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

- (NSString *)geminiURLDecodedString {
    return [self stringByRemovingPercentEncoding];
}


@end
