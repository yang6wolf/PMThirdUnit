//
//  UIDevice+Hardware.h
//  NeteaseLottery
//
//  Created by xuguoxing on 14-4-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//  设备硬件信息、可读的设备硬件信息（如：iPhone 1G）

#import <UIKit/UIKit.h>

@interface UIDevice (Hardware)

- (NSString *)platform;

- (NSString *)humanReadablePlatform;

@end
