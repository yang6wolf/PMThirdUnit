//
//  NeteaseMAPerformance.m
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/15/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import "NeteaseMAPerformance.h"
#import "NeteaseMASessionHTTPProtocol.h"
#import "NetEaseMAUtils.h"
#import "NetEaseMobileAgent.h"

#define CODE_FOR_FAILD_HTTP 1000
#define TIMESTAMP_NUMBER(interval)  [NSNumber numberWithLongLong:interval*1000]

extern NSString *const kNeteaseMAStartOverNotification;
@implementation NeteaseMAPerformance {
    NSString *_appId;
    NSString *_deviceId;
    NSString *_channel;
    
    NSMutableArray *_controllerRecordArray;
    NSMutableArray *_urlRecordArray;
    NSMutableDictionary *_dnsHostResolveInfo;
    
    BOOL _launchTimeValid;
    NSTimeInterval _launchStartTime;
    NSTimeInterval _launchEndTime;
}

+ (NeteaseMAPerformance*)startWithAppId:(NSString*)appId deviceId:(NSString*)deviceId channel:(NSString*)channel {
    return [[NeteaseMAPerformance alloc] initWithAppId:appId deviceId:deviceId channel:channel];
}

- (id)initWithAppId:(NSString*)appId deviceId:(NSString*)deviceId channel:(NSString*)channel {
    if (self=[super init]) {
        _appId = appId;
        _deviceId = deviceId;
        _channel = channel;
        
        _controllerRecordArray = [NSMutableArray array];
        _urlRecordArray = [NSMutableArray array];
        _dnsHostResolveInfo = [NSMutableDictionary dictionary];

        [NeteaseMASessionHTTPProtocol setDelegate:(id<NeteaseMAHTTPProtocolDelegate>)self];

        _launchTimeValid = YES;
        _launchStartTime = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}


- (void)setChannel:(NSString *)channel
{
    _channel = channel;
}


- (void)clearRecords {
    [_urlRecordArray removeAllObjects];
    [_controllerRecordArray removeAllObjects];
    [_dnsHostResolveInfo removeAllObjects];
    _launchTimeValid = NO;
}


- (NSDictionary*)convertAllRecordsToDataTrunk {
    if (_controllerRecordArray.count==0
        &&_urlRecordArray.count==0) {
        return nil;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[self createInfoNode] forKey:@"i"];
    if (_controllerRecordArray.count>0) {
        [dict setObject:[_controllerRecordArray copy] forKey:@"page"];
    }
    if (_urlRecordArray.count>0) {
        [dict setObject:[_urlRecordArray copy] forKey:@"url"];
    }

    if(_dnsHostResolveInfo.count > 0){
        [dict setObject:[self creatDNSNode] forKey:@"dns"];
    }
    
    if (_launchTimeValid&&_launchEndTime>_launchStartTime) {
        [dict setObject:[self createlauncNode] forKey:@"launch"];
        _launchTimeValid = NO;
    }
    
    return dict;
}

- (void)addControllerRecord:(NSDictionary*)dict {
    if (dict) {
        [_controllerRecordArray addObject:dict];
        if (_launchTimeValid&&_launchEndTime<_launchStartTime) {
            _launchEndTime = [NSDate timeIntervalSinceReferenceDate];
            NSLog(@"\n\n\n---------------\nfirst apppert controller:%0.5f\n,first controller switch time:%@\n------nt appbi startup time===%0.5f-----\n---------------\n\n\n", [NSDate timeIntervalSinceReferenceDate], dict, (_launchEndTime-_launchStartTime));
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeteaseMAStartOverNotification object:nil userInfo:nil];
        }
    }
}

- (void)addURLRecord:(NSDictionary*)dict {
    [_urlRecordArray addObject:dict];
}

- (void)addDNSResolveRecord:(NSDictionary *)dict forHost:(NSString *)host {
    if(host && dict && ![_dnsHostResolveInfo objectForKey:host]){
        _dnsHostResolveInfo[host] = dict;
    }
}

- (NSDictionary*)createInfoNode {
    NSMutableDictionary *info=[[NSMutableDictionary alloc]initWithCapacity:1];
    [info setObject:_deviceId forKey:@"u"];
    [info setObject:[NetEaseMaUtils getDeviceModel] forKey:@"m"];
    [info setObject:[NetEaseMaUtils getBuildVersion] forKey:@"o"];
    [info setObject:[NetEaseMaUtils getAppVersion] forKey:@"v"];
    [info setObject:[NSNumber numberWithInt:SDK_VERSION] forKey:@"sv"];
    [info setObject:_appId forKey:@"id"];
    
    if (self.ip) {
        [info setObject:self.ip forKey:@"ip"];
    }
    [info setObject:[NetEaseMaUtils getNetworkStatus] forKey:@"nt"];
    NSString *teleOperator = [NetEaseMaUtils getTeleOperator];
    if (teleOperator) {
        [info setObject:teleOperator forKey:@"op"];
    }
    return info;
}

- (NSDictionary*)createlauncNode {
    return @{@"st":TIMESTAMP_NUMBER(_launchStartTime),
             @"et":TIMESTAMP_NUMBER(_launchEndTime)};
}

- (NSArray*)creatDNSNode {
    NSMutableArray *dnsArray = [NSMutableArray array];
    for(NSString *hostKey in _dnsHostResolveInfo.allKeys){
        NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:[_dnsHostResolveInfo objectForKey:hostKey]];
        [tmpDict setObject:hostKey forKey:@"host"];
        [dnsArray addObject:tmpDict];
    }
    return dnsArray;
}


#pragma mark NeteaseMAHTTPProtocolDelegate
- (bool)protocolShouldHandleURL:(NSURL*)url {
    return [self.delegate neteaseMAPerformanceShouldProbeUrl:url];
}

- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime withStatusCode:(NSInteger)code {
    NSString *stringUrl = url.path;
    if (stringUrl) {
        [self addURLRecord:@{@"n":stringUrl,
                             @"st":TIMESTAMP_NUMBER(startTime),
                             @"et":TIMESTAMP_NUMBER(endTime),
                             @"c":[NSNumber numberWithInteger:code]}];
    }
}

- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime rxBytes:(NSUInteger)rxBytes txBytes:(NSUInteger)txBytes withStatusCode:(NSInteger)code{
    NSString *stringUrl = url.path;
    if (stringUrl) {
        [self addURLRecord:@{@"n":stringUrl,
                             @"st":TIMESTAMP_NUMBER(startTime),
                             @"et":TIMESTAMP_NUMBER(endTime),
                             @"rx":[NSNumber numberWithUnsignedInteger:rxBytes],
                             @"tx":[NSNumber numberWithUnsignedInteger:txBytes],
                             @"c":[NSNumber numberWithInteger:code]}];
    }
}

- (void)protocolDidCompleteURL:(NSURL*)url from:(NSTimeInterval)startTime to:(NSTimeInterval)endTime withError:(NSError*)error {
    NSString *stringUrl = url.path;
    if (stringUrl) {
        [self addURLRecord:@{@"n":stringUrl,
                             @"st":TIMESTAMP_NUMBER(startTime),
                             @"et":TIMESTAMP_NUMBER(endTime),
                             @"c":[NSNumber numberWithInteger:CODE_FOR_FAILD_HTTP],
                             @"e":[error localizedDescription]}];
    }
}

- (BOOL)protocolShouldDNSResolve:(NSString *)host{
    BOOL should = YES;
    if(_dnsHostResolveInfo && [_dnsHostResolveInfo objectForKey:host]){
        should = NO;
    }
    return should;
}


- (void)protocolDidCompleteDNSResolve:(NSString *)host dnsIP:(NSString *)dnsIP dnsResolveTime:(int)dnsResolveTime{
    if(host && dnsIP && dnsResolveTime){
        [self addDNSResolveRecord:@{@"dp":dnsIP, @"dt":[NSNumber numberWithInt:dnsResolveTime]} forHost:host];
    }
}

- (NSString *)protocolGetIPbyDomain:(NSString *)domain
{
    return [self.delegate neteaseMAPerformanceGetIPbyDomain:domain];
}

@end
