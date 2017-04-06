//
//  UIDevice(Identifier).h
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//  设备ID、IDFA标志、mac地址

#import <Foundation/Foundation.h>


@interface UIDevice (IdentifierAddition)

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates a hash from the MAC-address in combination with the bundle identifier
 * of your app.
 */

//- (NSString *) uniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. as example a advertising network will use this method to track the device
 * from different apps.
 * It generates a hash from the MAC-address only.
 */

//- (NSString *) uniqueGlobalDeviceIdentifier;

/*
    新设备ID
    iOS6+ [UIDevice identifierForVendor];
    iOS5  [mac md5];
 */
- (NSString *)deviceId;

/*
    老设备ID
    iOS7 nil
    iOS6 [mac md5];
    iOS5 nil
 */
- (NSString *)oldDeviceId;

- (void)removeKeychainDeviceId;

//渠道统计用，iOS7以下使用mac地址，iOS7以上使用IDFA,返回值有可能为nil
- (NSString *)macOrAdvertisingId;

//获取IDFA标志
- (NSString *)getIDFA;

//获得mac地址
- (NSString *)getMACString;


@end
