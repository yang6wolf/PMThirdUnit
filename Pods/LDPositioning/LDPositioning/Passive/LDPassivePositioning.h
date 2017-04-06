//
//  LDPassivePositioning.h
//  LDPositioningDemo
//
//  Created by wuxu on 16/5/27.
//  Copyright © 2016年 wuxu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LDPassiveRoute.h"

@interface LDPassivePositioning : NSObject

/**
 *  定位一个控件的路径
 *
 *  @param route  实现LDPassiveRoute协议的对象
 *  @param view   需要匹配的View
 */
+ (BOOL)isRoute:(id<LDPassiveRoute>)route matchToView:(__kindof UIView *)view;

/**
 *  定位一个控件的路径
 *
 *  @param route  实现LDPassiveRoute协议的对象
 *  @param view   需要匹配的View
 *  @param ignore 是否忽略swift类名的module前缀
 */
+ (BOOL)isRoute:(id<LDPassiveRoute>)route matchToView:(__kindof UIView *)view ignoreSwiftModule:(BOOL)ignore;

@end
