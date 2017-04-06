//
//  NSMutableDictionary+Safe.h
//  Pods
//
//  Created by yangning on 15-2-11.
//
//  key和value都不为空时，为字典添加一项

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safe)

- (void)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
