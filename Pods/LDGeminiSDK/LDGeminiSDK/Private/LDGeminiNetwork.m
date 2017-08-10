//
//  LDGeminiNetwork.m
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/12.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "LDGeminiNetwork.h"
#import "NSString+LDGeminiURLEncode.h"
#import "LDGeminiMacro.h"

@implementation LDGeminiNetwork


+ (void)requestDataWithUrl:(NSString *)urlString
                parameters:(NSDictionary<NSString *, id> *)parameters
         completionHandler:(GeminiNetworkCompletion)completion {
    LDGeminiNetworkResponse *realResponse = [[LDGeminiNetworkResponse alloc] initWithData:nil URLResponse:nil error:nil];
    NSURL *url = nil;

    if (urlString.length > 0) {
        NSString *queryString = [self iURLQueryStringWithParameters:parameters];
        NSString *realUrlString = [urlString stringByAppendingFormat:@"%@%@", (queryString.length > 0 ? @"?" : @""), queryString];
        url = [NSURL URLWithString:realUrlString];
    }
    if (!url) {
        NSError *error = [NSError errorWithDomain:LDGeminiSDKDomain
                                             code:22
                                         userInfo:@{NSLocalizedDescriptionKey : @"不合法的参数"}];
        realResponse.error = error;
        completion(realResponse);
        return;
    }

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        realResponse.data = data;
        realResponse.response = response;
        realResponse.error = error;
        completion(realResponse);
    }] resume];
}

+ (LDGeminiNetworkResponse *)syncRequestDataWithUrl:(NSString *)urlString
                                         parameters:(NSDictionary<NSString *, id> *)parameters
                                            timeout:(NSTimeInterval)timeout {
    LDGeminiNetworkResponse *realResponse = [[LDGeminiNetworkResponse alloc] initWithData:nil URLResponse:nil error:nil];
    NSURL *url = nil;

    if (urlString.length > 0) {
        NSString *queryString = [self iURLQueryStringWithParameters:parameters];
        NSString *realUrlString = [urlString stringByAppendingFormat:@"%@%@", (queryString.length > 0 ? @"?" : @""), queryString];
        url = [NSURL URLWithString:realUrlString];
    }

    if (!url) {
        NSError *error = [NSError errorWithDomain:LDGeminiSDKDomain
                                             code:22
                                         userInfo:@{NSLocalizedDescriptionKey : @"不合法的参数"}];
        realResponse.error = error;
        return realResponse;
    }

    NSTimeInterval realTimeout = timeout * 1000000; // 毫秒 => 纳秒
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        realResponse.data = data;
        realResponse.response = response;
        realResponse.error = error;
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, realTimeout));

    return realResponse;
}

+ (NSString *)iURLQueryStringWithParameters:(NSDictionary<NSString *, id> *)parameters {
    NSMutableString *queryString = [[NSMutableString alloc] initWithString:@""];
    NSDictionary *dictionary = [parameters copy];
    NSArray *allKeys = [dictionary allKeys];
    BOOL firstKeyValue = YES;

    for (NSString *key in allKeys) {
        id value = dictionary[key];
        NSString *valueString = nil;
        if ([value isKindOfClass:[NSString class]]) {
            valueString = value;
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            valueString = [self iURLQueryStringWithParameters:value];
        } else if ([value respondsToSelector:@selector(stringValue)]) {
            valueString = [value stringValue];
        } else if ([value respondsToSelector:@selector(description)]) {
            valueString = [value description];
        }
        if (valueString.length > 0) {
            [queryString appendFormat:@"%@%@=%@", firstKeyValue ? @"" : @"&", key, [valueString geminiURLEncodedString]];
        } else {
            [queryString appendFormat:@"%@%@", firstKeyValue ? @"" : @"&", key];
        }

        firstKeyValue = NO;
    }
    return [queryString copy];
}

@end

