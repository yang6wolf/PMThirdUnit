//
//  UIDevice+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/19/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (NLDEventCollection)

/**
 *  IDFA
 */
- (NSString *)NLD_idfa;

/**
 *  Gets the device model string.
 *  @return A platform string identifying the device
 */
- (NSString *)NLD_deviceModel;

/**
 *  物理屏幕分辨率
 */
- (NSString *)NLD_screenResolution;

/**
 *  内存总量，单位MB，精确到Byte
 *  @return double，如果获取失败返回-1
 */
- (double)NLD_totalMemorySize;

/**
 *  内存总量，单位MB，精确到小数点后两位
 *  @return @"xxx MB"，如果获取失败，返回@""
 */
- (NSString *)NLD_totalMemorySizeString;

/**
 *  当前内存剩余量，单位MB，精确到Byte
 *  @return double，如果获取失败返回-1
 */
- (double)NLD_availableMemorySize;

/**
 *  当前内存剩余量，单位MB，精确到小数点后两位
 *  @return @"xxx MB"，如果获取失败，返回@""
 */
- (NSString *)NLD_availableMemorySizeString;

/**
 *  当前App物理内存占用量(不包括虚拟内存)，单位MB，精确到Byte
 *  @return double，如果获取失败返回-1
 */
- (double)NLD_currentAppMemorySize;

/**
 *  当前App物理内存占用量(不包括虚拟内存)，单位MB，精确到小数点后两位
 *  @return @"xxx MB"，如果获取失败，返回@""
 */
- (NSString *)NLD_currentAppMemorySizeString;

/**
 *  当前磁盘空间剩余量，单位MB，精确到Byte
 *  @return double，如果获取失败返回-1
 */
- (double)NLD_availableDiskSize;

/**
 *  当前磁盘空间剩余量，单位MB，精确到小数点后两位
 *  @return @"xxx MB"，如果获取失败，返回@""
 */
- (NSString *)NLD_availableDiskSizeString;

/**
 *  磁盘空间总量，单位MB，精确到Byte
 *  @return double，如果获取失败返回-1
 */
- (double)NLD_totalDiskSize;

/**
 *  磁盘空间总量，单位MB，精确到小数点后两位
 *  @return @"xxx MB"，如果获取失败，返回@""
 */
- (NSString *)NLD_totalDiskSizeString;

/**
 *  当前电量，0.0~1.0，1.0为满电状态
 *  @return double，如果获取失败返回-1
 */
- (CGFloat)NLD_batteryLevel;

/**
 *  当前电量百分比
 *  @return @"xx%"，如果获取失败，返回@""
 */
- (NSString *)NLD_batteryLevelString;

/**
 *  当前运营商
 *  @return @"中国移动"，如果获取失败，返回@""
 */
- (NSString *)NLD_carrier;

@end

NS_ASSUME_NONNULL_END
