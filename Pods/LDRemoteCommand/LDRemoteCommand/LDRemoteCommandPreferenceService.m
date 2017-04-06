//
//  LDRemoteCommandPreferenceService.m
//  NeteaseLottery
//
//  Created by david on 16/2/26.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "LDRemoteCommandPreferenceService.h"
#import "LDRemoteCommandDefine.h"
#import "LDRemoteCommandResultHandler.h"

@implementation LDRemoteCommandPreferenceService

+ (BOOL)addPreferenceValue:(id)value key:(NSString *)key
{
    return [self modifyPreferenceValue:value key:key];
}

+ (BOOL)removePreferenceByKey:(NSString *)key
{
    if (![key isKindOfClass:[NSString class]]) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)modifyPreferenceValue:(id)value key:(NSString *)key
{
    if (![key isKindOfClass:[NSString class]]) {
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)readPreferenceByKey:(NSString *)key
{
    if (![key isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    id info = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    LDRemoteCommandResultHandler *handler = [[LDRemoteCommandResultHandler alloc] init];
    [handler uploadExecuteResultToFile:readIniFilePath content:[info description] completed:nil];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
