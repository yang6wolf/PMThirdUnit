//
//  UIViewController+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIViewController+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import "UIViewController+NLDAdditionalInfo.h"
#import "UIView+NLDHierarchy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+NLDPerformSelector.h"
#import "NLDMacroDef.h"
#import "UIViewController+NLDInternalMethod.h"
#import "NSObject+MethodSwizzle.h"
#import "NLDRNPageManager.h"
#import "NLDMethodHookNotification.h"

NLDNotificationNameDefine(NLDNotificationNewController)
NLDNotificationNameDefine(NLDNotificationShowController)
NLDNotificationNameDefine(NLDNotificationDidShowController)
NLDNotificationNameDefine(NLDNotificationHideController)
NLDNotificationNameDefine(NLDNotificationDestoryController)
NLDNotificationNameDefine(NLDNotificationPresentController)
NLDNotificationNameDefine(NLDNotificationDismissController)


@implementation UIViewController (NLDEventCollection)

+ (void)NLD_swizz
{
    SEL sel = @selector(viewDidLoad);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained UIViewController *receiver) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:nil]) {
                ((void ( *)(id, SEL))objc_msgSend)(receiver, newSel);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        NSString *pageName = [receiver controllerName];
        [userInfo setValue:pageName forKey:@"controller"];
        if ([receiver respondsToSelector:@selector(NLD_addInfoForNewController)]) {
            [userInfo setValue:[receiver NLD_addInfoForNewController] forKey:@"addition"];
        }
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationNewController object:nil userInfo:userInfo.copy];
        
        [NSNotificationCenter NLD_postMethodHookNotificationName:kNLDViewDidLoadNotification userInfo:@{@"pageName": pageName}];
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = NSSelectorFromString(@"dealloc");
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained UIViewController *receiver) {
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        NSString *pageName = [receiver controllerName];
        [userInfo setValue:pageName forKey:@"controller"];
        if ([receiver respondsToSelector:@selector(NLD_addInfoForDestoryController)]) {
            [userInfo setValue:[receiver NLD_addInfoForDestoryController] forKey:@"addition"];
        }
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationDestoryController object:nil userInfo:userInfo.copy];
        
        [NSNotificationCenter NLD_postMethodHookNotificationName:kNLDDeallocNotification userInfo:@{@"pageName": pageName}];
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:nil]) {
                ((void ( *)(id, SEL))objc_msgSend)(receiver, newSel);
            }
        }
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(viewWillAppear:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained UIViewController *receiver, BOOL animated) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[@(animated)]]) {
                ((void ( *)(id, SEL, BOOL))objc_msgSend)(receiver, newSel, animated);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        NSString *pageName = [receiver controllerName];
        [userInfo setValue:pageName forKey:@"controller"];
        
        [UIViewController updateCurrentPageWithEvent:NLDNotificationShowController pageName:pageName];
        
        if ([receiver respondsToSelector:@selector(NLD_addInfoForShowController)]) {
            [userInfo setValue:[receiver NLD_addInfoForShowController] forKey:@"addition"];
        }
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationShowController object:nil userInfo:userInfo.copy];
        
        [NSNotificationCenter NLD_postMethodHookNotificationName:kNLDViewWillAppearNotification userInfo:@{@"pageName": pageName}];
        
        [[NLDRNPageManager defaultManager] triggerPageEventWithType:RNPageEventShow componentName:receiver.componentName];
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(viewDidAppear:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained UIViewController *receiver, BOOL animated) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[@(animated)]]) {
                ((void ( *)(id, SEL, BOOL))objc_msgSend)(receiver, newSel, animated);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        NSString *pageName = [receiver controllerName];
        NSDictionary *userInfo = @{
                                   @"controller": pageName
                                   };
        
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationDidShowController object:nil userInfo:userInfo.copy];
        
        [NSNotificationCenter NLD_postMethodHookNotificationName:kNLDViewDidAppearNotification userInfo:@{@"pageName": pageName}];
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(viewWillDisappear:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained UIViewController *receiver, BOOL animated) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[@(animated)]]) {
                ((void ( *)(id, SEL, BOOL))objc_msgSend)(receiver, newSel, animated);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        NSString *pageName = [receiver controllerName];
        [userInfo setValue:pageName forKey:@"controller"];
        if ([receiver respondsToSelector:@selector(NLD_addInfoForHideController)]) {
            [userInfo setValue:[receiver NLD_addInfoForHideController] forKey:@"addition"];
        }
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationHideController object:nil userInfo:userInfo.copy];
        
        [NSNotificationCenter NLD_postMethodHookNotificationName:kNLDViewWillDisappearNotification userInfo:@{@"pageName": pageName}];
        
        [[NLDRNPageManager defaultManager] triggerPageEventWithType:RNPageEventHide componentName:receiver.componentName];
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    /*
    sel = @selector(presentViewController:animated:completion:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained UIViewController *receiver, __unsafe_unretained UIViewController *viewControllerToPresent, BOOL flag, id completion) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[viewControllerToPresent, @(flag), [completion copy] ?:[NSNull null]]]) {
                ((void ( *)(id, SEL, id, BOOL, id))objc_msgSend)(receiver, newSel, viewControllerToPresent, flag, completion);
            }
        }

        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        [userInfo setValue:NSStringFromClass([receiver class]) forKey:@"controller"];
        [userInfo setValue:NSStringFromClass([viewControllerToPresent class]) forKey:@"presentController"];
        if ([receiver respondsToSelector:@selector(NLD_addInfoForPresentController:)]) {
            [userInfo setValue:[receiver NLD_addInfoForPresentController:viewControllerToPresent] forKey:@"addition"];
        }
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationPresentController object:nil userInfo:userInfo.copy];
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(dismissViewControllerAnimated:completion:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained UIViewController *receiver, BOOL flag, id completion) {
        UIViewController *baseController;
        UIViewController *dismissController;
        if (receiver.presentedViewController) {
            // self present出来了另一个controller，此时dismiss的是被present出来的controller
            baseController = receiver;
            dismissController = receiver.presentedViewController;
        } else if (receiver.presentingViewController) {
            // self是被present出来的，此时self dismiss的是self
            baseController = receiver.presentingViewController;
            dismissController = receiver;
        }
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[@(flag), [completion copy] ?:[NSNull null]]]) {
                ((void ( *)(id, SEL, BOOL, id))objc_msgSend)(receiver, newSel, flag, completion);
            }
        }

        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        if (baseController && dismissController) {
            NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
            [userInfo setValue:NSStringFromClass([baseController class]) forKey:@"controller"];
            [userInfo setValue:NSStringFromClass([dismissController class]) forKey:@"dismissController"];
            if ([receiver respondsToSelector:@selector(NLD_addInfoForDismissController:)]) {
                [userInfo setValue:[receiver NLD_addInfoForDismissController:dismissController] forKey:@"addition"];
            }
            [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationDismissController object:nil userInfo:userInfo.copy];
        }
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(presentModalViewController:animated:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained UIViewController *receiver, __unsafe_unretained UIViewController *modalViewController, BOOL animated) {
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[modalViewController, @(animated)]]) {
                ((void ( *)(id, SEL, id, BOOL))objc_msgSend)(receiver, newSel, modalViewController, animated);
            }
        }

        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
        [userInfo setValue:NSStringFromClass([receiver class]) forKey:@"controller"];
        [userInfo setValue:NSStringFromClass([modalViewController class]) forKey:@"presentController"];
        if ([receiver respondsToSelector:@selector(NLD_addInfoForPresentController:)]) {
            [userInfo setValue:[receiver NLD_addInfoForPresentController:modalViewController] forKey:@"addition"];
        }
        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationPresentController object:nil userInfo:userInfo.copy];
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
    sel = @selector(dismissModalViewControllerAnimated:);
    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained UIViewController *receiver, BOOL animated) {
        UIViewController *baseController;
        UIViewController *dismissController;
        if (receiver.presentedViewController) {
            // self present出来了另一个controller，此时dismiss的是被present出来的controller
            baseController = receiver;
            dismissController = receiver.presentedViewController;
        } else if (receiver.presentingViewController) {
            // self是被present出来的，此时self dismiss的是self
            baseController = receiver.presentingViewController;
            dismissController = receiver;
        }
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[@(animated)]]) {
                ((void ( *)(id, SEL, BOOL))objc_msgSend)(receiver, newSel, animated);
            }
        }

        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));

        if (baseController && dismissController) {
            NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
            [userInfo setValue:NSStringFromClass([baseController class]) forKey:@"controller"];
            [userInfo setValue:NSStringFromClass([dismissController class]) forKey:@"dismissController"];
            if ([receiver respondsToSelector:@selector(NLD_addInfoForDismissController:)]) {
                [userInfo setValue:[receiver NLD_addInfoForDismissController:dismissController] forKey:@"addition"];
            }
            [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationDismissController object:nil userInfo:userInfo.copy];
        }
    });
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
     */
}

@end
