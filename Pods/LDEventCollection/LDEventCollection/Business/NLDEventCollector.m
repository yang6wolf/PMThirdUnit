//
//  NLDEventCollector.m
//  LDEventCollection
//
//  Created by SongLi on 5/17/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDEventCollector.h"
#import "NLDEventCollection.h"
#import "NLDEventDefine.h"
#import "NLDDataEntity.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "UIDevice+NLDEventCollection.h"
#import "NLDEventProtocol.h"
#import "NLDEventCache.h"
#import "NLDEventJsonSerializer.h"
#import "NSValue+NLDDescription.h"
#import "NSIndexPath+NLDDescription.h"
#import "NLDSessionProtocol.h"
#import "NSString+NLDAddition.h"
#import "NLDImageUploader.h"
#import "NLDMacroDef.h"
#import "UIApplication+NLDEventCollection.h"
#import "UIGestureRecognizer+NLDEventCollection.h"
#import "UIScrollView+NLDEventCollection.h"
#import "UITableView+NLDEventCollection.h"
#import "UICollectionView+NLDEventCollection.h"
#import "UIWebView+NLDEventCollection.h"
#import "UIViewController+NLDEventCollection.h"
#import "UINavigationController+NLDEventCollection.h"
#import "NLDCheckAppInstall.h"
#import "NLDEventCollectionManager.h"
#import "NLDLocationService.h"
#import "NLDAppInfoUtils.h"
#import "UIViewController+NLDInternalMethod.h"

@interface NLDEventCollector ()
@property (nonatomic, copy, nonnull) NSString *sessionId;
@property (nonatomic, copy, nonnull) NSString *appKey;
@property (nonatomic, copy, nonnull) NSString *deviceId;
@end

@implementation NLDEventCollector

- (instancetype)init
{
    NLDEventCache *nilCache;
    NSString *nilAppKey, *nilDeviceId, *nilChannel;
    return [self initWithEventCache:nilCache appKey:nilAppKey deviceId:nilDeviceId channel:nilChannel];
}

- (nullable instancetype)initWithEventCache:(nonnull NLDEventCache *)eventCache appKey:(nonnull NSString *)appKey deviceId:(nonnull NSString *)deviceId channel:(nonnull NSString *)channel
{
    NSParameterAssert(eventCache && appKey && deviceId && channel);
    if (!eventCache || !appKey || !deviceId || !channel) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _eventCache = eventCache;
        _appKey = appKey;
        _deviceId = deviceId;
        _channel = channel;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppWillTerminal:) name:UIApplicationWillTerminateNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleButtonClickEvent:) name:NLDNotificationButtonClick object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppOpenUrlEvent:) name:NLDNotificationAppOpenUrl object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenTouchEvent:) name:NLDNotificationScreenSingleTouch object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidReceiveRemoteNotification:) name:NLDNotificationReceiveRemoteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollEndDragEvent:) name:NLDNotificationScrollViewWillEndDragging object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollEndZoomEvent:) name:NLDNotificationScrollViewDidEndZooming object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollToTopEvent:) name:NLDNotificationScrollViewDidScrollToTop object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollDidStop:) name:NLDNotificationScrollViewDidStop object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableSelectEvent:) name:NLDNotificationTableViewDidSelectRow object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCollectionSelectEvent:) name:NLDNotificationCollectionViewDidSelectIndexPath object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTapEvent:) name:NLDNotificationTapGesture object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLongPressEvent:) name:NLDNotificationLongPressGesture object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePanEvent:) name:NLDNotificationPanGesture object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSwipeEvent:) name:NLDNotificationSwipeGesture object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWebWillLoadEvent:) name:NLDNotificationWebWillLoadRequest object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWebStartLoadEvent:) name:NLDNotificationWebStartLoad object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWebFinishLoadEvent:) name:NLDNotificationWebFinishLoad object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWebFailLoadEvent:) name:NLDNotificationWebFailedLoad object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushEvent:) name:NLDNotificationPushController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePopEvent:) name:NLDNotificationPopController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePopToEvent:) name:NLDNotificationPopToController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePopToRootEvent:) name:NLDNotificationPopToRoot object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePresentEvent:) name:NLDNotificationPresentController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDismissEvent:) name:NLDNotificationDismissController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewControllerEvent:) name:NLDNotificationNewController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShowControllerEvent:) name:NLDNotificationShowController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidShowControllerEvent:) name:NLDNotificationDidShowController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHideControllerEvent:) name:NLDNotificationHideController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDestoryControllerEvent:) name:NLDNotificationDestoryController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCheckAppInstallListEvent:) name:NLDNotificationAppInstallList object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleABTest:) name:NLDNotificationABTest object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationUpload:) name:NLDNotificationLocationUpload object:nil];
        
        NSString *timeStamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
        _sessionId = [[NSString stringWithFormat:@"%@_%@", self.deviceId, timeStamp] NLD_md5String];
        
        [self handleAppDidStart];
        
        // 设置webView的UserAgent
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *originalUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString *newUserAgent = [NSString stringWithFormat:@"%@ LsessionId/%@ LdeviceId/%@", originalUserAgent, _sessionId, _deviceId];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": newUserAgent}];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addEventName:(nonnull NSString *)eventName withParams:(nullable NSDictionary<NSString *, NSString *> *)params
{
    NLDDataEntity<NLDUserOptionalEvent> *event = [[NLDDataEntity<NLDUserOptionalEvent> alloc] initWithProtocol:@protocol(NLDUserOptionalEvent)];
    event.eventName = eventName;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.item = [self addionInfoArrayWithDict:params];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到用户自定义事件名：%@ \n 参数信息：%@", eventName, [event toDictionary]);
}


#pragma mark - Events Handler

- (void)handleAppDidStart
{
    UIDevice *device = [UIDevice currentDevice];
    NLDDataEntity<NLDAppColdStartEvent> *event = [[NLDDataEntity<NLDAppColdStartEvent> alloc] initWithDictionary:nil protocol:@protocol(NLDAppColdStartEvent)];
    event.eventName = NLDEventAppStart;
    event.eventTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.sessionId = self.sessionId;
    event.idfa = [NLDAppInfoUtils idfa];
    event.deviceId = self.deviceId;
    event.deviceModel = [device NLD_deviceModel];
    event.screenResolution = [device NLD_screenResolution];
    event.totalMemory = [device NLD_totalMemorySizeString];
    event.avalibleMemory = [device NLD_availableMemorySizeString];
    event.appMemory = [device NLD_currentAppMemorySizeString];
    event.totalDisk = [device NLD_totalDiskSizeString];
    event.avalibleDisk = [device NLD_availableDiskSizeString];
    event.batteryLevel = [device NLD_batteryLevelString];
    event.carrier = [device NLD_carrier];
    event.systemName = [device systemName];
    event.systemVersion = [device systemVersion];
    event.appKey = self.appKey;
    event.appBundle = [NLDAppInfoUtils appBundle];
    event.appVersion = [NLDAppInfoUtils appVersion];
    event.appBuildVersion = [NLDAppInfoUtils appBuildVersion];
    event.channel = self.channel;
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

- (void)handleLocationUpload:(NSNotification *)notification
{
    // 获取位置信息
    [[NLDLocationService sharedService] startUpdateLocationWithCompletionHandler:^(NSString * _Nonnull longitude, NSString * _Nonnull latitude, NSString * _Nonnull altitude) {
        [self addLocationEventWithLongitude:longitude latitude:latitude altitude:altitude];
    }];
}

- (void)handleAppDidFinishLaunching:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    if (userInfo && userInfo[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        LDECLog(@"用户点击推送消息启动了应用");
        [self addPushMsgClickEventWithInfo:userInfo[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
/* 暂时不统计该事件
    UIDevice *device = [UIDevice currentDevice];
    NLDDataEntity<NLDSessionEvent> *event = [[NLDDataEntity<NLDSessionEvent> alloc] initWithDictionary:nil protocol:@protocol(NLDSessionEvent)];
    event.eventName = NLDEventAppFinishLaunching;
    event.eventTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.deviceId = self.deviceId;
    event.appKey = self.appKey;
    [self.eventCache addEvent:event];
*/
}

- (void)addLocationEventWithLongitude:(NSString *)longitude
                             latitude:(NSString *)latitude
                             altitude:(NSString *)altitude
{
    NLDDataEntity<NLDLocationEvent> *event = [[NLDDataEntity<NLDLocationEvent> alloc] initWithProtocol:@protocol(NLDLocationEvent)];
    event.eventName = NLDEventLocation;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.eventTime = timeStamp;
    event.longitude = longitude;
    event.latitude = latitude;
    event.altitude = altitude;
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

- (void)handleDidReceiveRemoteNotification:(NSNotification *)notification
{
    LDECLog(@"用户在后台点击了推送消息");
    NSDictionary *userInfo = notification.userInfo;
    [self addPushMsgClickEventWithInfo:userInfo];
}

- (void)addPushMsgClickEventWithInfo:(NSDictionary *)userInfo
{
    NLDDataEntity<NLDPushMsgClickEvent> *event = [[NLDDataEntity<NLDPushMsgClickEvent> alloc] initWithProtocol:@protocol(NLDPushMsgClickEvent)];
    event.eventName = NLDEventPushMsgClick;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.eventTime = timeStamp;
    NSString *content = @"";
    id alert = userInfo[@"aps"][@"alert"];
    if ([alert isKindOfClass:[NSString class]]) {
        content = [alert copy];
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        content = [alert[@"body"] copy];
    }
    event.content = content;
    event.uri = userInfo[@"url"];
    event.jobId = userInfo[@"jobId"];
    [self.eventCache addEvent:event];

    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

- (void)handleAppEnterForeground:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    NLDDataEntity<NLDAppEnterForeBackgroundEvent> *event = [[NLDDataEntity<NLDAppEnterForeBackgroundEvent> alloc] initWithDictionary:nil protocol:@protocol(NLDAppEnterForeBackgroundEvent)];
    event.eventName = NLDEventAppEnterForeground;
    event.eventTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.avalibleMemory = [device NLD_availableMemorySizeString];
    event.appMemory = [device NLD_currentAppMemorySizeString];
    event.avalibleDisk = [device NLD_availableDiskSizeString];
    event.appKey = self.appKey;
    event.channel = self.channel;
    [self.eventCache addEvent:event];
    
    // 获取位置信息
    if ([NLDLocationService sharedService].isEnableLocation) {
        [[NLDLocationService sharedService] startUpdateLocationWithCompletionHandler:^(NSString * _Nonnull longitude, NSString * _Nonnull latitude, NSString * _Nonnull altitude) {
            [self addLocationEventWithLongitude:longitude latitude:latitude altitude:altitude];
        }];
    }
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

- (void)handleAppDidRecieveUncaughtException
{
/* 暂时不统计该事件
    UIDevice *device = [UIDevice currentDevice];
    NLDDataEntity<NLDSessionEvent> *event = [[NLDDataEntity<NLDSessionEvent> alloc] initWithDictionary:nil protocol:@protocol(NLDSessionEvent)];
    event.eventName = NLDEventAppThrowUncaughtException;
    event.eventTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.sessionId = self.sessionId;
    event.idfa = [device NLD_idfa];
    event.deviceId = self.deviceId;
    event.deviceModel = [device NLD_deviceModel];
    event.screenResolution = [device NLD_screenResolution];
    event.totalMemory = [device NLD_totalMemorySizeString];
    event.avalibleMemory = [device NLD_availableMemorySizeString];
    event.appMemory = [device NLD_currentAppMemorySizeString];
    event.totalDisk = [device NLD_totalDiskSizeString];
    event.avalibleDisk = [device NLD_availableDiskSizeString];
    event.batteryLevel = [device NLD_batteryLevelString];
    event.carrier = [device NLD_carrier];
    event.systemName = [device systemName];
    event.systemVersion = [device systemVersion];
    event.appKey = self.appKey;
    event.appBundle = [[self class] appBundle];
    event.appVersion = [[self class] appVersion];
    event.appBuildVersion = [[self class] appBuildVersion];
    event.channel = self.channel;
    [self.eventCache addEvent:event];
 */
}

- (void)handleAppEnterBackground:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    NLDDataEntity<NLDAppEnterForeBackgroundEvent> *event = [[NLDDataEntity<NLDAppEnterForeBackgroundEvent> alloc] initWithDictionary:nil protocol:@protocol(NLDAppEnterForeBackgroundEvent)];
    event.eventName = NLDEventAppEnterBackground;
    event.eventTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.avalibleMemory = [device NLD_availableMemorySizeString];
    event.appMemory = [device NLD_currentAppMemorySizeString];
    event.avalibleDisk = [device NLD_availableDiskSizeString];
    event.appKey = self.appKey;
    event.channel = self.channel;
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

- (void)handleAppWillTerminal:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    NLDDataEntity<NLDAppEnterForeBackgroundEvent> *event = [[NLDDataEntity<NLDAppEnterForeBackgroundEvent> alloc] initWithDictionary:nil protocol:@protocol(NLDAppEnterForeBackgroundEvent)];
    event.eventName = NLDEventAppTerminal;
    event.eventTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.avalibleMemory = [device NLD_availableMemorySizeString];
    event.appMemory = [device NLD_currentAppMemorySizeString];
    event.avalibleDisk = [device NLD_availableDiskSizeString];
    event.appKey = self.appKey;
    event.channel = self.channel;
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationButtonClick
- (void)handleButtonClickEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDViewClickEvent> *event = [[NLDDataEntity<NLDViewClickEvent> alloc] initWithProtocol:@protocol(NLDViewClickEvent)];
//    event.eventName = NLDEventButtonClick;
    event.eventName = NLDEventViewClick;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];
    event.view.title = userInfo[@"viewTitle"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationAppOpenUrl
- (void)handleAppOpenUrlEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDAppUrlEvent> *event = [[NLDDataEntity<NLDAppUrlEvent> alloc] initWithProtocol:@protocol(NLDAppUrlEvent)];
    event.eventName = NLDEventAppOpenUrl;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.url = [userInfo[@"url"] absoluteString];
    event.succeed = [userInfo[@"succeed"] boolValue] ? @"1" : @"0";
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationScreenSingleTouch
- (void)handleScreenTouchEvent:(NSNotification *)notification
{
/* 暂时不统计该事件
    NSDictionary *userInfo = notification.userInfo;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:NLDEventScreenTouch forKey:NLDEventParamEventName];
    [dict setValue:self.appKey forKey:NLDEventParamAppKey];
    [dict setValue:self.deviceId forKey:NLDEventParamDeviceId];
    [dict setValue:userInfo[@"timeStamp"] forKey:NLDEventParamTimeStamp];
    [dict setValue:userInfo[@"controller"] ?: @"" forKey:NLDEventParamController];
    NSString *point = [[NSValue valueWithCGPoint:[userInfo[@"touch"] previousLocationInView:nil]] NLD_CGPointDescription];
    [dict setValue:point forKey:NLDEventParamPoint];
    [dict setValue:[NSMutableDictionary dictionary] forKey:NLDEventParamView];
    
    [dict[NLDEventParamView] setValue:[userInfo[@"view"] forKey:NLDEventParamClass];
    [dict[NLDEventParamView] setValue:[userInfo[@"viewFrame"] NLD_CGRectDescription] forKey:NLDEventParamFrame];
    [dict[NLDEventParamView] setValue:userInfo[@"viewPath"] forKey:NLDEventParamPath];
    
    NLDDataEntity<NLDEvent> *event = [[NLDDataEntity<NLDEvent> alloc] initWithDictionary:dict protocol:@protocol(NLDEvent)];
    [self.eventCache addEvent:event];
 */
}

/// NLDNotificationScrollViewWillEndDragging
- (void)handleScrollEndDragEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDScrollViewEvent> *event = [[NLDDataEntity<NLDScrollViewEvent> alloc] initWithProtocol:@protocol(NLDScrollViewEvent)];
    event.eventName = NLDEventScrollViewDrag;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.direction = [userInfo[@"velocity"] NLD_CGPointDescription];
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationScrollViewDidEndZooming
- (void)handleScrollEndZoomEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDScrollViewEvent> *event = [[NLDDataEntity<NLDScrollViewEvent> alloc] initWithProtocol:@protocol(NLDScrollViewEvent)];
    event.eventName = NLDEventScrollViewZoom;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.scale = [userInfo[@"scale"] description];
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationScrollViewDidScrollToTop
- (void)handleScrollToTopEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDScrollViewEvent> *event = [[NLDDataEntity<NLDScrollViewEvent> alloc] initWithProtocol:@protocol(NLDScrollViewEvent)];
    event.eventName = NLDEventScrollViewToTop;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationScrollViewDidStop
- (void)handleScrollDidStop:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDListItemScanEvent> *event = [[NLDDataEntity<NLDListItemScanEvent> alloc] initWithProtocol:@protocol(NLDListItemScanEvent)];
    event.eventName = NLDEventTableViewScan;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    event.show = [self addionInfoArrayWithDict:userInfo[@"show"]];
    event.hide = [self addionInfoArrayWithDict:userInfo[@"hide"]];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationTableViewDidSelectRow
- (void)handleTableSelectEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDListItemClickEvent> *event = [[NLDDataEntity<NLDListItemClickEvent> alloc] initWithProtocol:@protocol(NLDListItemClickEvent)];
    event.eventName = NLDEventTableViewSelect;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.indexPath = userInfo[@"indexPath"];
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.view.title = userInfo[@"viewTitle"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationCollectionViewDidSelectIndexPath
- (void)handleCollectionSelectEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDListItemClickEvent> *event = [[NLDDataEntity<NLDListItemClickEvent> alloc] initWithProtocol:@protocol(NLDListItemClickEvent)];
    event.eventName = NLDEventCollectionViewSelect;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.indexPath = userInfo[@"indexPath"];
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];;
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationTapGesture
- (void)handleTapEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDViewClickEvent> *event = [[NLDDataEntity<NLDViewClickEvent> alloc] initWithProtocol:@protocol(NLDViewClickEvent)];
    event.eventName = NLDEventViewClick;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];;
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationLongPressGesture
- (void)handleLongPressEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDViewClickEvent> *event = [[NLDDataEntity<NLDViewClickEvent> alloc] initWithProtocol:@protocol(NLDViewClickEvent)];
    event.eventName = NLDEventViewLongPress;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];
    event.view = [[NLDDataEntity<NLDEventParamView> alloc] initWithProtocol:@protocol(NLDEventParamView)];
    event.view.viewClass = userInfo[@"view"];
    event.view.frame = [(NSValue *)userInfo[@"viewFrame"] NLD_CGRectDescription];
    event.view.path = userInfo[@"viewPath"];
    event.view.depthPath = userInfo[@"viewDepthPath"];
    event.view.viewId = userInfo[@"viewId"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationPanGesture
- (void)handlePanEvent:(NSNotification *)notification
{
    
}

/// NLDNotificationSwipeGesture
- (void)handleSwipeEvent:(NSNotification *)notification
{
    
}

/// NLDNotificationWebWillLoadRequest
- (void)handleWebWillLoadEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDWebViewEvent> *event = [[NLDDataEntity<NLDWebViewEvent> alloc] initWithProtocol:@protocol(NLDWebViewEvent)];
    event.eventName = NLDEventWebLoad;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.url = userInfo[@"requestUrl"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationWebStartLoad
- (void)handleWebStartLoadEvent:(NSNotification *)notification
{
    
}

/// NLDNotificationWebFinishLoad
- (void)handleWebFinishLoadEvent:(NSNotification *)notification
{
    
}

/// NLDNotificationWebFailedLoad
- (void)handleWebFailLoadEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDWebViewEvent> *event = [[NLDDataEntity<NLDWebViewEvent> alloc] initWithProtocol:@protocol(NLDWebViewEvent)];
    event.eventName = NLDEventWebLoad;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.url = userInfo[@"requestUrl"];
    event.error = userInfo[@"error"];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationPushController
- (void)handlePushEvent:(NSNotification *)notification
{
/* 暂时不统计该事件
    NSDictionary *userInfo = notification.userInfo;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:NLDEventPushController forKey:NLDEventParamEventName];
    [dict setValue:self.appKey forKey:NLDEventParamAppKey];
    [dict setValue:self.deviceId forKey:NLDEventParamDeviceId];
    [dict setValue:userInfo[@"timeStamp"] forKey:NLDEventParamTimeStamp];
    [dict setValue:userInfo[@"controller"] ?: @"" forKey:NLDEventParamController];
    [dict setValue:userInfo[@"addition"] forKey:NLDEventParamItem];
    
    NLDDataEntity<NLDEvent> *event = [[NLDDataEntity<NLDEvent> alloc] initWithDictionary:dict protocol:@protocol(NLDEvent)];
    [self.eventCache addEvent:event];
 */
}

/// NLDNotificationPopController
- (void)handlePopEvent:(NSNotification *)notification
{
/* 暂时不统计该事件
    NSDictionary *userInfo = notification.userInfo;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:NLDEventPopController forKey:NLDEventParamEventName];
    [dict setValue:self.appKey forKey:NLDEventParamAppKey];
    [dict setValue:self.deviceId forKey:NLDEventParamDeviceId];
    [dict setValue:userInfo[@"timeStamp"] forKey:NLDEventParamTimeStamp];
    [dict setValue:userInfo[@"controller"] ?: @"" forKey:NLDEventParamController];
    [dict setValue:userInfo[@"addition"] forKey:NLDEventParamItem];
    
    NLDDataEntity<NLDEvent> *event = [[NLDDataEntity<NLDEvent> alloc] initWithDictionary:dict protocol:@protocol(NLDEvent)];
    [self.eventCache addEvent:event];
 */
}

/// NLDNotificationPopToController
- (void)handlePopToEvent:(NSNotification *)notification
{
    
}

/// NLDNotificationPopToRoot
- (void)handlePopToRootEvent:(NSNotification *)notification
{
    
}

/// NLDNotificationPresentController
- (void)handlePresentEvent:(NSNotification *)notification
{
/* 暂时不统计该事件
    NSDictionary *userInfo = notification.userInfo;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:NLDEventPresentController forKey:NLDEventParamEventName];
    [dict setValue:self.appKey forKey:NLDEventParamAppKey];
    [dict setValue:self.deviceId forKey:NLDEventParamDeviceId];
    [dict setValue:userInfo[@"timeStamp"] forKey:NLDEventParamTimeStamp];
    [dict setValue:userInfo[@"presentController"] ?: @"" forKey:NLDEventParamController];
    [dict setValue:userInfo[@"controller"] ?: @"" forKey:NLDEventParamFromController];
    [dict setValue:userInfo[@"addition"] forKey:NLDEventParamItem];
    
    NLDDataEntity<NLDEvent> *event = [[NLDDataEntity<NLDEvent> alloc] initWithDictionary:dict protocol:@protocol(NLDEvent)];
    [self.eventCache addEvent:event];
 */
}

/// NLDNotificationDismissController
- (void)handleDismissEvent:(NSNotification *)notification
{
/* 暂时不统计该事件
    NSDictionary *userInfo = notification.userInfo;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:NLDEventDismissController forKey:NLDEventParamEventName];
    [dict setValue:self.appKey forKey:NLDEventParamAppKey];
    [dict setValue:self.deviceId forKey:NLDEventParamDeviceId];
    [dict setValue:userInfo[@"timeStamp"] forKey:NLDEventParamTimeStamp];
    [dict setValue:userInfo[@"dismissController"] ?: @"" forKey:NLDEventParamController];
    [dict setValue:userInfo[@"controller"] ?: @"" forKey:NLDEventParamFromController];
    [dict setValue:userInfo[@"addition"] forKey:NLDEventParamItem];
    
    NLDDataEntity<NLDEvent> *event = [[NLDDataEntity<NLDEvent> alloc] initWithDictionary:dict protocol:@protocol(NLDEvent)];
    [self.eventCache addEvent:event];
 */
}

/// NLDNotificationNewController
- (void)handleNewControllerEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDPageEvent> *event = [[NLDDataEntity<NLDPageEvent> alloc] initWithProtocol:@protocol(NLDPageEvent)];
    event.eventName = NLDEventNewController;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];;
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationShowController
- (void)handleShowControllerEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDPageEvent> *event = [[NLDDataEntity<NLDPageEvent> alloc] initWithProtocol:@protocol(NLDPageEvent)];
    event.eventName = NLDEventShowController;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];;
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationDidShowController
- (void)handleDidShowControllerEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([NLDImageUploader sharedUploader].isEnableUpload) {
        // 获取截图并上传
        if (userInfo[@"controller"]) {
            __block UIImage *screenImage = nil;
            dispatch_sync(dispatch_get_main_queue(), ^{
                screenImage = [UIViewController currentPageScreenShot];
            });
            NSString *imageName = userInfo[@"controller"];
            [[NLDImageUploader sharedUploader] uploadImage:screenImage fileName:imageName type:NLDAutoScreenshot];
        }
    }
}

/// NLDNotificationHideController
- (void)handleHideControllerEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDPageEvent> *event = [[NLDDataEntity<NLDPageEvent> alloc] initWithProtocol:@protocol(NLDPageEvent)];
    event.eventName = NLDEventHideController;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];;
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationDestoryController
- (void)handleDestoryControllerEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDPageEvent> *event = [[NLDDataEntity<NLDPageEvent> alloc] initWithProtocol:@protocol(NLDPageEvent)];
    event.eventName = NLDEventDestoryController;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    event.eventTime = userInfo[@"timeStamp"];
    event.page = userInfo[@"controller"] ?: @"";
    event.item = [self addionInfoArrayWithDict:userInfo[@"addition"]];;
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationAppInstallList
- (void)handleCheckAppInstallListEvent:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDAppInstallListEvent> *event = [[NLDDataEntity<NLDAppInstallListEvent> alloc] initWithProtocol:@protocol(NLDAppInstallListEvent)];
    event.eventName = NLDEventAppInstallList;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.eventTime = timeStamp;
    event.item = [self addionInfoArrayWithDict:userInfo];
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

/// NLDNotificationABTest
- (void)handleABTest:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NLDDataEntity<NLDABTestEvent> *event = [[NLDDataEntity<NLDABTestEvent> alloc] initWithProtocol:@protocol(NLDABTestEvent)];
    event.eventName = NLDEventABTest;
    event.appKey = self.appKey;
    event.sessionId = self.sessionId;
    event.deviceId = self.deviceId;
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    event.eventTime = timeStamp;
    event.content = userInfo[@"content"] ?: @"";
    [self.eventCache addEvent:event];
    
    LDECLog(@"收集到事件名：%@ \n 参数信息：%@", event.eventName, [event toDictionary]);
}

#pragma mark - Helper

- (NSArray *)addionInfoArrayWithDict:(NSDictionary<NSString *, NSString *> *)dict
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dict.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [array addObject:@{key:obj}];
    }];
    return array.copy;
}

@end
