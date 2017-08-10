//
//  LDGeminiNetwork+IPAddress.h
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import "LDGeminiNetwork.h"

@interface LDGeminiNetwork (IPAddress)

+ (NSString *)IPAddress;

+ (BOOL)isIPAddress:(nullable NSString *)ip;

+ (BOOL)isIPv4Address:(nullable NSString *)ipv4;

+ (BOOL)isIPv6Address:(nullable NSString *)ipv6;

@end
