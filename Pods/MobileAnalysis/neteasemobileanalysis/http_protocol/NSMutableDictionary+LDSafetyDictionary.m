//
//  NSMutableDictionary+LDSafetyDictionary.m
//  MobileAnalysis
//
//  Created by wangjiale on 2017/4/5.
//  Copyright © 2017年 zhang jie. All rights reserved.
//

#import "NSMutableDictionary+LDSafetyDictionary.h"

@implementation NSMutableDictionary (LDSafetyDictionary)

- (void)_safety_setObject:(id)object forKey:(NSString *)key {
    object = object ? : @"";
    [self setObject:object forKey:key];
}

- (void)_safety_setInteger:(long long)integer forKey:(NSString *)key {
    [self _safety_setObject:@(integer) forKey:key];
}

@end
