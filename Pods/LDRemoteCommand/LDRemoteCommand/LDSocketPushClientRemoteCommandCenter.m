//
//  LDSocketPushClientRemoteCommandCenter.m
//  NeteaseLottery
//
//  Created by david on 16/2/22.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "LDSocketPushClientRemoteCommandCenter.h"
#import "LDRemoteCommandDefine.h"
#import "LDRemoteCommandPreferenceService.h"
#import "LDRemoteCommandNetDiagnoseService.h"

NSString *const fileNameKey = @"spname";
NSString *const filePathKey = @"path";
NSString *const targetKey   = @"keyname";
NSString *const targetValue = @"value";
NSString *const urlKey = @"url";

@implementation LDSocketPushClientRemoteCommandCenter

+ (instancetype)sharedInstance
{
    static LDSocketPushClientRemoteCommandCenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LDSocketPushClientRemoteCommandCenter alloc] init];
    });
    return instance;
}

- (BOOL)executeCommand:(id<LDRemoteCommandProtocol>)item
{
    if (item.command == DelayKillType) {
        return [self killProgressOnExit];
        
    } else if (item.command == ReadIniType) {
        for (NSDictionary *dict in item.params) {
            [LDRemoteCommandPreferenceService readPreferenceByKey:dict[targetKey]];
        }
        return YES;
        
    } else if (item.command == RemoveIniType) {
        for (NSDictionary *dict in item.params) {
            [LDRemoteCommandPreferenceService removePreferenceByKey:dict[targetKey]];
        }
        return YES;
        
    } else if (item.command == AddIniType) {
        for (NSDictionary *dict in item.params) {
            [LDRemoteCommandPreferenceService addPreferenceValue:dict[targetValue]
                                                             key:dict[targetKey]];
        }
        return YES;

    } else if (item.command == ModifyIniType) {
        for (NSDictionary *dict in item.params) {
            [LDRemoteCommandPreferenceService modifyPreferenceValue:dict[targetValue]
                                                                key:dict[targetKey]];
        }
        return YES;
        
    } else if (item.command == NetDiagnoseType) {
        NSMutableArray *domains = [NSMutableArray array];
        for (NSDictionary *dict in item.params) {
            if (dict[urlKey]) {
                [domains addObject:dict[urlKey]];
            }
        }
        return [self netDiagnoseDomains:domains];
        
    } else if (item.command == ExecuteSQLType) { //暂不支持
        NSLog(@"暂不支持执行sql语句");
         return NO;
    } else if (item.command == SwitchIPModeType) {
        if ([self.methodSource respondsToSelector:@selector(RCSetIPModeState:)]) {
            for (NSDictionary *dict in item.params) {
                if (dict[@"switch"] && [dict[@"switch"] integerValue] == 0) {
                    [self.methodSource RCSetIPModeState:NO];
                    return YES;
                }
            }
            [self.methodSource RCSetIPModeState:YES];
            return YES;
        }
    } else if (item.command == DiagnoseLogType) {
        if ([self.methodSource respondsToSelector:@selector(RCSetupDiagnose:)]) {
            [self.methodSource RCSetupDiagnose:item.params];
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Private Mehtods

- (BOOL)netDiagnoseDomains:(NSArray *)domains
{
    if (!domains || ![domains count]) {
        return NO;
    }
    
    LDRemoteCommandNetDiagnoseService *netService = [LDRemoteCommandNetDiagnoseService sharedInstance];
    [netService setDiagnoseDomains:domains];
    [netService start];
    
    return YES;
}

- (BOOL)killProgressOnExit
{
    //__block id observer =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        exit(0);
        //[[NSNotificationCenter defaultCenter] removeObserver:observer name:UIApplicationDidEnterBackgroundNotification object:nil];
    }];
    return YES;
}

- (BOOL)dbFile:(NSString *)filePath execSQL:(NSString *)sql
{
    if (!filePath || ![filePath length]) {
        return NO;
    }
    if (!sql || ![sql length]) {
        return NO;
    }
    
    return YES;
}
@end
