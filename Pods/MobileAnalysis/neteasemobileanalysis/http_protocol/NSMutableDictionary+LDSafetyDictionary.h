//
//  NSMutableDictionary+LDSafetyDictionary.h
//  MobileAnalysis
//
//  Created by wangjiale on 2017/4/5.
//  Copyright © 2017年 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (LDSafetyDictionary)

- (void)_safety_setObject:(id)object forKey:(NSString *)key;
- (void)_safety_setInteger:(long long)integer forKey:(NSString *)key;

@end
