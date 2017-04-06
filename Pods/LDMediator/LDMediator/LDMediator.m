//
//  LDMediator.m
//  NeteaseLottery
//
//  Created by wuxu on 16/5/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "LDMediator.h"

@interface LDMediator ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id(^)()> *servicesByProtocolStr;
@property (nonatomic, strong) NSLock *registerLock;
@end

@implementation LDMediator

#pragma mark - init

+ (instancetype)shared
{
    static LDMediator *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _servicesByProtocolStr = [NSMutableDictionary dictionary];
        _registerLock = [NSLock new];
    }
    return self;
}

#pragma mark - service

+ (nullable NSSet<Protocol *> *)allServiceProtocol
{
    if ([LDMediator shared].servicesByProtocolStr.count == 0) {
        return nil;
    }
    
    NSSet<NSString *> *protocolsStr = [NSSet setWithArray:[[LDMediator shared].servicesByProtocolStr allKeys]];
    
    __block NSMutableSet *mProtocols = [NSMutableSet set];
    
    [protocolsStr enumerateObjectsUsingBlock:^(NSString * _Nonnull protocolStr, BOOL * _Nonnull stop) {
        [mProtocols addObject:NSProtocolFromString(protocolStr)];
    }];
    
    return [mProtocols copy];
}

+ (BOOL)registerService:(Protocol *)serviceProtocol withImpl:(id (^)())block
{
    NSParameterAssert(serviceProtocol != nil);
    NSParameterAssert(block != nil);
    
    if (!serviceProtocol || !block) {
        return NO;
    }
    
    [[LDMediator shared].registerLock lock];
    
    //防止重复添加协议
    if ([[LDMediator shared].servicesByProtocolStr objectForKey:NSStringFromProtocol(serviceProtocol)]) {
        [[LDMediator shared].registerLock unlock];
        
#if DEBUG
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 协议已经注册", NSStringFromProtocol(serviceProtocol)] userInfo:nil];
#endif
        
        return NO;
    }
    
#if DEBUG
    //防止对象没有实现协议
    id instance = block();
    if (![[instance class] conformsToProtocol:serviceProtocol]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 服务不符合 %@ 协议", NSStringFromClass([instance class]), NSStringFromProtocol(serviceProtocol)] userInfo:nil];
    }
#endif
    
    NSString *protocolName = NSStringFromProtocol(serviceProtocol);
    if (protocolName) {
        [[LDMediator shared].servicesByProtocolStr setObject:[block copy] forKey:protocolName];
        
#if DEBUG
        NSLog(@"%@ 协议注册成功", NSStringFromProtocol(serviceProtocol));
#endif
        
        [[LDMediator shared].registerLock unlock];
        return YES;
    }
    
    [[LDMediator shared].registerLock unlock];
    return NO;
}

+ (void)unregisterService:(Protocol *)serviceProtocol
{
    NSParameterAssert(serviceProtocol != nil);
    
    if (!serviceProtocol) {
        return ;
    }
    
    [[LDMediator shared].registerLock lock];
    
    if (![[LDMediator shared].servicesByProtocolStr objectForKey:NSStringFromProtocol(serviceProtocol)]) {
        
#if DEBUG
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 协议未被注册，因此反注册失败", NSStringFromProtocol(serviceProtocol)] userInfo:nil];
#endif
        
    } else {
        [[LDMediator shared].servicesByProtocolStr removeObjectForKey:NSStringFromProtocol(serviceProtocol)];
        
#if DEBUG
        NSLog(@"%@ 协议反注册成功", NSStringFromProtocol(serviceProtocol));
#endif
    }
    
    [[LDMediator shared].registerLock unlock];
}

+ (nullable id)findService:(Protocol *)serviceProtocol
{
    id (^block)() = [[LDMediator shared].servicesByProtocolStr objectForKey:NSStringFromProtocol(serviceProtocol)];
    
    if (block) {
        return block();
    }
    
    return nil;
}

@end
