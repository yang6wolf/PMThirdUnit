//
//  NSMutableDictionary+Safe.m
//  Pods
//
//  Created by yangning on 15-2-11.
//
//

#import "NSMutableDictionary+Safe.h"

@implementation NSMutableDictionary (Safe)

- (void)safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject != nil && aKey != nil) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
