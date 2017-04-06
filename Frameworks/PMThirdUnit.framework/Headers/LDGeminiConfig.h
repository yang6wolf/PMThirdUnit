//
//  LDGeminiConfig.h
//  LDGeminiSDK
//
//  Created by wangkaird on 2016/10/11.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDGeminiConfigAttributes.h"

NS_ASSUME_NONNULL_BEGIN
@interface LDGeminiConfig : NSObject

+ (instancetype)sharedConfig;
- (void)resetConfigs;
- (void)resetConfig:(NSString *)configName;
- (void)refreshConfig:(NSDictionary *)configs;  // 更新配置

/*
 * 当参数等出错时返回nil
 * 其他时候返回non-null的字符串
 */
- (nullable NSString *)getConfig:(NSString *)configName;
- (NSDictionary *)getAllConfigs;
- (NSArray *)getAllRequiredConfigNames;
- (NSArray *)getAllOptionalConfigNames;
- (NSArray *)getAllConfigNames;

@end
NS_ASSUME_NONNULL_END
