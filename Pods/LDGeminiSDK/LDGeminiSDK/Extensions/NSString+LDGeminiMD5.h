//
//  NSString+LDGeminiMD5.h
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/12.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LDGeminiMD5)

+ (NSString *)geminiMD5WithArray:(NSArray<NSString *> *)stringArray;
- (NSString *)geminiMD5;

@end

NS_ASSUME_NONNULL_END
