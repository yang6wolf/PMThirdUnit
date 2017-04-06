//
//  NeteaseMobileManager.m
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/14/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import "NeteaseMobileManager.h"
#import "NetEaseMAUtils.h"
#import "NeteaseMANetworkManager.h"
#import "NetEaseMACache.h"
#import "NetEaseMAUpLoader.h"
#import "NetEaseMADownloader.h"
#import "NeteaseMASession.h"
#import "NetEaseMobileAgent.h"
#import "NeteaseMAPerformance.h"
#import "NeteaseMAControllerProber.h"
#import "NeteaseMAController.h"

#define MOBILE_SESSION_UPLOAD_URL @"/cdp"
#define MOBILE_PERFORMANCE_UPLOAD_URL @"/pfm"

@interface NeteaseMobileManager()<NeteaseMANetworkManagerDelegate,NetEaseMAUploaderDelegate,NetEaseMADownloaderDelegate,NeteaseMAPerformanceDelegate>
@property(nonatomic,strong) NeteaseMASession *session;
@end

@implementation NeteaseMobileManager {
    NeteaseMANetworkManager *_networkManager;
    NetEaseMAUpLoader *_sessionUpLoader;
    NetEaseMAUpLoader *_performanceUpLoader;
    NetEaseMADownloader *_downloader;
    NetEaseMACache *_cache;
    NeteaseMAPerformance *_performance;
    NeteaseMAControllerProber *_controllerProbe;
}

+ (NeteaseMobileManager*)sharedManager {
    static NeteaseMobileManager * _instance = nil;
    if (!_instance) {
        _instance = [[NeteaseMobileManager alloc] init];
    }
    return _instance;
}

- (void)setChannel:(NSString *)channel
{
    if (![_channel isEqualToString:channel]) {
        _channel = channel;
        [_performance setChannel:channel];
        [_session setChannel:channel];
    }
}

#pragma mark public methods

-(id)init
{
    if(self=[super init])
    {

        _networkManager = [[NeteaseMANetworkManager alloc] init];
        _networkManager.delegate = self;

        //FIXME: 暂时删除，避免Crash的时候上报数据后无法删除上报文件
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fastSaveSession)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(endSession)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(startSession)
                                                         name:UIApplicationWillEnterForegroundNotification
                                                       object:nil];
        }
    }
    return self;
}


-(void)setAppId:(NSString *)appId andChannel:(NSString*)channel andDeviceId:(NSString*)deviceId {
    NSAssert(self.appId==nil,@"self.appId!=nil");
    self.appId = appId;
    self.deviceId = deviceId;
    _channel = channel;
    
    [NetEaseMaUtils resetEncyptKeyWithAppId:appId];
    [_networkManager start];

    _sessionUpLoader=[[NetEaseMAUpLoader alloc] initWithUrl:[NSString stringWithFormat:@"%@%@",[[NetEaseMobileAgent sharedInstance] getAnalysisHost],MOBILE_SESSION_UPLOAD_URL]];
    _sessionUpLoader.delegate = self;
    
    _performanceUpLoader = [[NetEaseMAUpLoader alloc] initWithUrl:[NSString stringWithFormat:@"%@%@",[[NetEaseMobileAgent sharedInstance] getAnalysisHost],MOBILE_PERFORMANCE_UPLOAD_URL]];
    _performanceUpLoader.delegate = self;
    
    _downloader = [[NetEaseMADownloader alloc] initWithAppid:_appId];
    _downloader.delegate = self;
    
    _cache = [[NetEaseMACache alloc] init];
    
    _performance = [NeteaseMAPerformance startWithAppId:appId deviceId:deviceId channel:channel];
    _performance.delegate = self;

    _controllerProbe = [[NeteaseMAControllerProber alloc] init];
    _controllerProbe.delegate = (id<NeteaseMAControllerProberDelegate>)self;
    [_controllerProbe start];

    //初始化化的时候需要马上下载配置数据
    [self startSession];
}

- (void)reconnectionConfigData
{
    [_downloader downloadWithSessionTrunk:[self.session getSessionInfo]];
}

- (void)reportSessionPfmData{
    [_sessionUpLoader uploadSessionCacheFiles:[_cache getCachedSessionFiles]];
    [_performanceUpLoader uploadSessionCacheFiles:[_cache getCachedPerformanceFiles]];
}

-(void)startSession {
    [_sessionUpLoader uploadSessionCacheFiles:[_cache getCachedSessionFiles]];
    [_performanceUpLoader uploadSessionCacheFiles:[_cache getCachedPerformanceFiles]];
    
    if (!self.session) {
        self.session = [NeteaseMASession startSession:self.appId deviceId:self.deviceId channel:self.channel];
    }
    if (!_downloader.isLastDownloadSuccess) {
        [_downloader downloadWithSessionTrunk:[self.session getSessionInfo]];
    }
}

-(void)fastSaveSession{
    //save session data
    [self.session setURSID:[NetEaseMobileAgent sharedInstance].ursId];
    [self.session setExtra:[NetEaseMobileAgent sharedInstance].extra];
    [_cache saveSessionTrunk:[self.session endSession]];
    self.session = nil;

    //save pfm data
    NSDictionary *performanceInfo = [_performance convertAllRecordsToDataTrunk];
    [_performance clearRecords];
    if (performanceInfo) {
        [_cache savePerformanceTrunk:performanceInfo];
    }
}

-(void)endSession
{
    [self.session setURSID:[NetEaseMobileAgent sharedInstance].ursId];
    [self.session setExtra:[NetEaseMobileAgent sharedInstance].extra];
    if ([self.delegate neteaseMobileManagerShouldSaveSession]) {
        [_cache saveSessionTrunk:[self.session endSession]];
    }
    self.session = nil;
    [_sessionUpLoader uploadSessionCacheFiles:[_cache getCachedSessionFiles]];
    
    [self saveAndUploadPerformanceInfo];
}

- (void)saveAndUploadPerformanceInfo {
    NSDictionary *performanceInfo = [_performance convertAllRecordsToDataTrunk];
    [_performance clearRecords];
    if (performanceInfo) {
        [_cache savePerformanceTrunk:performanceInfo];
    }
    [_performanceUpLoader uploadSessionCacheFiles:[_cache getCachedPerformanceFiles]];
}


-(void)addEvent:(NSString *)name param:(NSString *)param extra:(NSString *)extra
{
    [self.session addEvent:name param:param extra:extra];
}

-(void)addEvent:(NSString *)name param:(NSString *)param
{
    [self addEvent:name param:param extra:nil];
}

-(void)addEventOfHttpRequestWithUrl:(NSString*)url duration:(NSTimeInterval)interval result:(BOOL)result {
    NSMutableDictionary *eventNode = [NSMutableDictionary dictionary];
    [eventNode setObject:url forKey:@"url"];
    [eventNode setObject:[NSNumber numberWithDouble:interval] forKey:@"t"];
    [eventNode setObject:[NSNumber numberWithBool:result] forKey:@"r"];
}

- (void)reportCrash:(id)crash{
    [self.session addCrashLog:crash];
}

#pragma mark NeteaseMANetworkManagerDelegate
- (void)networkManagerNetworkBecomeAwailable:(NeteaseMANetworkManager*)manager {
    [_downloader downloadWithSessionTrunk:[self.session getSessionInfo]];
}

- (void)networkManagerIPUpdated:(NeteaseMANetworkManager*)manager {
    if (_performance.ip&&![_performance.ip isEqualToString:manager.ip]) {
        [self saveAndUploadPerformanceInfo];
    }
    _performance.ip = manager.ip;
}

#pragma mark NeteaseMaDownloaderDelegate
- (void)netEaseMADownloaderComplete:(BOOL)success withResponse:(NSDictionary*)dict {
    if (success) {
        _onlineAppConfig = dict;
        NSDictionary *userInfo = nil;
        if (dict) {
            userInfo = @{kNeteaseMAOnlineAppConfigKey:_onlineAppConfig};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeteaseMAOnlineAppConfigLoadNotification
                                                            object:self
                                                          userInfo:userInfo];
    }
}

- (void)netEaseMADownloaderShouldRefresh {
    [_downloader downloadWithSessionTrunk:[self.session getSessionInfo]];
}

#pragma mark NeteaseMaUploaderDelegate
- (void)netEaseMAUploadSessionFiles:(NSArray*)array complete:(BOOL)success {
    if (success) {
        [_cache removeCachedFiles:array];
    }
}

#pragma mark NeteaseMAPerformanceDelegate
- (BOOL)neteaseMAPerformanceShouldProbeUrl:(NSURL *)url {
    if ([[url host] rangeOfString:@"163"].length==0
        &&[[url host] rangeOfString:@"126"].length==0) {
        return YES;
    }
    if ([[url host] isEqualToString:@"mt.analytics.163.com"]) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(neteaseMobileManagerShouldProbleUrl:)]) {
        return [self.delegate neteaseMobileManagerShouldProbleUrl:url];
    } else {
        return YES;
    }
}

- (NSString *)neteaseMAPerformanceGetIPbyDomain:(NSString *)domain
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(neteaseMobileManagerGetIPbyDomain:)]) {
        return [self.delegate neteaseMobileManagerGetIPbyDomain:domain];
    } else {
        return nil;
    }
}

#pragma mark NeteaseMAControllerProberDelegate
- (void)controllerProber:(NeteaseMAControllerProber*)probe didGetPeformanceRecord:(NSDictionary*)dict {
    [_performance addControllerRecord:dict];
}

- (void)controllerProber:(NeteaseMAControllerProber*)probe didGetEvent:(NeteaseMAControllerEvent)event forController:(UIViewController*)controller {
    NSString *pageName = NSStringFromClass(controller.class);
    NSString *pageEvent = nil;
    switch (event) {
        case NeteaseMAControllerCreate:
            pageEvent = @"pl";break;
        case NeteaseMAControllerOpen:
            pageEvent = @"pr";break;
        case NeteaseMAControllerClose:
            pageEvent = @"pp";break;
        case NeteaseMAControllerDestroy:
            pageEvent = @"pd";break;
        default:
            break;
    }
    if (pageName&&pageEvent) {
        NSString *extraParam  = nil;
        if ([controller respondsToSelector:@selector(pageEventParam)]) {
            extraParam = [controller performSelector:@selector(pageEventParam) withObject:nil];
        }
        [self.session addEvent:pageEvent param:pageName extra:extraParam];
    }
}

@end
