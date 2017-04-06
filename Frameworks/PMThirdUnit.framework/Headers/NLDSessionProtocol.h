//
//  NLDSessionProtocol.h
//  LDEventCollection
//
//  Created by SongLi on 5/17/16.
//  Copyright © 2016 netease. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NLDSession <NSObject>

#pragma mark - 设备信息

/// Device idfa
@property (nonatomic, strong) NSString *idfa;
/// 设备model
@property (nonatomic, strong) NSString *deviceModel;
/// 屏幕分辨率
@property (nonatomic, strong) NSString *screenResolution;
/// 总内存
@property (nonatomic, strong) NSString *totalMemory;
/// 剩余内存
@property (nonatomic, strong) NSString *avalibleMemory;
/// 此App占用内存
@property (nonatomic, strong) NSString *appMemory;
/// 总磁盘
@property (nonatomic, strong) NSString *totalDisk;
/// 剩余磁盘
@property (nonatomic, strong) NSString *avalibleDisk;
/// 电量
@property (nonatomic, strong) NSString *batteryLevel;
/// 运营商
@property (nonatomic, strong) NSString *carrier;


#pragma mark - 系统信息

/// System Name
@property (nonatomic, strong) NSString *systemName;

/// System Version
@property (nonatomic, strong) NSString *systemVersion;


#pragma mark - App信息

/// CFBundleIdentifier
@property (nonatomic, strong) NSString *appBundle;
/// CFBundleShortVersionString
@property (nonatomic, strong) NSString *appVersion;
/// CFBundleVersion
@property (nonatomic, strong) NSString *appBuildVersion;
/// 渠道号
@property (nonatomic, strong) NSString *channel;
/// 自定义device标识
@property (nonatomic, strong) NSString *deviceId;

@end

NS_ASSUME_NONNULL_END
