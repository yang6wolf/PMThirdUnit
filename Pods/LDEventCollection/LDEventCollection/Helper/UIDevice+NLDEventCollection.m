//
//  UIDevice+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/19/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIDevice+NLDEventCollection.h"
#import <AdSupport/AdSupport.h>
#import <sys/sysctl.h>
#import <sys/statvfs.h>
#import <mach/mach.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation UIDevice (NLDEventCollection)

- (NSString *)NLD_idfa
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

- (NSString *)NLD_deviceModel
{
    // SDK的方法渠道的信息有限，使用新的方法，可以区分iphone4[iPhone3,1]和iphone4s[iPhone4,1]
    // return [[UIDevice currentDevice] model];
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform ?: @"";
}

- (NSString *)NLD_screenResolution
{
    CGFloat scale_screen = [[UIScreen mainScreen] scale];
    CGSize size_screen = [[UIScreen mainScreen] bounds].size;
    NSInteger w = (NSInteger)(size_screen.width) * (NSInteger)scale_screen;
    NSInteger h = (NSInteger)(size_screen.height) * (NSInteger)scale_screen;
    
    return [NSString stringWithFormat:@"%ld*%ld", (long)w, (long)h];
}

- (double)NLD_totalMemorySize
{
    return [NSProcessInfo processInfo].physicalMemory / 1024.0 / 1024.0;
}

- (NSString *)NLD_totalMemorySizeString
{
    double size = [self NLD_totalMemorySize];
    if (size < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%.2f MB", size];
}

- (double)NLD_availableMemorySize
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    
    if (kernReturn == KERN_SUCCESS) {
        return (vm_page_size * (vmStats.free_count + vmStats.inactive_count)) / 1024.0 / 1024.0;
    } else {
        return -1;
    }
}

- (NSString *)NLD_availableMemorySizeString
{
    double size = [self NLD_availableMemorySize];
    if (size < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%.2f MB", size];
}

- (double)NLD_currentAppMemorySize
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);
    
    if (kernReturn == KERN_SUCCESS) {
        return taskInfo.resident_size / 1024.0 / 1024.0;
    } else {
        return -1;
    }
}

- (NSString *)NLD_currentAppMemorySizeString
{
    double size = [self NLD_currentAppMemorySize];
    if (size < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%.2f MB", size];
}

- (double)NLD_availableDiskSize
{
    struct statvfs buf;
    unsigned long long freeSpace = -1;
    if (statvfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_frsize * buf.f_bavail);
        return freeSpace / 1024.0 / 1024.0;
    } else {
        return -1;
    }
//    long long freeSpace2 = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
}

- (NSString *)NLD_availableDiskSizeString
{
    double size = [self NLD_availableDiskSize];
    if (size < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%.2f MB", size];
}

- (double)NLD_totalDiskSize
{
    struct statvfs buf;
    unsigned long long freeSpace = -1;
    if (statvfs("/var", &buf) >= 0) {
        freeSpace = (unsigned long long)(buf.f_frsize * buf.f_blocks);
        return freeSpace / 1024.0 / 1024.0;
    } else {
        return -1;
    }
//    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
}

- (NSString *)NLD_totalDiskSizeString
{
    double size = [self NLD_totalDiskSize];
    if (size < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%.2f MB", size];
}

- (CGFloat)NLD_batteryLevel
{
    return [self batteryLevel];
}

- (NSString *)NLD_batteryLevelString
{
    CGFloat batteryLevel = [self NLD_batteryLevel];
    if (batteryLevel < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%ld%%", (long)(batteryLevel * 100)];
}

- (NSString *)NLD_carrier
{
    CTCarrier *carrier = [[CTTelephonyNetworkInfo new] subscriberCellularProvider];
    return [carrier carrierName].copy ?: @"";
}

@end
