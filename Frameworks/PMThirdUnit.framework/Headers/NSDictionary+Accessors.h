//
//  NSDictionary+Accessors.h
//  Belle
//
//  Created by Allen Hsu on 1/11/14.
//  Copyright (c) 2014 Allen Hsu. All rights reserved.
//  根据key处理value的类型

#import <Foundation/Foundation.h>

@interface NSDictionary (Accessors)

- (BOOL)cp_isKindOfClass:(Class)aClass forKey:(NSString *)key;

- (BOOL)cp_isMemberOfClass:(Class)aClass forKey:(NSString *)key;

- (BOOL)cp_isArrayForKey:(NSString *)key;

- (BOOL)cp_isDictionaryForKey:(NSString *)key;

- (BOOL)cp_isStringForKey:(NSString *)key;

- (BOOL)cp_isNumberForKey:(NSString *)key;

- (NSArray *)cp_arrayForKey:(NSString *)key;

- (NSDictionary *)cp_dictionaryForKey:(NSString *)key;

- (NSString *)cp_stringForKey:(NSString *)key;

- (NSNumber *)cp_numberForKey:(NSString *)key;

- (double)cp_doubleForKey:(NSString *)key;

- (float)cp_floatForKey:(NSString *)key;

- (int)cp_intForKey:(NSString *)key;

- (unsigned int)cp_unsignedIntForKey:(NSString *)key;

- (NSInteger)cp_integerForKey:(NSString *)key;

- (NSUInteger)cp_unsignedIntegerForKey:(NSString *)key;

- (long long)cp_longLongForKey:(NSString *)key;

- (unsigned long long)cp_unsignedLongLongForKey:(NSString *)key;

- (BOOL)cp_boolForKey:(NSString *)key;

@end
