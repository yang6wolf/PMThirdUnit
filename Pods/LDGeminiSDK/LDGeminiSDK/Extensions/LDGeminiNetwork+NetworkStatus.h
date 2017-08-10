//
//  LDGeminiNetwork+NetworkStatus.h
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import "LDGeminiNetwork.h"

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

@interface LDGeminiNetwork (NetworkStatus)

+ (LDGeminiNetworkStatus)networkStatus;
+ (LDGeminiNetworkReachabilityStatus)networkReachabilityStatus;

@end
