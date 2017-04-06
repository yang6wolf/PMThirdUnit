//
//  LDGeminiService.h
//  LDGeminiSDK
//
//  Created by wangkaird on 2016/10/11.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LDGeminiConfig;
typedef void(^LDGeminiServiceHandler)(NSArray  * _Nullable array, NSError * _Nullable error);

@interface LDGeminiService : NSObject

/**
 *  handler不能为nil，否则直接返回
 */
+ (void)fetchCaseListWithConfig:(LDGeminiConfig *)config Completion:(LDGeminiServiceHandler)handler;

/**
 *  !! error不能为nil，否则将直接返回nil。
 */
+ (nullable NSArray *)syncFetchCaseListWithConfig:(LDGeminiConfig *)config timeout:(NSTimeInterval)timeout error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
