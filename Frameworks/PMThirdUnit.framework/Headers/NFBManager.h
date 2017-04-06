//
//  NTBManager.h
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NFeedBackUnreadMessageCountChangedNotification;
extern NSString * const NFeedBackUnreadMessageCountKey;

extern NSString * const NFeedBackActionEventNotification;
extern NSString * const NFeedBackAlertMessageKey;
extern NSString * const NFeedBackEvaluationKey;
extern NSString * const NFeedBackEvaluationCommitKey;
extern NSString * const CheckDNSisHijacked;                                 //检查网络劫持的消息


@interface NFBManager : NSObject
+ (void)configWithProduct:(NSString*)product
                productId:(NSString*)productId
                  version:(NSString*)version
                  channel:(NSString*)channel
                 deviceId:(NSString*)deviceId;
//URS账号,可以随消息上传客服系统
+ (void)setURSAccount:(NSString*)account;

//设置产品独有的客服电话，不设置用默认电话
+ (void)setServicePhone:(NSString *)phoneNumber;

//设置产品域名，用于网络诊断
+ (void)setDomains:(NSArray*)domains;

//设置客服域名，默认为http://chat.zxkf.163.com
+ (void)setFeedBackHost:(NSString *)host;

//开始消息轮询
+ (void)startMessagePolling;
+ (NSUInteger)currentUnreadMessageCount;
@end
