//
//  NTProtocolProxy.m
//  ProxyTest
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NFBAppearanceProxy.h"
#import "NFBDefaultAppearance.h"



@implementation NFBAppearanceProxy {
    id _realObject1;
    id _realObject2;
}

+ (NFBAppearanceProxy*)sharedAppearance {
    static NFBAppearanceProxy *gProxyInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         gProxyInstance = [NFBAppearanceProxy alloc];
    });
    return gProxyInstance;
}


- (void)setDefaultAppearance:(id<NFBAppearance>)defaultAppearance
{
    _realObject2 = defaultAppearance;
}

- (void)setCustomAppearance:(id<NFBAppearance>)customAppearance
{
    _realObject1 = customAppearance;
}

- (void)clearProxy {
    _realObject2 = nil;
    _realObject1 = nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig;
    sig = [_realObject1 methodSignatureForSelector:aSelector];
    if (sig) return sig;
    sig = [_realObject2 methodSignatureForSelector:aSelector];
    return sig;
}

// Invoke the invocation on whichever real object had a signature for it.
- (void)forwardInvocation:(NSInvocation *)invocation {
    id target = [_realObject1 respondsToSelector:[invocation selector]] ? _realObject1 : _realObject2;
    [invocation invokeWithTarget:target];
}

// Override some of NSProxy's implementations to forward them...
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_realObject1 respondsToSelector:aSelector]) return YES;
    if ([_realObject2 respondsToSelector:aSelector]) return YES;
    return NO;
}

@end
