//
//  LDSocketPushClientRemoteCommandCenter.h
//  NeteaseLottery
//
//  Created by david on 16/2/22.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDRemoteCommandProtocol.h"

extern NSString *const fileNameKey;
extern NSString *const filePathKey;
extern NSString *const targetKey;
extern NSString *const targetValue;
extern NSString *const urlKey;

@protocol LDSocketPushClientRemoteCommandCenterMethodSource <NSObject>

/*
 * YES:开启强制IP模式
 * NO:关闭IP模式
 */
- (void)RCSetIPModeState:(BOOL)state;

/*
 * 开启/关闭日志上传
 */
- (void)RCSetupDiagnose:(NSArray *)params;

@end

@interface LDSocketPushClientRemoteCommandCenter : NSObject

@property (nonatomic, weak) id<LDSocketPushClientRemoteCommandCenterMethodSource> methodSource;

+ (instancetype)sharedInstance;

- (BOOL)executeCommand:(id<LDRemoteCommandProtocol>)item;

@end
