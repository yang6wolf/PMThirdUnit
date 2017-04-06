//
//  LDMediator.h
//  NeteaseLottery
//
//  Created by wuxu on 16/5/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDMediator : NSObject

/**
 *  获取目前所有被注册的协议
 */
+ (nullable NSSet<Protocol *> *)allServiceProtocol;

/**
 *  注册一个实现某协议的服务
 *
 *  @param serviceProtocol  服务遵守的协议
 *  @param block            返回实现协议的实例
 */
+ (BOOL)registerService:(Protocol *)serviceProtocol withImpl:(id (^)())block;

/**
 *  反注册某个服务
 *
 *  @param serviceProtocol  需要反注册的服务
 */
+ (void)unregisterService:(Protocol *)serviceProtocol;

/**
 *  通过某个协议找到实现协议的实例
 *
 *  @param serviceProtocol  服务协议
 */
+ (nullable id)findService:(Protocol *)serviceProtocol;

@end

NS_ASSUME_NONNULL_END
