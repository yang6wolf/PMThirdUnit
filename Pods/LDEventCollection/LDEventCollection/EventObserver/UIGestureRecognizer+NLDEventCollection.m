//
//  UIGestureRecognizer+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIGestureRecognizer+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "UIGestureRecognizer+NLDInternalMethodCall.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import "UIViewController+NLDAdditionalInfo.h"
#import "UIView+NLDHierarchy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NLDRemoteEventManager.h"
#import "NSObject+MethodSwizzle.h"
#import "NLDEventCollectionManager.h"
#import "UIViewController+NLDInternalMethod.h"

NLDNotificationNameDefine(NLDNotificationTapGesture)
NLDNotificationNameDefine(NLDNotificationLongPressGesture)
NLDNotificationNameDefine(NLDNotificationPanGesture)
NLDNotificationNameDefine(NLDNotificationSwipeGesture)


@implementation UIGestureRecognizer (NLDEventCollection)

+ (void)NLD_swizz
{
    Method orgMethod = class_getInstanceMethod(self, @selector(initWithTarget:action:));
    Method hookMethod = class_getInstanceMethod(self, @selector(NLD_hookInitWithTarget:action:));
    NSParameterAssert(orgMethod && hookMethod);
    method_exchangeImplementations(orgMethod, hookMethod);
    
    orgMethod = class_getInstanceMethod(self, @selector(addTarget:action:));
    hookMethod = class_getInstanceMethod(self, @selector(NLD_hookAddTarget:action:));
    NSParameterAssert(orgMethod && hookMethod);
    method_exchangeImplementations(orgMethod, hookMethod);
}

- (instancetype)NLD_hookInitWithTarget:(nullable id)target action:(nullable SEL)action
{
    if (!target || !action) {
        return [self NLD_hookInitWithTarget:target action:action];
    }
    
    if (![self isInternalMethodCallWithTarget:target action:action]) {
        if ([self isKindOfClass:[UITapGestureRecognizer class]]) {
            [self NLD_swizzGesture:NLDNotificationTapGesture withTarget:target action:action];
        }
        else if ([self isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [self NLD_swizzGesture:NLDNotificationLongPressGesture withTarget:target action:action];
        }
    }
    
/*
        if (![NSThread isInternalMethodCallAtIndex:2]) {
            if ([self isKindOfClass:[UITapGestureRecognizer class]]) {
                [self NLD_swizzGesture:NLDNotificationTapGesture withTarget:target action:action];
            }
            else if ([self isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [self NLD_swizzGesture:NLDNotificationLongPressGesture withTarget:target action:action];
            }
            //        else if ([self isKindOfClass:[UIPanGestureRecognizer class]]) {
            //            [self NLD_swizzGesture:NLDNotificationPanGesture withTarget:target action:action];
            //        }
            //        else if ([self isKindOfClass:[UISwipeGestureRecognizer class]]) {
            //            [self NLD_swizzGesture:NLDNotificationSwipeGesture withTarget:target action:action];
            //        }
        }
 */
    
    return [self NLD_hookInitWithTarget:target action:action];
}

- (void)NLD_hookAddTarget:(id)target action:(SEL)action
{
    if (!target || !action) {
        return [self NLD_hookAddTarget:target action:action];
    }
    [self NLD_hookAddTarget:target action:action];
    
    if (![self isInternalMethodCallWithTarget:target action:action]) {
        if ([self isKindOfClass:[UITapGestureRecognizer class]]) {
            [self NLD_swizzGesture:NLDNotificationTapGesture withTarget:target action:action];
        }
        else if ([self isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [self NLD_swizzGesture:NLDNotificationLongPressGesture withTarget:target action:action];
        }
    }
    
    /*
        if (![NSThread isInternalMethodCallAtIndex:2]) {
            if ([self isKindOfClass:[UITapGestureRecognizer class]]) {
                [self NLD_swizzGesture:NLDNotificationTapGesture withTarget:target action:action];
            }
            else if ([self isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [self NLD_swizzGesture:NLDNotificationLongPressGesture withTarget:target action:action];
            }
            //        else if ([self isKindOfClass:[UIPanGestureRecognizer class]]) {
            //            [self NLD_swizzGesture:NLDNotificationPanGesture withTarget:target action:action];
            //        }
            //        else if ([self isKindOfClass:[UISwipeGestureRecognizer class]]) {
            //            [self NLD_swizzGesture:NLDNotificationSwipeGesture withTarget:target action:action];
            //        }
        }
     */
}


#pragma mark - swizz

- (void)NLD_swizzGesture:(NSString *)gesture withTarget:(id)target action:(SEL)action
{
    if (!target || !action) {
        return;
    }
    
    NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];
    
    SEL newAction = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(action)]);
    id block;
    if ([NSStringFromSelector(action) rangeOfString:@":"].location != NSNotFound) {
        block = ^(__unsafe_unretained id receiver, __unsafe_unretained id arg) {
            
            if (![arg isKindOfClass:[UIGestureRecognizer class]]) {
                if (!collectManager.infoBlock) {
                    if (![receiver invokeSelector:newAction withArguments:@[arg ?: [NSNull null]]]) {
                        ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newAction, arg);
                    }
                }
                return;
            }
            UIGestureRecognizer *gestureRecognizer = (UIGestureRecognizer *)arg;
            if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                LDECLog(@"监测到系统调用的方法：%@\nself: %@\nges: %@ ", NSStringFromSelector(action), self, gestureRecognizer);
                UIView *targetView = nil;
                if (gestureRecognizer.view) {
                    targetView = gestureRecognizer.view;
                } else if ([receiver isKindOfClass:[UIView class]]) {
                    targetView = (UIView *)receiver;
                }
                NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
                [userInfo NLD_setViewOrNil:targetView];
                
                [UIViewController updateCurrentPageWithEvent:gesture pageName:userInfo[@"controller"]];
                
                //            [userInfo setValue:target forKey:@"target"];
                [userInfo setValue:NSStringFromSelector(action) forKey:@"action"];
                UIViewController *controller = [targetView NLD_controller];
                
                NSMutableDictionary *additionalDict = [NSMutableDictionary dictionaryWithCapacity:2];
                NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:targetView eventName:gesture];
                if (relativeInfo) {
                    [additionalDict addEntriesFromDictionary:relativeInfo];
                }
                if ([receiver additionalData]) {
                    [additionalDict addEntriesFromDictionary:[receiver additionalData]];
                }
                if ([controller respondsToSelector:@selector(NLD_addInfoForView:gesture:)]) {
                    if ([controller NLD_addInfoForView:targetView gesture:gestureRecognizer]) {
                        [additionalDict addEntriesFromDictionary:[controller NLD_addInfoForView:targetView gesture:gestureRecognizer]];
                    }
                }
                if (additionalDict.count > 0) {
                    [userInfo setValue:additionalDict forKey:@"addition"];
                }
                
                if (collectManager.infoBlock) {
                    collectManager.infoBlock(userInfo, targetView);
                }
                else {
                    if (collectManager.logInfoBlock) {
                        userInfo[@"eventName"] = @"ViewClick";
                        collectManager.logInfoBlock(userInfo);
                    }
                    [NSNotificationCenter NLD_postEventCollectionNotificationName:gesture object:nil userInfo:userInfo.copy];
                }
            }
            
            if (!collectManager.infoBlock) {
                if (![receiver invokeSelector:newAction withArguments:@[arg ?: [NSNull null]]]) {
                    ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newAction, arg);
                }
            }
        };
    } else {
        block = ^(__unsafe_unretained id receiver) {
            
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(action));
            
            // 获取当前的手势对象
            UIGestureRecognizer *gestureRecognizer = nil;
            if ([receiver isKindOfClass:[UIView class]]) {
                UIView *gesutureView = (UIView *)receiver;
                NSArray *gestureRecognizers = gesutureView.gestureRecognizers;
                Class gestureKlass = [gesture isEqualToString:NLDNotificationTapGesture] ? [UITapGestureRecognizer class] : [UILongPressGestureRecognizer class];
                if (gestureRecognizers.count == 1 && [gestureRecognizers[0] isKindOfClass:gestureKlass]) {
                    gestureRecognizer = [gestureRecognizers firstObject];
                } else if (gestureRecognizers.count > 1) {
                    for (UIGestureRecognizer *gr in gestureRecognizers) {
                        if ([gr isKindOfClass:gestureKlass]) {
                            gestureRecognizer = gr;
                            break;
                        }
                    }
                } else {
                    gestureRecognizer = self;
                }
            } else {
                gestureRecognizer = self;
            }
            
            if (gestureRecognizer && gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                UIView *targetView = nil;
                if (gestureRecognizer.view) {
                    targetView = gestureRecognizer.view;
                } else if ([receiver isKindOfClass:[UIView class]]) {
                    targetView = (UIView *)receiver;
                }
                NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
                [userInfo NLD_setViewOrNil:targetView];
                
                [UIViewController updateCurrentPageWithEvent:gesture pageName:userInfo[@"controller"]];
                
                //            [userInfo setValue:target forKey:@"target"];
                [userInfo setValue:NSStringFromSelector(action) forKey:@"action"];
                UIViewController *controller = [targetView NLD_controller];
                
                NSMutableDictionary *additionalDict = [NSMutableDictionary dictionaryWithCapacity:2];
                NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:targetView eventName:gesture];
                if (relativeInfo) {
                    [additionalDict addEntriesFromDictionary:relativeInfo];
                }
                if ([receiver additionalData]) {
                    [additionalDict addEntriesFromDictionary:[receiver additionalData]];
                }
                if ([controller respondsToSelector:@selector(NLD_addInfoForView:gesture:)]) {
                    if ([controller NLD_addInfoForView:targetView gesture:self]) {
                        [additionalDict addEntriesFromDictionary:[controller NLD_addInfoForView:targetView gesture:self]];
                    }
                }
                if (additionalDict.count > 0) {
                    [userInfo setValue:additionalDict forKey:@"addition"];
                }
                
                if (collectManager.infoBlock) {
                    collectManager.infoBlock(userInfo, targetView);
                }
                else {
                    if (collectManager.logInfoBlock) {
                        userInfo[@"eventName"] = @"ViewClick";
                        collectManager.logInfoBlock(userInfo);
                    }
                    [NSNotificationCenter NLD_postEventCollectionNotificationName:gesture object:nil userInfo:userInfo.copy];
                }
            }
            
            if (!collectManager.infoBlock) {
                if (![receiver invokeSelector:newAction withArguments:nil]) {
                    ((void ( *)(id, SEL))objc_msgSend)(receiver, newAction);
                }
            }
        };
    }
    
    [[target class] NLD_swizzSelector:action referProtocol:nil newSel:newAction usingBlock:block];
}

@end
