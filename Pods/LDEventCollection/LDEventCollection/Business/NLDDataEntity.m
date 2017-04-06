//
//  NLDDataEntity.m
//  LDEventCollection
//
//  Created by SongLi on 5/17/16.
//  Copyright © 2016 netease. All rights reserved.
//

#define NLDDataEntityKey(obj) @#obj

#import "NLDDataEntity.h"
#import <objc/runtime.h>

@interface NLDDataEntity ()
@property (nonatomic, strong) Protocol *protocol;
@property (nonatomic, strong) NSMutableDictionary *dataDict;
@end


@implementation NLDDataEntity

#pragma mark Public Methods

- (nullable instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)dict
{
    return [self initWithDictionary:dict protocol:nil];
}

- (nullable instancetype)initWithProtocol:(nullable Protocol *)protocol
{
    return [self initWithDictionary:nil protocol:protocol];
}

- (nullable instancetype)initWithDictionary:(nullable NSDictionary<NSString *, id> *)dict protocol:(nullable Protocol *)protocol
{
    self->_dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    self->_protocol = protocol;
    return self;
}

- (NSDictionary<NSString *, id> *)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:self->_dataDict.count];
    [self->_dataDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NLDDataEntity.self]) {
            dict[key] = [(NLDDataEntity *)obj toDictionary];
        } else {
            dict[key] = obj;
        }
    }];
    return dict.copy;
}

- (NSString *)description
{
    return [self->_dataDict description];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ %p\n<protocol>:%@, <data>:%@", NSStringFromClass(NLDDataEntity.self), self, NSStringFromProtocol(self->_protocol), [self->_dataDict description]];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    if (protocol_isEqual(aProtocol, self->_protocol)) {
        return YES;
    }
    return [super conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    SEL changedSelector = aSelector;
    if ([self propertyNameScanFromGetterSelector:aSelector]) {
        changedSelector = @selector(objectForKey:);
    } else if ([self propertyNameScanFromSetterSelector:aSelector]) {
        changedSelector = @selector(setObject:forKey:);
    }
    return [[self->_dataDict class] instancesRespondToSelector:changedSelector];
}

- (BOOL)isKindOfClass:(Class)aClass
{
    for (Class tcls = [self class]; tcls; tcls = class_getSuperclass(tcls)) {
        if (tcls == aClass) return YES;
    }
    return NO;
}


#pragma mark Coding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self->_dataDict forKey:NLDDataEntityKey(_dataDict)];
    [aCoder encodeObject:NSStringFromProtocol(self->_protocol) forKey:NLDDataEntityKey(_protocol)];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *dict = [aDecoder decodeObjectOfClass:NLDDataEntity.self forKey:NLDDataEntityKey(_dataDict)];
    NSString *protocol = [aDecoder decodeObjectOfClass:NLDDataEntity.self forKey:NLDDataEntityKey(_protocol)];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return [self initWithDictionary:dict protocol:NSProtocolFromString(protocol)];
    }
    return nil;
}


#pragma mark Message Forwading

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // Change method signature to NSMutableDictionary's
    // getter -> objectForKey:
    // setter -> setObject:forKey:
    
    SEL changedSelector = aSelector;
    
    if ([self propertyNameScanFromGetterSelector:aSelector]) {
        changedSelector = @selector(objectForKey:);
    } else if ([self propertyNameScanFromSetterSelector:aSelector]) {
        changedSelector = @selector(setObject:forKey:);
    }
    
    return [[self->_dataDict class] instanceMethodSignatureForSelector:changedSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *propertyName = nil;
    
    // Try getter
    propertyName = [self propertyNameScanFromGetterSelector:invocation.selector];
    if (propertyName) {
        invocation.selector = @selector(objectForKey:);
        [invocation setArgument:&propertyName atIndex:2]; // self, _cmd, key
        [invocation invokeWithTarget:self->_dataDict];
        return;
    }
    
    // Try setter
    propertyName = [self propertyNameScanFromSetterSelector:invocation.selector];
    if (propertyName) {
        invocation.selector = @selector(setValue:forKey:);
        [invocation setArgument:&propertyName atIndex:3]; // self, _cmd, obj, key
        [invocation invokeWithTarget:self->_dataDict];
        return;
    }
    
    if ([[self->_dataDict class] instancesRespondToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self->_dataDict];
    }
}


#pragma mark Helpers

- (NSString *)propertyNameScanFromGetterSelector:(SEL)selector
{
    if (!self->_protocol) {
        return nil;
    }
    
    NSString *propertyName = NSStringFromSelector(selector);
    NSUInteger parameterCount = [[propertyName componentsSeparatedByString:@":"] count] - 1;
    if (parameterCount == 0) {
        objc_property_t property = protocol_getProperty(self->_protocol, [propertyName cStringUsingEncoding:NSASCIIStringEncoding], YES, YES);
        if (property != NULL) {
            return propertyName;
        }
    }
    return nil;
}

- (NSString *)propertyNameScanFromSetterSelector:(SEL)selector
{
    if (!self->_protocol) {
        return nil;
    }
    
    NSString *selectorName = NSStringFromSelector(selector);
    NSUInteger parameterCount = [[selectorName componentsSeparatedByString:@":"] count] - 1;
    if ([selectorName hasPrefix:@"set"] && parameterCount == 1) {
        NSMutableString *propertyName = [selectorName substringWithRange:NSMakeRange(3, selectorName.length - 4)].mutableCopy;
        objc_property_t property = protocol_getProperty(self->_protocol, [propertyName cStringUsingEncoding:NSASCIIStringEncoding], YES, YES);
        if (property != NULL) {
            return propertyName.copy;
        }
        [propertyName replaceCharactersInRange:NSMakeRange(0, 1) withString:[propertyName substringToIndex:1].lowercaseString];
        property = protocol_getProperty(self->_protocol, [propertyName cStringUsingEncoding:NSASCIIStringEncoding], YES, YES);
        if (property != NULL) {
            return propertyName.copy;
        }
    }
    return nil;
}

@end
