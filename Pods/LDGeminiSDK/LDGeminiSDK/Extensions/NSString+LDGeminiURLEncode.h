//
//  NSString+LDGeminiURLEncode.h
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/13.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LDGeminiURLEncode)

- (nullable NSString *)geminiURLEncodedString;
- (nullable NSString *)geminiURLDecodedString;

@end
