//
//  LDGeminiNetwork+NetworkStatus.m
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import "LDGeminiNetwork+NetworkStatus.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netdb.h>

@implementation LDGeminiNetwork (NetworkStatus)

+ (LDGeminiNetworkStatus)networkStatus {
    static NSArray *radio2G = nil;
    static NSArray *radio3G = nil;
    static NSArray *radio4G = nil;
    if (!radio2G) {
        radio2G = @[
                    CTRadioAccessTechnologyGPRS,    // 处于2G 和 3G之间，2.5G
                    CTRadioAccessTechnologyEdge,    // 2.75G
                    CTRadioAccessTechnologyCDMA1x,
                    ];
    }
    if (!radio3G) {
        radio3G = @[
                    CTRadioAccessTechnologyWCDMA,   // 3G，日本、欧洲
                    CTRadioAccessTechnologyHSDPA,   // 3.5G
                    CTRadioAccessTechnologyHSUPA,   // 3.75G
                    CTRadioAccessTechnologyCDMAEVDORev0,
                    CTRadioAccessTechnologyCDMAEVDORevA,
                    CTRadioAccessTechnologyCDMAEVDORevB,
                    CTRadioAccessTechnologyeHRPD,
                    ];
    }
    if (!radio4G) {
        radio4G = @[CTRadioAccessTechnologyLTE];
    }
    LDGeminiNetworkStatus status = LDGeminiNetworkStatusUnknown;
    LDGeminiNetworkReachabilityStatus reachability = [self networkReachabilityStatus];
    switch (reachability) {
        case LDGeminiNetworkReachabilityStatusUnknown:
        case LDGeminiNetworkReachabilityStatusNotReachable:
            break;
        case LDGeminiNetworkReachabilityStatusReachableViaWWAN:
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                break;
            }
            CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = networkInfo.currentRadioAccessTechnology;
            if (currentStatus.length <= 0) {
                break;
            }
            if ([radio2G containsObject:currentStatus]) {
                status = LDGeminiNetworkStatus2G;
            } else if ([radio3G containsObject:currentStatus]) {
                status = LDGeminiNetworkStatus3G;
            } else if ([radio4G containsObject:currentStatus]) {
                status = LDGeminiNetworkStatus4G;
            }
        }
            break;
        case LDGeminiNetworkReachabilityStatusReachableViaWiFi:
            status = LDGeminiNetworkStatusWifi;
            break;
        default:
            break;
    }

    return status;
}

+ (LDGeminiNetworkReachabilityStatus)networkReachabilityStatus {
    //创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;

    BOOL success = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    LDGeminiNetworkReachabilityStatus status = LDGeminiNetworkReachabilityStatusUnknown;
    if (!success) {
        return status;
    }

    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));

    if (isNetworkReachable == NO) {
        status = LDGeminiNetworkReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = LDGeminiNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = LDGeminiNetworkReachabilityStatusReachableViaWiFi;
    }

    return status;
}

@end
