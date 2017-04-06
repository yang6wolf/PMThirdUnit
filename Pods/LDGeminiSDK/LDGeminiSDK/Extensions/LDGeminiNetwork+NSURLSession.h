//
//  LDGeminiNetwork+NSURLSession.h
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/13.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "LDGeminiNetwork.h"

NS_ASSUME_NONNULL_BEGIN
@class LDGeminiNetworkResponse;
typedef void(^GeminiNetworkCompletion)(LDGeminiNetworkResponse *response);

@interface LDGeminiNetworkResponse : NSObject

@property (nonatomic, strong, nullable) NSData *data;
@property (nonatomic, strong, nullable) NSURLResponse *response;
@property (nonatomic, strong, nullable) NSError *error;

- (instancetype)initWithData:(nullable NSData *)data
                 URLResponse:(nullable NSURLResponse *)response
                       error:(nullable NSError *)error;

@end

@interface LDGeminiNetwork (NSURLSession)

+ (void)requestDataWithUrl:(NSString *)urlString
                parameters:(nullable NSDictionary<NSString *, id> *)parameters
         completionHandler:(GeminiNetworkCompletion)completion;

+ (LDGeminiNetworkResponse *)syncRequestDataWithUrl:(NSString *)urlString
                                         parameters:(nullable NSDictionary<NSString *, id> *)parameters
                                            timeout:(NSTimeInterval)timeout;

@end
NS_ASSUME_NONNULL_END
