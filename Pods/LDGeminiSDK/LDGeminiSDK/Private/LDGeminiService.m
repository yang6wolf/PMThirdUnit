//
//  LDGeminiService.m
//  LDGeminiSDK
//
//  Created by wangkaird on 2016/10/11.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "LDGeminiService.h"
#import "LDGeminiCase.h"
#import "LDGeminiConfig.h"
#import "LDGeminiNetwork+NSURLSession.h"
#import "LDGeminiCase.h"
#import "LDGeminiMacro.h"

static NSString * const kQueryUserCaseListUrl = @"http://adc.163.com/ab/interface/case/queryUserCaseList";

@implementation LDGeminiService

+ (void)fetchCaseListWithConfig:(LDGeminiConfig *)config Completion:(LDGeminiServiceHandler)handler {
    if (!handler) {
        return ;
    }
    if (!config) {
        NSError *confError = [NSError errorWithDomain:LDGeminiSDKDomain
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey : @"LDGeminiSDK配置错误"}];
        handler(nil, confError);
        return;
    }
    NSDictionary *parameters = [self iAssembleParameterWithConf:config];
    [LDGeminiNetwork requestDataWithUrl:[self iQueryUserCaseListURLString] parameters:parameters completionHandler:^(LDGeminiNetworkResponse * _Nonnull response) {
        if (response.error || response.data.length <= 0) {
            handler(nil, response.error);
            return ;
        }
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response.data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if (!dict) {
            handler(nil, error);
            return ;
        }

        NSInteger retCode = [dict[@"retCode"] integerValue];
        if (retCode != 200) {
            // 401: 缺少参数 402: 参数有误 403: 签名错误 404: 系统错误 500: 内部错误
            handler(nil, response.error);
            LDGeminiLog(@"%s retCode: %ld.", __func__, (long)retCode);
            return ;
        }

        NSArray *result = dict[@"result"];
        if (![result isKindOfClass:[NSArray class]]) {
            NSError *resultError = [NSError errorWithDomain:LDGeminiSDKDomain
                                                       code:-1
                                                   userInfo:@{NSLocalizedDescriptionKey : @"返回数据格式有误！"}];
            handler(nil, resultError);
            return ;
        }

        handler([LDGeminiCase createWithArray:[result copy]], nil);
    }];
}

+ (NSArray *)syncFetchCaseListWithConfig:(LDGeminiConfig *)config timeout:(NSTimeInterval)timeout error:(NSError * _Nullable __autoreleasing *)error {
    if (!error) {
        return nil;
    }
    if (!config) {
        NSError *confError = [NSError errorWithDomain:LDGeminiSDKDomain
                                                 code:-1
                                             userInfo:@{NSLocalizedDescriptionKey : @"LDGeminiSDK配置错误"}];
        *error = confError;
        return nil;
    }
    NSDictionary *parameters = [self iAssembleParameterWithConf:config];
    
    LDGeminiNetworkResponse *response = nil;
    response = [LDGeminiNetwork syncRequestDataWithUrl:[self iQueryUserCaseListURLString] parameters:parameters timeout:timeout];

    if (response.error || response.data.length <= 0) {
        *error = response.error;
        return nil;
    }
    NSError *jsonError = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response.data
                                                         options:NSJSONReadingAllowFragments
                                                           error:&jsonError];
    if (!dict) {
        *error = jsonError;
        return nil;
    }

    NSInteger retCode = [dict[@"retCode"] integerValue];
    if (retCode != 200) {
        // 401: 缺少参数 402: 参数有误 403: 签名错误 404: 系统错误 500: 内部错误
        *error = response.error;
        LDGeminiLog(@"%s retCode: %ld.", __func__, (long)retCode);
        return nil;
    }

    NSArray *result = dict[@"result"];
    if (![result isKindOfClass:[NSArray class]]) {
        NSError *resultError = [NSError errorWithDomain:LDGeminiSDKDomain
                                                   code:-1
                                               userInfo:@{NSLocalizedDescriptionKey : @"返回数据格式有误！"}];
        *error = resultError;
        return nil;
    }

    *error = nil;
    return [LDGeminiCase createWithArray:[result copy]];
}

+ (NSDictionary *)iAssembleParameterWithConf:(LDGeminiConfig *)conf {
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
    if (!conf) {
        return @{};
    }
    NSDictionary *map = [self iMapofConfigAttribute];
    NSArray *keys = [conf getAllConfigNames];
    NSString *parameterKey = nil;
    for (NSString *key in keys) {
        parameterKey = map[key];
        if (parameterKey.length <= 0) {
            continue;
        }
        parameter[parameterKey] = [conf getConfig:key];
    }

    return [parameter copy];
}

+ (NSDictionary *)iMapofConfigAttribute {
    static NSDictionary *map = nil;
    if (!map) {
        map = @{
                LDGeminiAppKeyConfigAttributeName : @"productFlag",
                LDGeminiUserIdConfigAttributeName : @"userId",
                LDGeminiTimeStampConfigAttributeName : @"timestamp",
                LDGeminiDeviceIDConfigAttributeName : @"deviceId",
                LDGeminiSignConfigAttributeName : @"sign",

                LDGeminiAccessIPConfigAttributeName : @"accessIp",
                LDGeminiNetTypeConfigAttributeName : @"netType",
                LDGeminiDeviceTypeConfigAttributeName : @"deviceType",
                };
    }
    return map;
}

+ (NSString *)iQueryUserCaseListURLString {
    return kQueryUserCaseListUrl;
}

@end
