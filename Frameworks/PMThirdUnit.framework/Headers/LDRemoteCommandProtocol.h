//
//  LDRemoteCommandItemProtocol.h
//  NeteaseLottery
//
//  Created by david on 16/6/28.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDRemoteCommandDefine.h"

@protocol LDRemoteCommandProtocol <NSObject>

@property (nonatomic, readonly, assign) RemoteCommandType command;
@property (nonatomic, readonly, strong) NSArray *params;

@end
