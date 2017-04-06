//
//  MobileAgent.m
//  NeteaseStatistics
//
//  Created by zhang jie on 13-4-12.
//  Copyright (c) 2013年 zhang jie. All rights reserved.
//
#import "NetEaseMobileAgent.h"
#import "NeteaseMobileManager.h"
#import "NetEaseMADiagnoseLog.h"

NSString * const kNeteaseMAOnlineAppConfigLoadNotification = @"NeteaseMAOnlineAppConfigLoadNotification";
NSString * const kNeteaseMAOnlineAppConfigKey = @"onlineConfig";
NSString * const kNeteaseMAStartOverNotification = @"kNeteaseMAStartOverNotification";

@interface NetEaseMobileAgent ()

@property (nonatomic, copy) NSArray *protocolNames;
@property (nonatomic, copy) NSString *analysisHostName;

@end

@implementation NetEaseMobileAgent  {
}

+(NetEaseMobileAgent *)sharedInstance
{
    static NetEaseMobileAgent *sharedInstance=nil;
    @synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance=[[self alloc] init];
		}
	}
	return sharedInstance;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setAppId:(NSString *)appId andChannel:(NSString*)channel andDeviceId:(NSString*)deviceId {
    [NeteaseMobileManager sharedManager].delegate = (id<NetEaseMobileManagerDelegate>)self;
    [[NeteaseMobileManager sharedManager] setAppId:appId andChannel:channel andDeviceId:deviceId];
}

-(void)resetChannel:(NSString *)channel
{
    [NeteaseMobileManager sharedManager].channel = channel;
}

- (void)reconnectionAppbiData
{
    [[NeteaseMobileManager sharedManager] reconnectionConfigData];
}

- (void)setProtocolClassNames:(NSArray<Class> *)protocolClassNames
{
    self.protocolNames = protocolClassNames;
}

- (NSArray *)getAllProtocolClassNames
{
    return self.protocolNames;
}

- (void)setAnalysisHost:(NSString *)host
{
    _analysisHostName = host;
}

- (NSString *)getAnalysisHost
{
    if (self.analysisHostName.length > 0) {
        return self.analysisHostName;
    } else {
        return @"https://mt.analytics.163.com";
    }
}

-(void)addEvent:(NSString *)name param:(NSString *)param extra:(NSString *)extra
{    
    [[NeteaseMobileManager sharedManager] addEvent:name param:param extra:extra];
}

-(void)addEvent:(NSString *)name param:(NSString *)param
{
    [self addEvent:name param:param extra:nil];
}

- (void)reportCrash:(id)crash {
    [[NeteaseMobileManager sharedManager] reportCrash:crash];
}

- (void)reportSessionPfmData{
    [[NeteaseMobileManager sharedManager] reportSessionPfmData];
}

- (void)setupDiagnose:(NSArray *)params {
    [[NetEaseMADiagnoseLog sharedInstance] setupDiagnose:params];
}

- (void)addDiagnoseLog:(NSString *)log tag:(NSString *)tag {
    [[NetEaseMADiagnoseLog sharedInstance] addDiagnoseLog:log tag:tag];
}

- (BOOL)neteaseMobileManagerShouldProbleUrl:(NSURL*)url {
    if ([self.delegate respondsToSelector:@selector(neteaseMobileAgentShouldProbleUrl:)]) {
        return [self.delegate neteaseMobileAgentShouldProbleUrl:url];
    }
    return YES;
}

- (NSString *)neteaseMobileManagerGetIPbyDomain:(NSString *)domain
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(neteaseMobileAgentGetIPbyDomain:)]) {
        return [self.delegate neteaseMobileAgentGetIPbyDomain:domain];
    }
    return nil;
}

- (BOOL)neteaseMobileManagerShouldSaveSession
{
    if ([self.delegate respondsToSelector:@selector(neteaseMobileManagerShouldSaveSession)]) {
        return [self.delegate neteaseMobileManagerShouldSaveSession];
    }
    return YES;
}

@end
