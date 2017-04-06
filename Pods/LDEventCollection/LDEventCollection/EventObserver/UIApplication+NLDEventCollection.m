//
//  UIApplication+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/5/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIApplication+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NLDRemoteEventManager.h"
#import "NSObject+MethodSwizzle.h"
#import "NLDEventCollectionManager.h"
#import "UIView+NLDHierarchy.h"
#import "UIViewController+NLDInternalMethod.h"

NLDNotificationNameDefine(NLDNotificationButtonClick)
NLDNotificationNameDefine(NLDNotificationAppOpenUrl)
NLDNotificationNameDefine(NLDNotificationScreenSingleTouch)
NLDNotificationNameDefine(NLDNotificationReceiveRemoteNotification)


@implementation UIApplication (NLDEventCollection)

+ (void)NLD_swizz
{
    /*
    SEL sel = @selector(sendEvent:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    BOOL res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained UIApplication *receiver, __unsafe_unretained UIEvent *event) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[event ?: [NSNull null]]]) {
                ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, event);
            }
        }
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        if ([event allTouches].count == 1) {
            UITouch *touch = [[event allTouches] anyObject];
            if (touch.phase == UITouchPhaseBegan) {
                UIView *view = touch.view;
                NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:view forKey:@"view"];
                [userInfo setValue:event forKey:@"event"];
                [userInfo setValue:touch forKey:@"touch"];
                [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationScreenSingleTouch object:nil userInfo:userInfo.copy];
            }
        }
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    */
     
    /**
     *  统一处理 UIControl、UITabBarButton、自定义添加的 Navigation BarButtonItem 等点击事件。
     *  无法处理系统添加的 Navigation BarButtonItem 如 BackButtonItem。
     */
    SEL sel = @selector(sendAction:to:from:forEvent:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^BOOL(__unsafe_unretained UIApplication *receiver, SEL action, __unsafe_unretained id target, __unsafe_unretained id sender, __unsafe_unretained UIEvent *event) {

        // 将此代码移至最前面，以保证此事件的产生时间在其他事件的前面（比如pageCreate/PageShow)
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        [userInfo NLD_setButtonOrNil:sender];
        
        if (userInfo[@"controller"]) {
            [UIViewController updateCurrentPageWithEvent:NLDNotificationButtonClick pageName:userInfo[@"controller"]];
        }
        
        NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];

        NSString *className = @"";
        if ([sender isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)sender;
            UIViewController *controller = [view NLD_controller];
            className = NSStringFromClass([controller class]);
        }
        
        BOOL shouldMsgSend = [receiver respondsToSelector:newSel] && !collectManager.infoBlock;
        BOOL ViewSelectControllerOrNot = false;
        if ([className isEqualToString:@"SVMainViewController"]) {
            ViewSelectControllerOrNot = true;
        }
        
        BOOL msgFlag = shouldMsgSend || (ViewSelectControllerOrNot && [receiver respondsToSelector:newSel]);
        
        BOOL result = NO;
        
        if (msgFlag) {
            NSString *actionName = [NSString stringWithFormat:@"SEL_%@", NSStringFromSelector(action)];
            BOOL isMsgForward = [receiver invokeSelector:newSel withArguments:@[actionName, target ?:[NSNull null], sender ?:[NSNull null], event ?:[NSNull null]] retureValue:&result];
            if (!isMsgForward) {
                result = ((BOOL ( *)(id, SEL, SEL, id, id, id))objc_msgSend)(receiver, newSel, action, target, sender, event);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        BOOL shouldCollectInfo = NO;
        if (event && [event isKindOfClass:[UIEvent class]]) {
            UITouchPhase phase = [[event allTouches] anyObject].phase;
            if ([sender isKindOfClass:[UIControl class]]) {
                UIControlEvents allControlEvents = [sender allControlEvents];
                if ((allControlEvents & UIControlEventTouchDown) && !(allControlEvents & UIControlEventTouchUpInside)) {
                    // 这种情况下，在手势开始时就收集
                    if (phase == UITouchPhaseBegan) {
                        shouldCollectInfo = YES;
                    }
                }
            }
            if (phase == UITouchPhaseEnded || phase == UITouchPhaseCancelled) {
                shouldCollectInfo = YES;
            }
        } else if ([sender isKindOfClass:[UIControl class]] && ([sender allControlEvents] & UIControlEventValueChanged)) {
            shouldCollectInfo = YES;
        }
        
        if (shouldCollectInfo) {
            [userInfo setValue:NSStringFromSelector(action) forKey:@"action"];
            NSMutableDictionary *additionalDict = [NSMutableDictionary dictionaryWithCapacity:2];
            if ([sender additionalData]) {
                [additionalDict addEntriesFromDictionary:[sender additionalData]];
            }
            if (sender && [sender isKindOfClass:[UIView class]]) {
                NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:sender eventName:NSStringFromSelector(sel)];
                if (relativeInfo) {
                    [additionalDict addEntriesFromDictionary:relativeInfo];
                }
            }
            if ([sender isKindOfClass:[UISwitch class]]) {
                UISwitch *aSwitch = (UISwitch *)sender;
                NSString *switchValue = aSwitch.isOn ? @"1" : @"0";
                [additionalDict setValue:switchValue forKey:@"switchValue"];
            }
            if (additionalDict.count > 0) {
                [userInfo setValue:additionalDict.copy forKey:@"addition"];
            }
            
            if (collectManager.infoBlock && !ViewSelectControllerOrNot) {
                collectManager.infoBlock(userInfo, sender);
            } else if (!ViewSelectControllerOrNot) {
                if (collectManager.logInfoBlock) {
                    userInfo[@"eventName"] = @"ButtonClick";
                    collectManager.logInfoBlock(userInfo);
                }
                [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationButtonClick object:nil userInfo:userInfo.copy];
            }
        }
        
        return result;
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(openURL:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^BOOL(__unsafe_unretained UIApplication *receiver, __unsafe_unretained NSURL *url) {
        BOOL result = NO;
        if ([receiver respondsToSelector:newSel]) {
            BOOL isMsgForward = [receiver invokeSelector:newSel withArguments:@[url] retureValue:&result];
            if (!isMsgForward) {
                result = ((BOOL ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, url);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        [userInfo setValue:url forKey:@"url"];
        [userInfo setValue:@(result) forKey:@"succeed"];
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationAppOpenUrl object:nil userInfo:userInfo.copy];
        return result;
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    // 由于在app启动后进行hook，因此可以直接获取到delegate
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    sel = @selector(application:didReceiveRemoteNotification:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    [[delegate class] NLD_swizzSelector:sel referProtocol:@protocol(UIApplicationDelegate) newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained UIApplication *application, __unsafe_unretained NSDictionary *userInfo) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[application, userInfo]]) {
                ((void ( *)(id, SEL, id, id))objc_msgSend)(receiver, newSel, application, userInfo);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationReceiveRemoteNotification object:nil userInfo:userInfo.copy];
    }];
    
    
    /* 如果以后在load时hook，则需要使用下面这种方式
    sel = @selector(setDelegate:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <UIApplicationDelegate> delegate) {
        
        SEL subSel = @selector(application:didReceiveRemoteNotification:);
        SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        NLD_swizzSelector([delegate class], subSel, @protocol(UIApplicationDelegate), subNewSel, ^void(__unsafe_unretained id receiver, __unsafe_unretained UIApplication *application, __unsafe_unretained NSDictionary *userInfo) {
            if ([receiver respondsToSelector:subNewSel]) {
                if (![receiver invokeSelector:subNewSel withArguments:@[application, userInfo]]) {
                    ((void ( *)(id, SEL, id, id))objc_msgSend)(receiver, subNewSel, application, userInfo);
                }
            }
            
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
            
            [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationReceiveRemoteNotification object:nil userInfo:userInfo.copy];
        });
     
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[delegate ?: [NSNull null]]]) {
                ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, delegate);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
     */
}

@end
