//
//  LDGeminiNetwork+IPAddress.m
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import "LDGeminiNetwork+IPAddress.h"
#include <arpa/inet.h>
#include <ifaddrs.h>

@implementation LDGeminiNetwork (IPAddress)

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
    while(success && iter_addr != NULL) {
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
    struct in6_addr addr;
    success = inet_pton(AF_INET6, ip, &addr);

    return (success == 1);
}

@end
