//
//  NSObject+MethodSwizzle.m
//  LDEventCollection
//
//  Created by 高振伟 on 16/10/5.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSObject+MethodSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzle)

static char *methodTypesInProtocol(Protocol *protocol, NSString *selectorName, BOOL isInstanceMethod, BOOL isRequired)
{
    if (!protocol) {
        return NULL;
    }
    
    unsigned int selCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, isRequired, isInstanceMethod, &selCount);
    for (int i = 0; i < selCount; i++) {
        if ([selectorName isEqualToString:NSStringFromSelector(methods[i].name)]) {
            char *types = malloc(strlen(methods[i].types) + 1);
            strcpy(types, methods[i].types);
            free(methods);
            return types;
        }
    }
    free(methods);
    return NULL;
}

+ (BOOL)NLD_swizzSelector:(SEL)originSelector referProtocol:(Protocol *)referToProtocol newSel:(SEL)newSelector usingBlock:(id)block
{
    Class cls = [self class];
    if (!cls || !originSelector || !newSelector || !block) {
        return NO;
    }
    
    if (class_respondsToSelector(cls, newSelector)) {
        return YES;
    }
    
    IMP originIMP = class_respondsToSelector(cls, originSelector) ? class_getMethodImplementation(cls, originSelector) : NULL;
    if (imp_getBlock(originIMP)) {
        return YES;
    }
    IMP newIMP = imp_implementationWithBlock(block);
    
    char *typeDesc = NULL;
    Method origMethod = class_getInstanceMethod(cls, originSelector);
    if (origMethod) {
        const char *type = method_getTypeEncoding(origMethod);
        typeDesc = malloc(strlen(type) + 1);
        strcpy(typeDesc, type);
    } else {
        typeDesc = methodTypesInProtocol(referToProtocol, NSStringFromSelector(originSelector), YES, YES);
        if (!typeDesc) {
            typeDesc = methodTypesInProtocol(referToProtocol, NSStringFromSelector(originSelector), YES, NO);
        }
    }
    if (typeDesc == NULL) {
        return NO;
    }
    
    class_replaceMethod(cls, originSelector, newIMP, typeDesc); // 没有就加，有就替换
    
    if (!originIMP) {
        free(typeDesc);
        return YES;
    }
    
    if (!class_addMethod(cls, newSelector, originIMP, typeDesc)) {
        class_replaceMethod(cls, originSelector, originIMP, typeDesc);
        free(typeDesc);
        return NO;
    }
    
    free(typeDesc);
    return YES;
}

+ (void)NLD_swizzStaticSel:(SEL)origSelector newSel:(SEL)newSelector
{
    Class cls = [self class];
    if (!cls || !origSelector || !newSelector) {
        return;
    }
    
    Method originalMethod = class_getClassMethod(cls, origSelector);
    Method swizzledMethod = class_getClassMethod(cls, newSelector);
    
    Class metacls = objc_getMetaClass([NSStringFromClass(cls) UTF8String]);
    if (class_addMethod(metacls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        class_replaceMethod(metacls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
