//
//  UIDevice(Identifier).m
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import "UIDevice+IdentifierAddition.h"
#import "NSString+Additions.h"
#import "KeychainWrapper.h"

#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <AdSupport/AdSupport.h>

@interface UIDevice (Private)

- (NSString *)macaddress;

@end

@implementation UIDevice (IdentifierAddition)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *)macaddress
{

    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;

    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }

    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }

    ifm = (struct if_msghdr *) buf;
    sdl = (struct sockaddr_dl *) (ifm + 1);
    ptr = (unsigned char *) LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                                     *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    free(buf);

    return outstring;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (NSString *)randomDeviceId
{
    srandom([[NSDate date] timeIntervalSince1970]);
    NSString *uniqueId = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", (Byte) random(), (Byte) random(), (Byte) random(), (Byte) random(), (Byte) random(), (Byte) random()];
    return uniqueId;
}

- (NSString *)macDeviceIdentifier
{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *uniqueIdentifier = [macaddress md5String];
    return uniqueIdentifier ? uniqueIdentifier : @""; /* 部分黑苹果没有en0，此时返回 @“”*/
}


/*
 新设备ID
 iOS6+ [UIDevice identifierForVendor];
 iOS5  [mac md5];
 */
- (NSString *)deviceId
{
    static NSString *deviceId;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceId = [KeychainWrapper keychainStringFromMatchingIdentifier:@"DeviceId"];
        if (!deviceId) {
            if ([self respondsToSelector:@selector(identifierForVendor)]) {
                deviceId = [[self identifierForVendor] UUIDString];
            } else {
                deviceId = [self macDeviceIdentifier];
            }

            if (deviceId) {
                [KeychainWrapper createKeychainValue:deviceId forIdentifier:@"DeviceId"];
            } else {
                NSAssert(0, @"Device ID not found");
                deviceId = [self randomDeviceId];
            }
        }
    });
    return deviceId;
}

- (void)removeKeychainDeviceId
{
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"DeviceId"];
}

/*
 老设备ID
 iOS7 nil
 iOS6 [mac md5];
 iOS5 nil
 */
- (NSString *)oldDeviceId
{
    NSString *version = [UIDevice currentDevice].systemVersion;
    NSInteger osMainVersion = version.integerValue;
    if (osMainVersion == 6) {
        return [self macDeviceIdentifier];
    }
    return nil;
}

//渠道统计用，iOS7以下使用mac地址，iOS7以上使用IDFA,返回值有可能为nil
- (NSString *)macOrAdvertisingId
{
    if ([[self systemVersion] floatValue] >= 7.0) {
        return [self getIDFA];
    } else {
        return [self getMACString];
    }
}

- (NSString *)getIDFA
{
    Class class = NSClassFromString(@"ASIdentifierManager");
    if (class) {
        NSString *IDFAString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return IDFAString;
    } else {
        return nil;
    }
}

- (NSString *)getMACString
{
    NSString *macaddress = [self macaddress];
    //从iOS7及更高版本往后，如果你向ios设备请求获取mac地址，系统将返回一个固定值“02:00:00:00:00:00”
    if (macaddress && ![macaddress isEqualToString:@"02:00:00:00:00:00"]) {
        return [macaddress stringByReplacingOccurrencesOfString:@":" withString:@""];
    } else {
        return nil;
    }
}
@end
