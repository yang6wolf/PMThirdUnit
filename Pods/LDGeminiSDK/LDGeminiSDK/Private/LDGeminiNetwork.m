//
//  LDGeminiNetwork.m
//  LDGeminiSDKiOS
//
//  Created by wangkaird on 2016/10/12.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "LDGeminiNetwork.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <UIKit/UIKit.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <netdb.h>

@implementation LDGeminiNetwork

#pragma mark - IP
+ (NSString *)IPAddress {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *iter_addr = NULL;
    struct ifaddrs *current_addr = NULL;
    char addr[INET6_ADDRSTRLEN + 1];
    int success = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);

    // Loop through linked list of interfaces
    iter_addr = interfaces;
    while(success &&
          iter_addr != NULL) {
        current_addr = iter_addr;
        iter_addr = current_addr->ifa_next;

        if (!current_addr->ifa_addr) {
            continue;
        }

        if(![[NSString stringWithUTF8String:current_addr->ifa_name] isEqualToString:@"en0"]) {
            continue;
        }

        if (current_addr->ifa_addr->sa_family == AF_INET) {
            // ipv4 address
            struct sockaddr_in *in4 = (struct sockaddr_in*) current_addr->ifa_addr;
            address = [NSString stringWithUTF8String:inet_ntop(AF_INET, &in4->sin_addr, addr, sizeof(addr))];
            break;
        } else if (current_addr->ifa_addr->sa_family == AF_INET6) {
            // ipv6 address
            struct sockaddr_in6 *in6 = (struct sockaddr_in6*) current_addr->ifa_addr;
            address = [NSString stringWithUTF8String:inet_ntop(AF_INET6, &in6->sin6_addr, addr, sizeof(addr))];
            break;
        }
    }

    if (interfaces) {
        freeifaddrs(interfaces);
    }
    return address;
}

+ (BOOL)isIPAddress:(NSString *)ip {
    return [self isIPv4Address:ip] || [self isIPv6Address:ip];
}

+ (BOOL)isIPv4Address:(NSString *)ipv4 {
    if (ipv4.length <= 0) {
        return NO;
    }

    const char *ip = [ipv4 UTF8String];
    int success = 0;
    struct in_addr addr;
    success = inet_pton(AF_INET, ip, &addr);

    return (success == 1);
}

+ (BOOL)isIPv6Address:(NSString *)ipv6 {
    if (ipv6.length <= 0) {
        return NO;
    }

    const char *ip = [ipv6 UTF8String];
    int success = 0;
    struct in_addr addr;
    success = inet_pton(AF_INET6, ip, &addr);
    
    return (success == 1);
}

#pragma mark - Network Status
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

















