//
//  NLDEventCollectionManager.m
//  LDEventCollection
//
//  Created by SongLi on 5/26/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDEventCollectionManager.h"
#import "NLDEventCollector.h"
#import "NLDEventUploader.h"
#import "NLDEventCache.h"
#import "NLDEventCache+NLDAppLifeCycle.h"
#import "NLDEventProtoBufSerializer.h"
#import "NLDImageUploader.h"
#import "NLDCheckAppInstall.h"
#import "NSObject+NLDPerformSelector.h"
#import "NLDManualTool.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import "NLDLocationService.h"
#import "NLDRemoteEventManager.h"
#import "NLDRNPageManager.h"

NLDNotificationNameDefine(NLDNotificationABTest)

NSUInteger NLDUploaderBufferSize = 10;
NSTimeInterval NLDUploaderTimeInterval = 30;

@interface NLDEventCollectionManager ()
@property (nonatomic, strong) NLDEventCache *eventCache; // 注意！NLDEventCache+NLDAppLifeCycle中的调用！
@property (nonatomic, strong) NLDEventCollector *eventCollector; // 注意！NLDEventCache+NLDAppLifeCycle中的调用！
@property (nonatomic, strong) NLDEventUploader *eventUploader;

@end

@implementation NLDEventCollectionManager

+ (instancetype)sharedManager
{
    static NLDEventCollectionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setAppKey:(nonnull NSString *)appKey deviceId:(nonnull NSString *)deviceId channel:(nonnull NSString *)channel
{
    [self setAppKey:appKey deviceId:deviceId channel:channel eventDomain:nil imageDomain:nil];
}

- (void)setAppKey:(nonnull NSString *)appKey deviceId:(nonnull NSString *)deviceId channel:(nonnull NSString *)channel eventDomain:(nullable NSString *)eventUploadDomain imageDomain:(nullable NSString *)imageUploadDomain
{
    NSParameterAssert(appKey && deviceId && channel);
    if (!appKey || !deviceId || !channel) {
        return;
    }
    
    if (_eventCache && _eventCollector && _eventUploader) {
        return;
    }
    
#ifndef LDEC_CLOSE_METHOD_SWIZZLE
    // 临时逻辑，等待稳定后去除
    Class cls = NSClassFromString(@"NLDSwizzLoader");
    SEL sel = NSSelectorFromString(@"swizz");
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel];
#pragma clang diagnostic pop
    }
#endif
    
    [[NLDRemoteEventManager sharedManager] setAppKey:appKey domain:eventUploadDomain ?: @"http://adc.163.com/"];
    
    _eventCache = [[NLDEventCache alloc] initWithSerializer:[[NLDEventProtoBufSerializer alloc] init]];
    _eventCollector = [[NLDEventCollector alloc] initWithEventCache:_eventCache appKey:appKey deviceId:deviceId channel:channel];
    _eventUploader = [[NLDEventUploader alloc] initWithEventCache:_eventCache domain:eventUploadDomain ?: @"http://adc.163.com/"];
    
    [[NLDImageUploader sharedUploader] setDomain:imageUploadDomain ?: @"http://data.ms.netease.com/"];
    [[NLDImageUploader sharedUploader] setAppKey:appKey];
    
    [_eventUploader startUploadWithBufferSize:NLDUploaderBufferSize];  // 开启 每累积 10 个事件上传一次
    [_eventUploader startUploadWithDuration:NLDUploaderTimeInterval];  // 开启 每隔 30s 上传一次
    
    // 程序进入前台时，将保存的本地文件上传
    [_eventUploader uploadLocalFiles]; // 程序启动时，手动触发一次
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDataOnForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // 程序进入后台时，将数据保存至本地，并上传
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDataOnBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)setChannel:(NSString *)channel
{
    _eventCollector.channel = channel;
}

- (void)setCheckAppList:(nonnull NSArray<NSString *> *)checkAppList
{
    [NLDCheckAppInstall startCheckAppInstallWithList:checkAppList];
}

- (void)addEventName:(nonnull NSString *)eventName withParams:(nullable NSDictionary<NSString *, NSString *> *)params
{
    if (!_eventCollector) {
        return;
    }
    [_eventCollector addEventName:eventName withParams:params];
}

- (void)setupUncaughtExceptionHandler
{
    [_eventCache setupUncaughtExceptionHandler];
}

- (void)uploadDataOnBackground
{
    [_eventUploader uploadAllEventsOnBackground];
}

- (void)uploadDataOnForeground
{
    [_eventUploader uploadLocalFiles];
}

- (void)setEnableLocationUpload:(BOOL)isEnable
{
    [[NLDLocationService sharedService] setEnableLocation:isEnable];
}

- (void)setEnablePageUpload:(BOOL)isEnable
{
    [[NLDImageUploader sharedUploader] setEnableUpload:isEnable];
}

- (void)setAdditionalData:(nullable NSDictionary<NSString *, NSString *> *)data forObject:(NSObject *)object
{
    [object setAdditionalData:data];
}

- (void)RN_viewWillAppearWithComponentName:(NSString *)componentName
{
    [[NLDRNPageManager defaultManager] RN_viewWillAppearWithComponentName:componentName];
}

- (void)setManualToolShow:(BOOL)show {
    static NSInteger orignalPageUpload = -1;
    if (orignalPageUpload == -1) {
        orignalPageUpload = [[NLDImageUploader sharedUploader] isEnableUpload] ? 1 : 0;
    }
    if (show) {
        orignalPageUpload = [[NLDImageUploader sharedUploader] isEnableUpload] ? 1 : 0;
        [self setEnablePageUpload:NO];
        [[NLDManualTool sharedManualTool] setBaseWindow:[[UIApplication sharedApplication] keyWindow]];  
        [[NLDManualTool sharedManualTool] showManualTool];
    } else {
        [self setEnablePageUpload:(orignalPageUpload == 1)];
        [[NLDManualTool sharedManualTool] hiddenManualTool];
    }
}

- (void)setABTestContent:(nonnull NSString *)content
{
    [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationABTest object:nil userInfo:@{@"content": content}];
    
//    NSError *error = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contentDict options:0 error:&error];
//    if (error) {
//        return;
//    }
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/* 暂时关闭
- (void)setManualToolBaseWindow:(UIWindow *)window {
    [[NLDManualTool sharedManualTool] setBaseWindow:window];
}
 */

@end
