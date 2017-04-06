//
//  LDRemoteCommandConfig.m
//  NeteaseLottery
//
//  Created by david on 16/6/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "LDRemoteCommandConfig.h"

@interface LDRemoteCommandConfig ()

@property (nonatomic, copy) NSString *productId;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *upLoadHost;

@end

@implementation LDRemoteCommandConfig

+ (instancetype)sharedConfig
{
    static LDRemoteCommandConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LDRemoteCommandConfig alloc] init];
    });
    return instance;
}

- (void)configWithProductId:(NSString *)productId
                    version:(NSString *)version
                  accountId:(NSString *)accountId
                   deviceId:(NSString *)deviceId
{
    [self configWithProductId:productId
                      version:version
                    accountId:accountId
                     deviceId:deviceId
                   upLoadHost:nil];
}

- (void)configWithProductId:(NSString *)productId
                    version:(NSString *)version
                  accountId:(NSString *)accountId
                   deviceId:(NSString *)deviceId
                 upLoadHost:(NSString *)upLoadHost
{
    self.productId = productId;
    self.version = version;
    self.accountId = accountId;
    self.deviceId = deviceId;
    
    if (upLoadHost) {
        self.upLoadHost = upLoadHost;
    } else {
        self.upLoadHost = @"http://mt.analytics.163.com";
    }
}

- (void)setUserAccountId:(NSString *)accountId
{
    self.accountId = accountId;
}

@end
