//
//  LDNetConnect.h
//  LDNetDiagnoServiceDemo
//
//  Created by ZhangHaiyang on 15-8-5.
//  Copyright (c) 2015年 庞辉. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * @protocal LDNetConnectDelegate监测connect命令的的输出到日志变量；
 *
 */
@protocol LDNetConnectDelegate <NSObject>
- (void)appendSocketLog:(NSString *)socketLog;
- (void)connectDidEnd:(BOOL)success;
@end


/*
 * @class LDNetConnect ping监控
 * 主要是通过建立socket连接的过程，监控目标主机是否连通
 * 默认连续执行4次，因为每次的速度不一致，可以观察其平均速度来判断网络情况
 */
@interface LDNetConnect : NSObject {
}

@property (nonatomic, weak) id<LDNetConnectDelegate> delegate;

/**
 * 设置Connect相关
 * maxCount: 最大connect次数，初始默认4次
 * timeOutTime: 最大超时响应时间，初始默认3秒
 */
- (void)setMaxCount:(NSUInteger)maxCount
        timeOutTime:(double)timeOutTime;

/**
 * 通过hostaddress和port 进行connect诊断
 */
- (void)runWithHostAddress:(NSString *)hostAddress port:(int)port;

/**
 * 停止connect
 */
- (void)stopConnect;

@end
