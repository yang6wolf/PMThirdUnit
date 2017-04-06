//
//  LDRemoteCommandConfig.h
//  NeteaseLottery
//
//  Created by david on 16/6/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  远程指令配置（需在主工程中配置）
 */
@interface LDRemoteCommandConfig : NSObject

@property (nonatomic, copy, readonly) NSString *productId;
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, copy, readonly) NSString *accountId;
@property (nonatomic, copy, readonly) NSString *deviceId;
@property (nonatomic, copy, readonly) NSString *upLoadHost;

+ (instancetype)sharedConfig;


- (void)configWithProductId:(NSString *)productId
                    version:(NSString *)version
                  accountId:(NSString *)accountId
                   deviceId:(NSString *)deviceId;

- (void)configWithProductId:(NSString *)productId
                    version:(NSString *)version
                  accountId:(NSString *)accountId
                   deviceId:(NSString *)deviceId
                 upLoadHost:(NSString *)upLoadHost;

- (void)setUserAccountId:(NSString *)accountId;

@end
