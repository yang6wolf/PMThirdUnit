//
//  LDGeminiNetwork.h
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/12.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDGeminiNetworkResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GeminiNetworkCompletion)(LDGeminiNetworkResponse *response);

@interface LDGeminiNetwork : NSObject

+ (void)requestDataWithUrl:(NSString *)urlString
                parameters:(nullable NSDictionary<NSString *, id> *)parameters
         completionHandler:(GeminiNetworkCompletion)completion;

+ (LDGeminiNetworkResponse *)syncRequestDataWithUrl:(NSString *)urlString
                                         parameters:(nullable NSDictionary<NSString *, id> *)parameters
                                            timeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
