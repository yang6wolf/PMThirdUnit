//
//  NLDEventProtocol.h
//  LDEventCollection
//
//  Created by SongLi on 5/17/16.
//  Copyright © 2016 netease. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import "NLDSessionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 参数View类型

@class NLDDataEntity;
@protocol NLDEventParamView
/// View信息
@property (nonatomic, strong) NSString *viewClass;
/// View路径
@property (nonatomic, strong) NSString *path;
/// View位置大小
@property (nonatomic, strong) NSString *frame;
/// View文子
@property (nonatomic, strong) NSString *title;
/// ViewDepthPath
@property (nonatomic, strong) NSString *depthPath;
/// ViewId
@property (nonatomic, strong) NSString *viewId;
@end

#pragma mark - 公共Event字段

@protocol NLDEvent <NSObject>
/// 事件名
@property (nonatomic, strong) NSString *eventName;
/// 事件时间 TimeStamp
@property (nonatomic, strong) NSString *eventTime;
/// SessionId
@property (nonatomic, strong) NSString *sessionId;
/// AppKey
@property (nonatomic, strong) NSString *appKey;
/// Custom DeviceId
@property (nonatomic, strong) NSString *deviceId;
@end


#pragma mark - AppColdStartEvent

@protocol NLDAppColdStartEvent <NLDEvent, NLDSession>
@end


#pragma mark - AppEnterForeBackgroundEvent

@protocol NLDAppEnterForeBackgroundEvent <NLDEvent>
/// 剩余内存
@property (nonatomic, strong) NSString *avalibleMemory;
/// 此App占用内存
@property (nonatomic, strong) NSString *appMemory;
/// 剩余磁盘
@property (nonatomic, strong) NSString *avalibleDisk;
/// 渠道号
@property (nonatomic, strong) NSString *channel;

@end


#pragma mark - ViewClickEvent

@protocol NLDViewClickEvent <NLDEvent>
/// 当前Controller
@property (nonatomic, strong) NSString *page;
/// 当前View
@property (nonatomic, strong) NLDDataEntity<NLDEventParamView> *view;
/// 附加信息
@property (nonatomic, strong) NSArray *item;
@end


#pragma mark - ScrollViewEvent

@protocol NLDScrollViewEvent <NLDEvent>
/// 当前Controller
@property (nonatomic, strong) NSString *page;
/// 放大倍数
@property (nonatomic, strong) NSString *scale;
/// 滑动方向
@property (nonatomic, strong) NSString *direction;
/// 当前View
@property (nonatomic, strong) NLDDataEntity<NLDEventParamView> *view;
@end

#pragma mark - ListItemScanEvent

@protocol NLDListItemScanEvent <NLDEvent>
/// 当前Controller
@property (nonatomic, strong) NSString *page;
/// 当前View
@property (nonatomic, strong) NLDDataEntity<NLDEventParamView> *view;
/// 隐藏的cell
@property (nonatomic, strong) NSArray *hide;
/// 当前显示的cell
@property (nonatomic, strong) NSArray *show;
/// 附加信息
@property (nonatomic, strong) NSArray *item;
@end


#pragma mark - ListItemClickEvent

@protocol NLDListItemClickEvent <NLDEvent>
/// 当前Controller
@property (nonatomic, strong) NSString *page;
/// IndexPath
@property (nonatomic, strong) NSString *indexPath;
/// 当前View
@property (nonatomic, strong) NLDDataEntity<NLDEventParamView> *view;
/// 附加信息
@property (nonatomic, strong) NSArray *item;
@end


#pragma mark - PageEvent

@protocol NLDPageEvent <NLDEvent>
/// 当前Controller
@property (nonatomic, strong) NSString *page;
/// 附加信息
@property (nonatomic, strong) NSArray *item;
@end


#pragma mark - AppUrlEvent

@protocol NLDAppUrlEvent <NLDEvent>
/// 要跳转的Url
@property (nonatomic, strong) NSString *url;
/// 是否成功 1:成功 0:失败
@property (nonatomic, strong) NSString *succeed;
@end


#pragma mark - WebViewEvent

@protocol NLDWebViewEvent <NLDEvent>
/// 当前Controller
@property (nonatomic, strong) NSString *page;
/// 要跳转的Url
@property (nonatomic, strong) NSString *url;
/// 失败原因
@property (nonatomic, strong) NSString *error;
@end


#pragma mark - UserOptionalEvent

@protocol NLDUserOptionalEvent <NLDEvent>
/// 用户信息
@property (nonatomic, strong) NSArray *item;
@end

#pragma mark - AppInstallListEvent

@protocol NLDAppInstallListEvent <NLDEvent>
/// App安装列表
@property (nonatomic, strong) NSArray *item;
@end

#pragma mark - PushMsgClickEvent

@protocol NLDPushMsgClickEvent <NLDEvent>
/// 推送内容
@property (nonatomic, strong) NSString *content;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSString *jobId;
@property (nonatomic, strong) NSArray *item;
@end

#pragma mark - ABTestEvent

@protocol NLDABTestEvent <NLDEvent>
/// AB测试方案
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSArray *item;
@end

#pragma mark - LocationEvent

@protocol NLDLocationEvent <NLDEvent>
/// 位置信息
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *altitude;
@property (nonatomic, copy) NSString *accuracy;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, strong) NSArray *item;
@end

NS_ASSUME_NONNULL_END
