//
//  WKWebView+NLDEventCollection.m
//  Pods
//
//  Created by 高振伟 on 17/6/13.
//
//

#import "WKWebView+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NSObject+MethodSwizzle.h"
#import "NLDEventCollectionManager.h"
#import "UIWebView+NLDEventCollection.h"

@implementation WKWebView (NLDEventCollection)

static NSString *lastWKWebView = nil;

+ (void)NLD_swizz {
    SEL sel = @selector(setNavigationDelegate:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <WKNavigationDelegate> delegate) {
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[delegate ?: [NSNull null]]]) {
                ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, delegate);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        if ([receiver isKindOfClass:[WKWebView class]]) {
            NSString *webView = [NSString stringWithFormat:@"%p", receiver];
            if (lastWKWebView && [lastWKWebView isEqualToString:webView]) {
                return;
            } else {
                lastWKWebView = webView;
            }
        }
        
        SEL subSel = @selector(webView:didStartProvisionalNavigation:);
        SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(WKNavigationDelegate) newSel:subNewSel usingBlock:^(__unsafe_unretained id receiver, __unsafe_unretained __kindof WKWebView *webView, __unsafe_unretained WKNavigation *navigation) {
            
            if ([receiver respondsToSelector:subNewSel]) {
                BOOL isMsgForward = [receiver invokeSelector:subNewSel withArguments:@[webView, navigation ?: [NSNull null]]];
                if (!isMsgForward) {
                    ((void ( *)(id, SEL, id, id))objc_msgSend)(receiver, subNewSel, webView, navigation);
                }
            }
            
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
            
            NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:webView];
            [userInfo setValue:[webView.URL absoluteString] forKey:@"requestUrl"];
            
            [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationWebWillLoadRequest object:nil userInfo:userInfo.copy];
        }];
        
        subSel = @selector(webView:didFailProvisionalNavigation:withError:);
        subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(WKNavigationDelegate) newSel:subNewSel usingBlock:^(__unsafe_unretained id receiver, __unsafe_unretained __kindof WKWebView *webView, __unsafe_unretained WKNavigation *navigation, __unsafe_unretained NSError *error) {
            
            if ([receiver respondsToSelector:subNewSel]) {
                BOOL isMsgForward = [receiver invokeSelector:subNewSel withArguments:@[webView, navigation ?: [NSNull null],error]];
                if (!isMsgForward) {
                    ((void ( *)(id, SEL, id, id, id))objc_msgSend)(receiver, subNewSel, webView, navigation, error);
                }
            }
            
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
            
            NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:webView];
            [userInfo setValue:[webView.URL absoluteString] forKey:@"requestUrl"];
            [userInfo setValue:[error localizedDescription] forKey:@"error"];
            
            [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationWebFailedLoad object:nil userInfo:userInfo.copy];
        }];
        
    }];
}

@end
