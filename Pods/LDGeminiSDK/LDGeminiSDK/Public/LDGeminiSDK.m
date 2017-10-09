//
//  LDGeminiSDK.m
//  LDGeminiSDK
//
//  Created by wangkaird on 2016/10/11.
//  Copyright © 2016年 wangkaird. All rights reserved.
//

#import "LDGeminiSDK.h"
#import "LDGeminiConfig.h"
#import "LDGeminiNetwork.h"
#import "NSString+LDGeminiMD5.h"
#import "LDGeminiNetwork.h"
#import "LDGeminiService.h"
#import "LDGeminiCase.h"
#import "LDGeminiMacro.h"
#import "LDGeminiNetworkInterface.h"
#import "LDGeminiNetwork+IPAddress.h"
#import "LDGeminiNetwork+NetworkStatus.h"

static NSString * const LDGeminiDefaultDeviceType   = @"iPhone";
static NSString * const LDGeminiCaseListKey         = @"LDGeminiCaseListKey";
static NSString * const LDGeminiLocalCaselistKey    = @"LDGeminiLocalCaselistKey";

@interface LDGeminiSDK ()

@property (nonatomic, strong) NSDictionary   *cache;    // nil，未初始化。 @{}: 无任何值
@property (nonatomic, strong) LDGeminiConfig *config;
@property (nonatomic, strong) NSArray        *registeredCaseIds;
@property (nonatomic, copy)   LDGeminiCacheUpdateHandler cacheUpdateHandler;
@property (nonatomic, assign) BOOL  enableCacheAutoUpdate;
@property (nonatomic, assign) BOOL  enableGeminiSDK;

@end

@implementation LDGeminiSDK

+ (instancetype)sharedInstance {
    static LDGeminiSDK *geminiSDK = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        geminiSDK = [[LDGeminiSDK alloc] initWithSharedConfig:YES];
        [geminiSDK enableCacheAutoUpdate:YES];
    });
    
    return geminiSDK;
}

#pragma mark - Public Class Methods

// MARK: 基本配置方法
+ (BOOL)setupGeminiWithAppKey:(NSString *)appKey deviceId:(NSString *)deviceId userId:(NSString *)userId {
    return [[self sharedInstance] setupGeminiWithAppKey:appKey deviceId:deviceId userId:userId];
}

+ (void)setBaseUrl:(NSString *)baseUrl {
    [LDGeminiNetworkInterface setBaseUrl:baseUrl];
}

+ (void)setupCacheUpdateHandler:(LDGeminiCacheUpdateHandler)handler {
    [[self sharedInstance] setupCacheUpdateHandler:handler];
}

// MARK: 开关控制
+ (void)enableCacheAutoUpdate:(BOOL)enable {
    [[self sharedInstance] enableCacheAutoUpdate:enable];
}

// MARK: 请求与查询
+ (void)asyncUpdateCache:(void (^)(BOOL))completion {
    [[self sharedInstance] asyncUpdateCache:completion];
}

+ (void)syncUpdateCache:(NSTimeInterval)timeout error:(NSError * _Nullable __autoreleasing *)error {
    [[self sharedInstance] syncUpdateCache:timeout error:error];
}

+ (id)getFlag:(NSString *)caseId defaultFlag:(id)defaultFlag {
    return [[self sharedInstance] getFlag:caseId defaultFlag:defaultFlag];
}

+ (void)asyncGetFlag:(NSString *)caseId defaultFlag:(id)defaultFlag handler:(LDGeminiAsyncGetHandler)handler {
    if (!handler) {
        // handler为nil时不会做任何处理
        return;
    }
    [[self sharedInstance] asyncGetFlag:caseId defaultFlag:defaultFlag handler:handler];
}

+ (id)syncGetFlag:(NSString *)caseId defaultFlag:(id)defaultFlag timeout:(NSTimeInterval)timeout error:(NSError * _Nullable __autoreleasing *)error {
    return [[self sharedInstance] syncGetFlag:caseId defaultFlag:defaultFlag timeout:timeout error:error];
}

// MARK: 辅助方法
+ (BOOL)registeredCase:(NSString *)caseId {
    return [[self sharedInstance] registeredCase:caseId];
}

+ (NSArray *)currentCaseIdList {
    return [[self sharedInstance] currentCaseIdList];
}

+ (NSString *)stringForCaseList {
    return [[self sharedInstance] stringForCaseList];
}

+ (NSDictionary *)debugInfo {
    return [[self sharedInstance] debugInfo];
}

#pragma mark - Instance Methods
- (instancetype) initWithSharedConfig:(BOOL)sharedConfig {
    self = [super init];
    if (self) {
        _cache = nil;
        _config = sharedConfig ? [LDGeminiConfig sharedConfig] : [[LDGeminiConfig alloc] init];
        _registeredCaseIds = nil;
        _enableGeminiSDK = NO;
        [_config resetConfigs];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: 基本配置方法
- (BOOL)setupGeminiWithAppKey:(NSString *)appKey deviceId:(NSString *)deviceId userId:(NSString *)userId {
    self.enableGeminiSDK = NO;
    if (appKey.length <= 0 ||
        deviceId.length <= 0) {
        return self.enableGeminiSDK;
    }

    [self iRefreshConfigWithAppKey:appKey deviceId:deviceId userId:userId];
    [self iSetupGeminiAccessIP:[LDGeminiNetwork IPAddress]];
    [self iSetupGeminiNetworkStatus:[LDGeminiNetwork networkStatus]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iAppWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.enableGeminiSDK = YES;
    return self.enableGeminiSDK;
}


- (void)setupCacheUpdateHandler:(LDGeminiCacheUpdateHandler)handler {
    self.cacheUpdateHandler = handler;
}

// MARK: 开关控制
- (void)enableCacheAutoUpdate:(BOOL)enable {
    self.enableCacheAutoUpdate = enable;
}

// MARK: 请求与查询
- (void)asyncUpdateCache:(void (^)(BOOL success))completion {
    [self iAsyncFetchCaseListWithHandler:^(NSArray * _Nullable array, NSError * _Nullable error) {
        if (array) {
            self.cache = @{LDGeminiCaseListKey : array};
        }
        if (completion) {
            completion(array != nil);
        }
    }];
}

- (void)syncUpdateCache:(NSTimeInterval)timeout error:(NSError * _Nullable __autoreleasing *)error {
    NSError *syncError = nil;
    [self iSyncFetchCaseListWithTimeout:timeout error:&syncError];
    if (error) {
        *error = syncError;
    }
}

- (id)getFlag:(NSString *)caseId defaultFlag:(id)defaultFlag {
    if (![self iHasCache]) {
        return defaultFlag;
    }

    NSDictionary *cache = self.cache;
    NSArray *caseList = cache[LDGeminiCaseListKey];
    id ret = defaultFlag;
    if (cache) {
        for (LDGeminiCase *caseInstance in caseList) {
            if (![caseInstance isKindOfClass:[LDGeminiCase class]]) {
                continue;
            }
            if ([caseInstance.caseId isEqualToString:caseId]) {
                ret = caseInstance.flag;
                break;
            }
        }
    } else {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:LDGeminiLocalCaselistKey];
        NSDictionary *localCache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        caseList = localCache[LDGeminiCaseListKey];
        if (caseList) {
            self.cache = localCache;
        }
        for (LDGeminiCase *caseInstance in caseList) {
            if (![caseInstance isKindOfClass:[LDGeminiCase class]]) {
                continue;
            }
            if ([caseInstance.caseId isEqualToString:caseId]) {
                ret = caseInstance.flag;
                break;
            }
        }
    }
    return ret;
}

- (void)asyncGetFlag:(NSString *)caseId defaultFlag:(id)defaultFlag handler:(LDGeminiAsyncGetHandler)handler {
    [self iAsyncFetchCaseListWithHandler:^(NSArray * _Nullable array, NSError * _Nullable error) {
        if (!error) {
            self.cache = @{LDGeminiCaseListKey : array};
        }
        if (handler) {
            handler([self getFlag:caseId defaultFlag:defaultFlag], error);
        }
    }];
}

- (id)syncGetFlag:(NSString *)caseId defaultFlag:(id)defaultFlag timeout:(NSTimeInterval)timeout error:( NSError * __autoreleasing *)error {
    NSError *syncError = nil;
    NSArray *cache = [self iSyncFetchCaseListWithTimeout:timeout error:&syncError];

    if (!syncError) {
        //正确返回
        cache = cache ? cache : @[];
        self.cache = @{LDGeminiCaseListKey : cache};
    }

    if (error) {
        *error = syncError;
    }
    return [self getFlag:caseId defaultFlag:defaultFlag];
}


- (NSArray *)currentCaseIdList {
    if (![self iHasCache]) {
        return @[];
    }
    NSDictionary *cache = self.cache;
    NSArray *caseList = cache[LDGeminiCaseListKey];
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:[caseList count]];
    for (LDGeminiCase *caseInstance in caseList) {
        if (![caseInstance isKindOfClass:[LDGeminiCase class]]) {
            continue;
        }
        [ret addObject:caseInstance.caseId];
    }
    return [ret copy];
}

- (NSString *)stringForCaseList {
    NSDictionary *cache = self.cache;
    NSArray *caseList = cache[LDGeminiCaseListKey];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (LDGeminiCase *caseInstance in caseList) {
        if (![caseInstance isKindOfClass:[LDGeminiCase class]]) {
            continue;
        }
        [list addObject:[caseInstance toDictionary]];
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:list options:0 error:nil];
    NSString *jsonString = nil;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    return jsonString ? : @"";
}

- (NSDictionary *)debugInfo {
    NSMutableDictionary *debugInfo = [[NSMutableDictionary alloc] init];
#if LDGeminiDebug
    NSMutableDictionary *configInfo = [[NSMutableDictionary alloc] init];
    configInfo[@"productFlag"] = [self.config getConfig:LDGeminiAppKeyConfigAttributeName];
    configInfo[@"userId"] = [self.config getConfig:LDGeminiUserIdConfigAttributeName];
    configInfo[@"timestamp"] = [self.config getConfig:LDGeminiTimeStampConfigAttributeName];
    configInfo[@"deviceId"] = [self.config getConfig:LDGeminiDeviceIDConfigAttributeName];
    configInfo[@"Sign"] = [self.config getConfig:LDGeminiSignConfigAttributeName];
    configInfo[@"accessIP"] = [self.config getConfig:LDGeminiAccessIPConfigAttributeName];
    configInfo[@"netType"] = [self.config getConfig:LDGeminiNetTypeConfigAttributeName];
    configInfo[@"deviceType"] = [self.config getConfig:LDGeminiDeviceTypeConfigAttributeName];
    configInfo[@"userInfo"] = [self.config getConfig:LDGeminiUserInfoConfigAttributeName];
    debugInfo[@"configInfo"] = [configInfo copy];

    NSArray *reginstered = [self registeredCaseIds];
    if (!reginstered) {
        debugInfo[@"registeredCaseId"] = @"All caseId is registered!";
    } else if (reginstered.count == 0) {
        debugInfo[@"registeredCaseId"] = @"No registered caseId";
    } else {
        debugInfo[@"registeredCaseId"] = reginstered;
    }

    NSString *jsonString = [self JSONStringForCurrentCaseList];
    debugInfo[@"caseList"] = jsonString;
#endif
    return [debugInfo copy];
}

// MARK: 私有方法
// MARK: getter & setter
- (void)setCache:(NSDictionary *)cache {
    _cache = cache;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cache];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:LDGeminiLocalCaselistKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// MARK: 自定义私有方法
- (void)iSetupGeminiAccessIP:(NSString *)accessIP {
    if (![LDGeminiNetwork isIPAddress:accessIP]) {
        return;
    }
    [_config refreshConfig:@{
                             LDGeminiAccessIPConfigAttributeName : accessIP,
                             }];
}

- (void)iSetupGeminiNetworkStatus:(LDGeminiNetworkStatus)networkStatus {
    NSString *network = @"unknown";
    switch (networkStatus) {
        case LDGeminiNetworkStatus2G:
            network = @"2G";
            break;
        case LDGeminiNetworkStatus3G:
            network = @"3G";
            break;
        case LDGeminiNetworkStatus4G:
            network = @"4G";
            break;
        case LDGeminiNetworkStatusWifi:
            network = @"wifi";
            break;
        default:
            break;
    }
    [_config refreshConfig:@{
                             LDGeminiNetTypeConfigAttributeName : network,
                             }];
}

- (void)iRefreshConfigWithAppKey:(NSString *)appKey deviceId:(NSString *)deviceId userId:(NSString *)userId {
    appKey = appKey ? : @"";
    userId = userId ? : @"";
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    deviceId = deviceId ? : @"";
    NSString *signKey = LDGeminiSignKey;

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *sign = [NSString geminiMD5WithArray:@[deviceId, appKey, timeStamp, userId, signKey]];
    [_config refreshConfig:@{
                              LDGeminiAppKeyConfigAttributeName : appKey,
                              LDGeminiUserIdConfigAttributeName : userId,
                              LDGeminiTimeStampConfigAttributeName : timeStamp,
                              LDGeminiDeviceIDConfigAttributeName : deviceId,
                              LDGeminiSignConfigAttributeName : sign,
                              LDGeminiDeviceTypeConfigAttributeName : LDGeminiDefaultDeviceType,
                              LDGeminiAppversionConfigAttributeName : version
                              }];
    
}

- (BOOL)iHasCache {
    return (self.cache != nil) || ([[NSUserDefaults standardUserDefaults] objectForKey:LDGeminiLocalCaselistKey] != nil);
}

- (void)iAppWillEnterForeground:(NSNotification *)notification {
    if (!self.enableGeminiSDK || !self.enableCacheAutoUpdate) {
        return ;
    }
    if ([self iHasCache]) {
        return ;
    }
    [self asyncUpdateCache:nil];
}

- (void)iAsyncFetchCaseListWithHandler:(LDGeminiServiceHandler)handler {
    if (!self.enableGeminiSDK) {
        NSError *error = [NSError errorWithDomain:LDGeminiSDKDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @"LDGeminiSDK未启动"}];
        if (handler) {
            handler(nil, error);
        }
        return ;
    }
    [LDGeminiService fetchCaseListWithConfig:self.config Completion:handler];
}

- (id)iSyncFetchCaseListWithTimeout:(NSTimeInterval)timeout error:(NSError * _Nullable __autoreleasing *)error {
    if (!self.enableGeminiSDK) {
        NSError *localError = [NSError errorWithDomain:LDGeminiSDKDomain
                                                  code:-1
                                              userInfo:@{NSLocalizedDescriptionKey : @"LDGeminiSDK未启动"}];
        *error = localError;
        return nil;
    }
    return [LDGeminiService syncFetchCaseListWithConfig:self.config timeout:timeout error:error];
}


@end
