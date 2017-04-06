//
//  NTBManager.m
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NFBManager.h"
#import "NFBConfig.h"
#import "NFBQequestSession.h"


NSString * const NFeedBackUnreadMessageCountChangedNotification = @"NFeedBackUnreadMessageCountChangedNotification";
NSString * const NFeedBackUnreadMessageCountKey = @"NFeedBackUnreadMessageCountKey";

NSString * const NFeedBackActionEventNotification = @"NFeedBackActionEventNotification";
NSString * const NFeedBackAlertMessageKey = @"NFeedBackAlertMessageKey";
NSString * const NFeedBackEvaluationKey = @"NFeedBackEvaluationKey";
NSString * const NFeedBackEvaluationCommitKey = @"NFeedBackEvaluationCommitKey";

NSString * const CheckDNSisHijacked = @"checkDNSisHijacked";

@implementation NFBManager

+ (void)configWithProduct:(NSString*)product
                productId:(NSString*)productId
                  version:(NSString*)version
                  channel:(NSString*)channel
                 deviceId:(NSString*)deviceId {
    [NFBConfig sharedConfig].product = product;
    [NFBConfig sharedConfig].productId = productId;
    [NFBConfig sharedConfig].deviceId = deviceId;
    [NFBConfig sharedConfig].channel = channel;
    [NFBConfig sharedConfig].version = version;
}

+ (void)setURSAccount:(NSString*)account
{
    [NFBConfig sharedConfig].accountId = account;
}

+ (void)setServicePhone:(NSString *)phoneNumber{
    [NFBConfig sharedConfig].servicePhone = phoneNumber;
}

+ (void)setDomains:(NSArray*)domains {
    [[NFBConfig sharedConfig].domains removeAllObjects];
    for (NSString *dm in domains) {
        if ([[NFBConfig sharedConfig].domains containsObject:dm]) {
            continue;
        }
        [[NFBConfig sharedConfig].domains addObject:dm];
    }
}

+ (void)setFeedBackHost:(NSString *)host
{
    [NFBConfig sharedConfig].host = host;
}

//开始消息轮询
+ (void)startMessagePolling {
    if ([NFBQequestSession session].pollingMode==NFBPollingMessageNone) {
        [[NFBQequestSession session] startPollMessage:NFBPollingMessageSlow];
    }
}

+ (NSUInteger)currentUnreadMessageCount {
    return [NFBQequestSession session].unreadNums;
}
@end
