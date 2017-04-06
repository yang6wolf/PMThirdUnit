//
//  LDPositioningCommon.h
//  NeteaseLottery
//
//  Created by wuxu on 16/5/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDPositioningCommon : NSObject

+ (BOOL)isView:(__kindof UIView *)view equalToPaths:(NSArray<NSString *> *)paths andDepths:(NSArray<NSString *> *)depths;

+ (nullable __kindof UIView *)findTargetWithRootView:(__kindof UIView *)view paths:(NSArray<NSString *> *)paths indexs:(NSArray<NSString *> *)indexs;

@end

NS_ASSUME_NONNULL_END