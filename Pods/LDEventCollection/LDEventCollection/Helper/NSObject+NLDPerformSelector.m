//
//  NSObject+NLDPerformSelector.m
//  Pods
//
//  Created by 高振伟 on 16/6/22.
//
//

#import "NSObject+NLDPerformSelector.h"
#import <objc/runtime.h>
#import <objc/message.h>

// 为了解决与 Aspects 库同时Hook方法时的问题
static BOOL NLD_isMsgForwardIMP(IMP impl) {
    return impl == _objc_msgForward
#if !defined(__arm64__)
    || impl == (IMP)_objc_msgForward_stret
#endif
    ;
}

@implementation NSObject (NLDPerformSelector)

- (BOOL)invokeSelector:(SEL)aSelector withArguments:(nullable NSArray *)arguments
{
    return [self invokeSelector:aSelector withArguments:arguments retureValue:NULL];
}

- (BOOL)invokeSelector:(SEL)aSelector withArguments:(nullable NSArray *)arguments retureValue:(nullable void *)res
{
    Method targetMethod = class_getInstanceMethod(self.class, aSelector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    
    if (NLD_isMsgForwardIMP(targetMethodIMP)) {
        //1、创建签名对象
        NSString *selStr = NSStringFromSelector(aSelector);
        NSString *delStr;
        if ([selStr hasPrefix:@"NLD_hookUIScrollView"]) {
            delStr = @"NLD_hookUIScrollView";
        } else if ([selStr hasPrefix:@"NLD_hookUITableView"]) {
            delStr = @"NLD_hookUITableView";
        } else if ([selStr hasPrefix:@"NLD_hookUICollectionView"]) {
            delStr = @"NLD_hookUICollectionView";
        } else if ([selStr hasPrefix:@"NLD_hook"]) {
            delStr = @"NLD_hook";
        }
        selStr = [selStr stringByReplacingOccurrencesOfString:delStr withString:@""];
        SEL targetSel = NSSelectorFromString(selStr);
        
        NSMethodSignature*signature = [[self class] instanceMethodSignatureForSelector:targetSel];
        
        //2、判断传入的方法是否存在
        if (signature==nil) {
            return NO;
        }
        
        //3、创建NSInvocation对象
        NSInvocation*invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        //4、保存方法所属的对象
        invocation.target = self;
        invocation.selector = targetSel;
        
        //5、设置参数
        if (arguments) {
            for (int i = 0; i < arguments.count; i++) {
                NSObject *obj = arguments[i];
                //处理参数是NULL类型的情况
                if ([obj isKindOfClass:[NSNull class]]) {
                    obj = nil;
                }
                //处理参数是SEL类型的情况
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([(NSString *)obj hasPrefix:@"SEL_"]) {
                        SEL sel = NSSelectorFromString([(NSString *)obj substringFromIndex:4]);
                        [invocation setArgument:&sel atIndex:i+2];
                        continue;
                    }
                }
                
                [invocation setArgument:&obj atIndex:i+2];
            }
        }
        
        [self forwardInvocation:invocation];
        
        // 6、获取返回值
        if (res) {
            [invocation getReturnValue:res];
        }
        
        return YES;
    }
    
    return NO;
}

- (nullable NSObject *)objectOrNull
{
    return self ?: [NSNull null];
}

- (void)setAdditionalData:(nullable NSDictionary<NSString *, NSString *> *)data
{
    objc_setAssociatedObject(self, @selector(additionalData), data, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable NSDictionary<NSString *, NSString *> *)additionalData
{
    return objc_getAssociatedObject(self, @selector(additionalData));
}

@end

@implementation NSObject (KVCException)

- (nullable id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end
