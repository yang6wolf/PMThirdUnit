//
//  MobileAgent.h
//  NeteaseStatistics
//
//  Created by zhang jie on 13-4-12.
//  Copyright (c) 2013年 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SDK_VERSION  4

extern NSString * const kNeteaseMAOnlineAppConfigLoadNotification;
extern NSString *const kNeteaseMAOnlineAppConfigKey; //notification的userinfo里onlineAppConfig对应的key
extern NSString *const kNeteaseMAStartOverNotification; //第一个controller显示结束通知，可以将一些耗时必须在主线程完成的task放在这里面做

@protocol NetEaseMobileAgentDelegate <NSObject>
@optional
/**
 * 是否需要检测某个url请求的性能，内部已经过滤掉了host不包含“163”或"126"的url
 *
 * 具体产品代码，可能需要过滤图片的url
 *
 * 注意这个方法不保证在主线程被调用，实现必须快速返回，否则可能影响网络请求的速度
 */
- (BOOL)neteaseMobileAgentShouldProbleUrl:(NSURL*)url;

/**
 *  通过域名来置换IP
 */
- (NSString *)neteaseMobileAgentGetIPbyDomain:(NSString *)domain;

/** 
 *  是否保持当前session。
 *  默认YES
 */
- (BOOL)neteaseMobileManagerShouldSaveSession;
@end

@interface NetEaseMobileAgent : NSObject
@property(nonatomic,strong) NSString *ursId; //用户的登录帐号,如果有的话请设置
@property(nonatomic,strong) NSString *extra; //额外参数，预留字段
@property(nonatomic,readonly) NSDictionary *onlineAppConfig; //在线参数配置
@property(nonatomic,strong) NSArray *spdyHostConfig; //使用SPDY的host列表
@property(nonatomic,weak) id<NetEaseMobileAgentDelegate> delegate;

+ (NetEaseMobileAgent *)sharedInstance;

//程序启动时（使用该类的其他接口前，应该设置appId和渠道,且只能设置一次
//@param deviceId, 由于不同的产品可能采用不同的deviceId方案，因此不再自动获取deviceId

-(void)setAppId:(NSString *)appId andChannel:(NSString*)channel andDeviceId:(NSString*)deviceId;
-(void)resetChannel:(NSString *)channel;
- (void)reconnectionAppbiData;

/**
 *  app中自定义的NSURLProtocol的类名，NeteaseMASessionHTTPProtocol内部采用NSURLSession实现，需要将NSURLProtocol的类名都设置进去
 *  注意：NSURLProtocol的startloading方法中，会重新创建一次request请求
 *  而针对使用NSURLSession实现，对新请求的拦截顺序，跟此处protocolClassNames中类名的顺序有关
 *  一般情况下，我们按照registerClass的倒序来作为设定protocolClassNames的顺序
 */
- (void)setProtocolClassNames:(NSArray<Class> *)protocolClassNames;
- (NSArray *)getAllProtocolClassNames;

/**
 *  设置诊断域名
 */
- (void)setAnalysisHost:(NSString *)host;
- (NSString *)getAnalysisHost;


- (void)addEvent:(NSString *)name param:(NSString *)param extra:(NSString *)extra;
- (void)addEvent:(NSString *)name param:(NSString *)param;

//exepect id<CLSCrashReport>
- (void)reportCrash:(id)crash;
- (void)reportSessionPfmData;

// diagnose log
- (void)setupDiagnose:(NSArray *)params;
- (void)addDiagnoseLog:(NSString *)log tag:(NSString *)tag;
@end
