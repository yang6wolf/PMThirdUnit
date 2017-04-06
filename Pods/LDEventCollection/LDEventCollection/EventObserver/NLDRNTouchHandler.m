//
//  NLDRNTouchHandler.m
//  LDEventCollection
//
//  Created by 高振伟 on 16/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDRNTouchHandler.h"
#import <objc/message.h>
#import "NSObject+MethodSwizzle.h"
#import "NSObject+NLDPerformSelector.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import "NLDRemoteEventManager.h"
#import "UIViewController+NLDInternalMethod.h"
#import "NLDEventCollectionManager.h"

NSString *const RNViewClickEventName = @"NLDNotificationTapGesture";

@implementation NLDRNTouchHandler

+ (void)NLD_swizz
{
    Class cls = NSClassFromString(@"RCTUIManager");
    if (!cls) return;
    
    SEL sel = NSSelectorFromString(@"setJSResponder:blockNativeResponder:");
    if (![cls instancesRespondToSelector:sel]) return;
    
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    [cls NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained NSNumber *reactTag, BOOL blockNativeResponder) {
        
        // 移至最前面执行，以保证事件时间的准确的顺序
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        
        NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];
        
        if ([receiver respondsToSelector:newSel] && !collectManager.infoBlock) {
            if (![receiver invokeSelector:newSel withArguments:@[reactTag, @(blockNativeResponder)]]) {
                ((void ( *)(id, SEL, id, BOOL))objc_msgSend)(receiver, newSel, reactTag, blockNativeResponder);
            }
        }
        
        NSLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        if ([NSStringFromClass([receiver class]) isEqualToString:@"RCTUIManager"] && [reactTag isKindOfClass:[NSNumber class]]) {
            
            NSMutableDictionary<NSNumber *, UIView *> *viewRegistry = [receiver valueForKey:@"_viewRegistry"];
            UIView *responseView = viewRegistry[reactTag];
            if (!responseView) return;
            
            [userInfo NLD_setViewOrNil:responseView];
            
            UIViewController *currentVC = [UIViewController currentVCOfIncludingChild:NO];
            NSString *pageName = [currentVC RN_pageName];
            [userInfo setObject:pageName forKey:@"controller"];
            
            NSMutableDictionary *additionalDict = [NSMutableDictionary dictionaryWithCapacity:2];
            NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:responseView eventName:RNViewClickEventName];
            if (relativeInfo) {
                [additionalDict addEntriesFromDictionary:relativeInfo];
            }
            if ([receiver additionalData]) {
                [additionalDict addEntriesFromDictionary:[receiver additionalData]];
            }
            if (additionalDict.count > 0) {
                [userInfo setValue:additionalDict forKey:@"addition"];
            }
            
            if (collectManager.infoBlock) {
                collectManager.infoBlock(userInfo, responseView);
            } else {
                [NSNotificationCenter NLD_postEventCollectionNotificationName:RNViewClickEventName object:nil userInfo:userInfo.copy];
            }
        }
    }];
}


/*
+ (void)NLD_swizz
{
    Class cls = NSClassFromString(@"RCTTouchHandler");
    if (!cls) return;
    
    SEL sel = NSSelectorFromString(@"_updateAndDispatchTouches:eventName:originatingTime:");
    if (![cls instancesRespondToSelector:sel]) return;
    
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    [cls NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained NSSet<UITouch *> *touches, __unsafe_unretained NSString *eventName, CFTimeInterval originatingTime) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[touches, eventName, @(originatingTime)]]) {
                ((void ( *)(id, SEL, id, id, double))objc_msgSend)(receiver, newSel, touches, eventName, originatingTime);
            }
        }
        
        NSLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        UITouch *touch = [touches anyObject];
        UITouchPhase phase = touch.phase;
        if (phase != UITouchPhaseEnded) return;
        
        UIView *touchView = touch.view;
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:touchView forKey:@"view"];
        NSMutableDictionary *additionalDict = [NSMutableDictionary dictionaryWithCapacity:2];
        NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:touchView eventName:RNViewClickEventName];
        if (relativeInfo) {
            [additionalDict addEntriesFromDictionary:relativeInfo];
        }
        if ([receiver additionalData]) {
            [additionalDict addEntriesFromDictionary:[receiver additionalData]];
        }
        if (additionalDict.count > 0) {
            [userInfo setValue:additionalDict forKey:@"addition"];
        }
        
        [NSNotificationCenter NLD_postEventCollectionNotificationName:RNViewClickEventName object:nil userInfo:userInfo.copy];
    }];
}
 */

@end
