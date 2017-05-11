//
//  NeteaseMASession.m
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/13/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//
#import <AdSupport/AdSupport.h>
#import "NeteaseMASession.h"
#import "NetEaseMAUtils.h"
#import "NetEaseMobileAgent.h"

#define NETEASEMA_TIME_NOW [NSNumber numberWithLongLong:(long long)([[NSDate date] timeIntervalSince1970]*1000)]

@protocol NeteaseMACLSCrashReport <NSObject>
/**
 * Returns the session identifier for the crash report.
 **/
@property (nonatomic, readonly) NSString *identifier;

/**
 * Returns the custom key value data for the crash report.
 **/
@property (nonatomic, readonly) NSDictionary *customKeys;

/**
 * Returns the CFBundleVersion of the application that crashed.
 **/
@property (nonatomic, readonly) NSString *bundleVersion;

/**
 * Returns the CFBundleShortVersionString of the application that crashed.
 **/
@property (nonatomic, readonly) NSString *bundleShortVersionString;

/**
 * Returns the date that the application crashed at.
 **/
@property (nonatomic, readonly) NSDate *crashedOnDate;

/**
 * Returns the os version that the application crashed on.
 **/
@property (nonatomic, readonly) NSString *OSVersion;

/**
 * Returns the os build version that the application crashed on.
 **/
@property (nonatomic, readonly) NSString *OSBuildVersion;

@end


@implementation NeteaseMASession {
    NSMutableDictionary *_infoDict;
    NSMutableArray *_eventArray;
    NSMutableDictionary *_crashDict;
    
    NSString *_appId;
    NSString *_deviceId;
    NSString *_channel;
    NSString *_startTime;
}

+ (NeteaseMASession*)startSession:(NSString*)appId deviceId:(NSString*)deviceId channel:(NSString*)channel {
    return [[NeteaseMASession alloc] initWithAppId:appId deviceId:deviceId channel:channel];
}

- (id)initWithAppId:(NSString*)appId deviceId:(NSString*)deviceId channel:(NSString*)channel {
    if (self=[super init]) {
        _appId = appId;
        _deviceId = deviceId;
        _channel = channel;
        
        _startTime = [NSString stringWithFormat:@"%lld",[NETEASEMA_TIME_NOW longLongValue]];
        _eventArray = [NSMutableArray array];
        
        //i node
        _infoDict=[self createInfoNode];
    }
    return self;
}


- (NSDictionary *)getSessionInfo {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%@_%@",_deviceId,_startTime] forKey:@"s"];
    [dict setObject:_infoDict forKey:@"i"];
    return dict;
}


- (NSDictionary *)endSession {
    [_infoDict setObject:NETEASEMA_TIME_NOW forKey:@"nd"];
    [_infoDict setObject:[NetEaseMaUtils getNetworkStatus] forKey:@"nt"];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%@_%@",_deviceId,_startTime] forKey:@"s"];
    [dict setObject:_infoDict forKey:@"i"];
    [dict setObject:_eventArray forKey:@"e"];
    if (_crashDict) {
        [dict setObject:_crashDict forKey:@"f"];
    }
    return dict;
}


- (void)setURSID:(NSString*)ursId
{
    if (ursId) {
       [_infoDict setObject:ursId forKey:@"uc"];
    } else {
        [_infoDict removeObjectForKey:@"uc"];
    }
}

- (void)setExtra:(NSString*)extra {
    if (extra) {
        [_infoDict setObject:extra forKey:@"x"];
    } else {
        [_infoDict removeObjectForKey:@"x"];
    }
}

- (void)setChannel:(NSString *)channel
{
    if (![_channel isEqualToString:channel]) {
        _channel = channel;
        if (channel) {
            [_infoDict setObject:channel forKey:@"c"];
        } else {
            [_infoDict removeObjectForKey:@"c"];
        }
    }
}

-(void)addEvent:(NSString *)name param:(NSString *)param extra:(NSString *)extra
{
    NSMutableDictionary *eventNode = [NSMutableDictionary dictionary];
    [eventNode setObject:name forKey:@"n"];
    if (param) {
        [eventNode setObject:param forKey:@"p"];
    }
    if (extra) {
        [eventNode setObject:extra forKey:@"d"];
    }
    [eventNode setObject:NETEASEMA_TIME_NOW forKey:@"st"];
    
    if (!_eventArray) {
        _eventArray=[[NSMutableArray alloc]init];
    }
    [_eventArray addObject:eventNode];
    
    NETEASE_LOG(@"%@:%@:%@",name,param,extra);
}

- (void)addCrashLog:(id)crash {
    id<NeteaseMACLSCrashReport> report = crash;
    if ([report respondsToSelector:@selector(identifier)]
        &&[report respondsToSelector:@selector(crashedOnDate)]
        &&[report respondsToSelector:@selector(bundleVersion)]
        &&[report respondsToSelector:@selector(bundleShortVersionString)]) {
        _crashDict=[[NSMutableDictionary alloc]init];
        [_crashDict setObject:[NSString stringWithFormat:@"%@_%@_%@",report.identifier,report.bundleVersion,report.bundleShortVersionString] forKey:@"c"];
        
        long long stamp = [report.crashedOnDate timeIntervalSince1970]*1000;
        [_crashDict setObject:[NSNumber numberWithLongLong:stamp] forKey:@"t"];
    } else {
        NSLog(@"MobileAnyalysis: Crash Report Format Error, This may caused by that Crashlytics has been updated");
    }
}

- (NSMutableDictionary *)createInfoNode
{
    NSMutableDictionary *info=[[NSMutableDictionary alloc]initWithCapacity:1];
    [info setObject:_deviceId forKey:@"u"];
    NSString *oldDeviceId = [NetEaseMaUtils getOldDeviceId];
    if (oldDeviceId) {
        [info setObject:oldDeviceId forKey:@"u0"];
    }
    if (NSClassFromString(@"ASIdentifierManager") && [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSString *adID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        if (adID != nil) {
            [info setObject:adID forKey:@"u1"];
        }
    }
    
    [info setObject:[NetEaseMaUtils getDeviceModel] forKey:@"m"];
    [info setObject:[NetEaseMaUtils getBuildVersion] forKey:@"o"];
    [info setObject:[NetEaseMaUtils getAppVersion] forKey:@"v"];
    if (_channel) {
        [info setObject:_channel forKey:@"c"];
    }
    [info setObject:[NetEaseMaUtils getResolution] forKey:@"r"];
    [info setObject:[NSNumber numberWithInt:SDK_VERSION] forKey:@"sv"];
    [info setObject:_appId forKey:@"id"];
    
    NSString *teleOperator = [NetEaseMaUtils getTeleOperator];
    if (teleOperator) {
        [info setObject:teleOperator forKey:@"op"];
    }
    
    NSString *networkType = [NetEaseMaUtils getNetworkStatus];
    if (networkType) {
        [info setObject:networkType forKey:@"nt"]; 
    }
    
    [info setObject:_startTime forKey:@"bg"];
    return info;
}


@end
