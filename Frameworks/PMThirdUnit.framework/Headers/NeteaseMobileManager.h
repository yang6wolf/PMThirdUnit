//
//  NeteaseMobileManager.h
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/14/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CLSCrashReport;

@protocol NetEaseMobileManagerDelegate <NSObject>
- (BOOL)neteaseMobileManagerShouldProbleUrl:(NSURL*)url;
/** 是否保持当前session，默认YES */
- (BOOL)neteaseMobileManagerShouldSaveSession;

- (NSString *)neteaseMobileManagerGetIPbyDomain:(NSString *)domain;
@end


@interface NeteaseMobileManager : NSObject
@property(nonatomic,strong) NSString *appId;
@property(nonatomic,strong) NSString *channel;
@property(nonatomic,strong) NSString *deviceId;
@property(nonatomic,readonly) NSDictionary *onlineAppConfig; //在线参数配置

@property(nonatomic,weak) id<NetEaseMobileManagerDelegate> delegate;

+ (NeteaseMobileManager*)sharedManager;
- (void)setAppId:(NSString *)appId andChannel:(NSString*)channel andDeviceId:(NSString*)deviceId;
- (void)addEvent:(NSString *)name param:(NSString *)param extra:(NSString *)extra;
- (void)reportCrash:(id<CLSCrashReport>)crash;
- (void)reportSessionPfmData;
- (void)reconnectionConfigData;

@end
