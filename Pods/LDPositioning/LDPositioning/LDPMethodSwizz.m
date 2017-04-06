//
//  LDPMethodSwizz.m
//  LDPositioningDemo
//
//  Created by 高振伟 on 16/8/15.
//  Copyright © 2016年 wuxu. All rights reserved.
//

#import "LDPMethodSwizz.h"
#import <objc/runtime.h>

BOOL LDP_replaceMethodWithBlock(Class c, SEL origSEL, SEL newSEL, id block) {
    if ([c instancesRespondToSelector:newSEL]) return YES; // Selector already implemented, skip silently.
    Method origMethod = class_getInstanceMethod(c, origSEL);
    IMP impl = imp_implementationWithBlock(block);
    if (!class_addMethod(c, newSEL, impl, method_getTypeEncoding(origMethod))) {
        return NO;
    }else {
        Method newMethod = class_getInstanceMethod(c, newSEL);
        if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(origMethod))) {
            class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(newMethod));
        }else {
            method_exchangeImplementations(origMethod, newMethod);
        }
    }
    return YES;
}
