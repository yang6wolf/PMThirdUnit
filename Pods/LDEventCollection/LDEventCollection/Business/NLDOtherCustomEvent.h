//
//  NLDOtherCustomEvent.h
//  LDEventCollection
//
//  Created by 高振伟 on 2018/3/19.
//

#import <Foundation/Foundation.h>

@interface NLDOtherCustomEvent : NSObject

// 检测用户是否开启推送权限
+ (void)checkPushNotificationPermission;

// 检测手机是否越狱
+ (void)checkJailBreak;

// 检测手机是否模拟器
+ (void)checkIsSimulator;

// 检测手机当前的充电状态
+ (void)checkBatteryState;

@end
