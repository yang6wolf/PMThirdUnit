//
//  LDGeminiNetwork.h
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/12.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LDGeminiNetworkReachabilityStatus) {
    LDGeminiNetworkReachabilityStatusUnknown            = -1,
    LDGeminiNetworkReachabilityStatusNotReachable       = 0,
    LDGeminiNetworkReachabilityStatusReachableViaWWAN   = 1,
    LDGeminiNetworkReachabilityStatusReachableViaWiFi   = 2,
};

typedef NS_ENUM(NSUInteger, LDGeminiNetworkStatus) {
    LDGeminiNetworkStatusUnknown  = 0,
    LDGeminiNetworkStatus2G       = 2,
    LDGeminiNetworkStatus3G       = 3,
    LDGeminiNetworkStatus4G       = 4,
    LDGeminiNetworkStatusWifi     = 9,
};

@interface LDGeminiNetwork : NSObject

+ (NSString *)IPAddress;
+ (BOOL)isIPAddress:(nullable NSString *)ip;
+ (BOOL)isIPv4Address:(nullable NSString *)ipv4;
+ (BOOL)isIPv6Address:(nullable NSString *)ipv6;
+ (LDGeminiNetworkStatus)networkStatus;
+ (LDGeminiNetworkReachabilityStatus)networkReachabilityStatus;


@end

NS_ASSUME_NONNULL_END
