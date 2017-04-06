//
//  UINavigationController+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UINavigationController+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NSString+NLDAddition.h"
#import "UIApplication+NLDEventCollection.h"
#import "UIViewController+NLDInternalMethod.h"
#import "NSObject+MethodSwizzle.h"
#import "NLDEventCollectionManager.h"

NLDNotificationNameDefine(NLDNotificationPushController)
NLDNotificationNameDefine(NLDNotificationPopController)
NLDNotificationNameDefine(NLDNotificationPopToController)
NLDNotificationNameDefine(NLDNotificationPopToRoot)


@implementation UINavigationController (NLDEventCollection)

+ (void)NLD_swizz
{
    /*
    SEL sel = @selector(pushViewController:animated:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained UINavigationController *receiver, __unsafe_unretained UIViewController *viewController, BOOL animated) {

        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        [userInfo setValue:receiver forKey:@"navigationController"];
        [userInfo setValue:viewController forKey:@"controller"];
        if ([receiver.topViewController respondsToSelector:@selector(NLD_addInfoForPushController:)]) {
            [userInfo setValue:[receiver.topViewController NLD_addInfoForPushController:viewController] forKey:@"addition"];
        }
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationPushController object:nil userInfo:userInfo.copy];
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[viewController, @(animated)]]) {
                ((void ( *)(id, SEL, id, BOOL))objc_msgSend)(receiver, newSel, viewController, animated);
            }
        }
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(popViewControllerAnimated:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = NLD_swizzSelector(self, sel, nil, newSel, ^UIViewController *(__unsafe_unretained UINavigationController *receiver, BOOL animated) {
        UIViewController *controller = nil;
        if ([receiver respondsToSelector:newSel]) {
            BOOL isMsgForward = [receiver invokeSelector:newSel withArguments:@[@(animated)] retureValue:&controller];
            if (!isMsgForward) {
                controller = ((UIViewController *( *)(id, SEL, BOOL))objc_msgSend)(receiver, newSel, animated);
            }
        }

        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        [userInfo setValue:receiver forKey:@"navigationController"];
        [userInfo setValue:controller forKey:@"controller"];
        if ([receiver.topViewController respondsToSelector:@selector(NLD_addInfoForPopController:)]) {
            [userInfo setValue:[receiver.topViewController NLD_addInfoForPopController:controller] forKey:@"addition"];
        }
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationPopController object:nil userInfo:userInfo.copy];
        return controller;
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(popToViewController:animated:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = NLD_swizzSelector(self, sel, nil, newSel, ^NSArray<__kindof UIViewController *> *(__unsafe_unretained UINavigationController *receiver, __unsafe_unretained UIViewController *viewController, BOOL animated) {
        NSArray<__kindof UIViewController *> *controllers = nil;
        if ([receiver respondsToSelector:newSel]) {
            BOOL isMsgForward = [receiver invokeSelector:newSel withArguments:@[viewController, @(animated)] retureValue:&controllers];
            if (!isMsgForward) {
                controllers = ((NSArray<__kindof UIViewController *> *( *)(id, SEL, id, BOOL))objc_msgSend)(receiver, newSel, viewController, animated);
            }
        }

        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        [userInfo setValue:receiver forKey:@"navigationController"];
        [userInfo setValue:controllers forKey:@"controllers"];
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationPopController object:nil userInfo:userInfo.copy];
        return controllers;
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(popToRootViewControllerAnimated:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = NLD_swizzSelector(self, sel, nil, newSel, ^NSArray<__kindof UIViewController *> *(__unsafe_unretained UINavigationController *receiver, BOOL animated) {
        NSArray<__kindof UIViewController *> *controllers = nil;
        if ([receiver respondsToSelector:newSel]) {
            BOOL isMsgForward = [receiver invokeSelector:newSel withArguments:@[@(animated)] retureValue:&controllers];
            if (!isMsgForward) {
                controllers = ((NSArray<__kindof UIViewController *> *( *)(id, SEL, BOOL))objc_msgSend)(receiver, newSel, animated);
            }
        }

        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        [userInfo setValue:receiver forKey:@"navigationController"];
        [userInfo setValue:controllers forKey:@"controllers"];
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationPopToRoot object:nil userInfo:userInfo.copy];
        return controllers;
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
     */
    
    SEL sel = @selector(navigationBar:shouldPopItem:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:@protocol(UINavigationBarDelegate) newSel:newSel usingBlock:^BOOL(__unsafe_unretained UINavigationController *receiver, __unsafe_unretained UINavigationBar *navigationBar, __unsafe_unretained UINavigationItem *item) {
        
        NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];
        
        if (receiver.viewControllers.count > 1) {
            if ((!item.leftBarButtonItem && !item.leftBarButtonItems) || item.leftItemsSupplementBackButton) {
                // 统计系统返回按钮的点击事件
                NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
                // title
                NSString *titleKey = @"viewTitle";
                UIBarItem *backItem = (UIBarItem *)item.backBarButtonItem;
                NSString *title = backItem.title.length > 0 ? backItem.title : @"导航返回";
                [userInfo setValue:title forKey:titleKey];
                // viewClass 系统返回按钮统一使用这个固定的类
                [userInfo setValue:@"UIBarButtonItem" forKey:@"view"];
                // pageName
                NSString *pageName = [UIViewController controllerNameForNavigation];
                [userInfo setValue:pageName forKey:@"controller"];
                // depthPath
                NSString *depthPath = @"0-0-0";
                [userInfo setValue:depthPath forKey:@"viewDepthPath"];
                // viewPath&depthPath
                NSString *viewPath = [NSString stringWithFormat:@"%@-UINavigationBar-UIBarButtonItem", NSStringFromClass([receiver class])];
                NSString *path = [NSString stringWithFormat:@"%@&%@", viewPath, depthPath];
                [userInfo setValue:path forKey:@"viewPath"];
                // viewId
                NSString *viewIdString = [NSString stringWithFormat:@"%@&%@&%@", pageName, viewPath, depthPath];
                [userInfo setValue:[viewIdString NLD_md5String] forKey:@"viewId"];
                
                if (collectManager.infoBlock) {
//                    collectManager.infoBlock(userInfo, item);
                }
                else {
                    if (collectManager.logInfoBlock) {
                        userInfo[@"eventName"] = @"ButtonClick";
                        collectManager.logInfoBlock(userInfo);
                    }
                    [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationButtonClick object:nil userInfo:userInfo.copy];
                }
            }
        }
        
        BOOL shouldPop = YES;
        if ([receiver respondsToSelector:newSel] && !collectManager.infoBlock) {
            BOOL isMsgForward = [receiver invokeSelector:newSel withArguments:@[navigationBar, item] retureValue:&shouldPop];
            if (!isMsgForward) {
                shouldPop = ((BOOL (*)(id, SEL, id, id))objc_msgSend)(receiver, newSel, navigationBar, item);
            }
        }
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        return shouldPop;
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
}

@end
