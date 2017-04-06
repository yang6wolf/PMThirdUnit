//
//  UIWebView+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIWebView+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NSObject+MethodSwizzle.h"
#import "NLDEventCollectionManager.h"

NLDNotificationNameDefine(NLDNotificationWebWillLoadRequest)
NLDNotificationNameDefine(NLDNotificationWebStartLoad)
NLDNotificationNameDefine(NLDNotificationWebFinishLoad)
NLDNotificationNameDefine(NLDNotificationWebFailedLoad)


@implementation UIWebView (NLDEventCollection)

static NSString *lastWebView = nil;

+ (void)NLD_swizz
{
    SEL sel = @selector(setDelegate:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <UIWebViewDelegate> delegate) {
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[delegate ?: [NSNull null]]]) {
                ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, delegate);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        if ([receiver isKindOfClass:[UIWebView class]]) {
            NSString *webView = [NSString stringWithFormat:@"%p", receiver];
            if (lastWebView && [lastWebView isEqualToString:webView]) {
                return;
            } else {
                lastWebView = webView;
            }
        }

        SEL subSel = @selector(webView:shouldStartLoadWithRequest:navigationType:);
        SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UIWebViewDelegate) newSel:subNewSel usingBlock:^BOOL(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIWebView *webView, __unsafe_unretained NSURLRequest *request, UIWebViewNavigationType navigationType) {
            
            BOOL shouldStartLoad = YES;
            if ([receiver respondsToSelector:subNewSel]) {
                BOOL isMsgForward = [receiver invokeSelector:subNewSel withArguments:@[webView, request, @(navigationType)] retureValue:&shouldStartLoad];
                if (!isMsgForward) {
                    shouldStartLoad = ((BOOL ( *)(id, SEL, id, id, NSInteger))objc_msgSend)(receiver, subNewSel, webView, request, navigationType);
                }
            }
            
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
            
            if (shouldStartLoad) {
                NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:webView];
                [userInfo setValue:[[request URL] absoluteString] forKey:@"requestUrl"];

                [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationWebWillLoadRequest object:nil userInfo:userInfo.copy];
                
            }
            return shouldStartLoad;
        }];
        
        /* 暂不统计
         subSel = @selector(webViewDidStartLoad:);
         subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
         NLD_swizzSelector([delegate class], subSel, @protocol(UIWebViewDelegate), subNewSel, ^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIWebView *webView) {
         if ([receiver respondsToSelector:subNewSel]) {
         if (![receiver invokeSelector:subNewSel withArguments:@[webView]]) {
         ((void ( *)(id, SEL, id))objc_msgSend)(receiver, subNewSel, webView);
         }
         }
         
         LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
         
         NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:webView forKey:@"webView"];
         [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationWebStartLoad object:nil userInfo:userInfo.copy];
         });
         */
        
        /* 暂不统计
         subSel = @selector(webViewDidFinishLoad:);
         subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
         NLD_swizzSelector([delegate class], subSel, @protocol(UIWebViewDelegate), subNewSel, ^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIWebView *webView) {
         if ([receiver respondsToSelector:subNewSel]) {
         if (![receiver invokeSelector:subNewSel withArguments:@[webView]]) {
         ((void ( *)(id, SEL, id))objc_msgSend)(receiver, subNewSel, webView);
         }
         }
         
         LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
         
         NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:webView forKey:@"webView"];
         [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationWebFinishLoad object:nil userInfo:userInfo.copy];
         });
         */
        
        subSel = @selector(webView:didFailLoadWithError:);
        subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UIWebViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIWebView *webView, __unsafe_unretained NSError *error) {
            UIWebView *webv = webView;
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
            NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:webv];
            [userInfo setValue:[error localizedDescription] forKey:@"error"];
            [userInfo setValue:[[[webv request] URL] absoluteString] forKey:@"requestUrl"];
            
            if ([receiver respondsToSelector:subNewSel]) {
                if (![receiver invokeSelector:subNewSel withArguments:@[webv, error ?: [NSNull null]]]) {
                    ((void ( *)(id, SEL, id, id))objc_msgSend)(receiver, subNewSel, webv, error);
                }
            }
            [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationWebFailedLoad object:nil userInfo:userInfo.copy];
            
        }];
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
}

@end
