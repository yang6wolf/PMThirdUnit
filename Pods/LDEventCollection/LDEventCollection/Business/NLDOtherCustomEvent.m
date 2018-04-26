//
//  NLDOtherCustomEvent.m
//  LDEventCollection
//
//  Created by 高振伟 on 2018/3/19.
//

#import "NLDOtherCustomEvent.h"
#import "NLDEventCollectionManager.h"

@implementation NLDOtherCustomEvent

char *printEnv(void){
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    return env;
}

// 检测用户是否开启推送权限
+ (void)checkPushNotificationPermission
{
    BOOL isOpen = NO;
    BOOL isIOS8 = [[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0;
    if (isIOS8) {
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (setting.types != UIUserNotificationTypeNone) {
            isOpen = YES;
        }
    } else {
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (type != UIRemoteNotificationTypeNone) {
            isOpen = YES;
        }
    }
    // 上报事件
    [[NLDEventCollectionManager sharedManager] addEventName:@"PushPermissionEvent" withParams:@{@"isOpen":(isOpen ? @"1":@"0")}];
}

// 检测手机是否越狱
+ (void)checkJailBreak
{
    BOOL isJailbreak = NO;
    
    // 1.判断是否存在以下文件
    NSArray *jailbreak_tool_paths = @[
                                      @"/Applications/Cydia.app",
                                      @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                                      @"/bin/bash",
                                      @"/usr/sbin/sshd",
                                      @"/etc/apt"
                                      ];
    for (NSString *path in jailbreak_tool_paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            isJailbreak = YES;
            break;
        }
    }
    
    // 2.判断是否能读取所有应用名称
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/User/Applications/"]){
        isJailbreak = YES;
    }
    
    // 3.读取环境变量
    if(printEnv()){
        isJailbreak = YES;
    }
    
    // 上报检测结果
    [[NLDEventCollectionManager sharedManager] addEventName:@"JailbreakEvent" withParams:@{@"isJailbreak":(isJailbreak ? @"1":@"0")}];
}

// 检测手机是否模拟器
+ (void)checkIsSimulator
{
    BOOL isSimulator = NO;
#if TARGET_IPHONE_SIMULATOR  //模拟器
    isSimulator = YES;
#elif TARGET_OS_IPHONE      //真机
    isSimulator = NO;
#endif
    
    // 上报检测结果
    [[NLDEventCollectionManager sharedManager] addEventName:@"SimulatorEvent" withParams:@{@"isSimulator":(isSimulator ? @"1":@"0")}];
}

// 检测手机当前的充电状态
+ (void)checkBatteryState
{
    NSString *batteryState = @"";
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    if (device.batteryState == UIDeviceBatteryStateUnknown) {
        batteryState = @"UnKnow";
    }else if (device.batteryState == UIDeviceBatteryStateUnplugged){
        batteryState = @"Unplugged";
    }else if (device.batteryState == UIDeviceBatteryStateCharging){
        batteryState = @"Charging";
    }else if (device.batteryState == UIDeviceBatteryStateFull){
        batteryState = @"Full";
    }
    
    // 上报检测结果
    [[NLDEventCollectionManager sharedManager] addEventName:@"BatteryStateEvent" withParams:@{@"batteryState":batteryState}];
}

@end
