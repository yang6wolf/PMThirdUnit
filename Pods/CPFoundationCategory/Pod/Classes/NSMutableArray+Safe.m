//
//  NSMutableArray+Safe.m
//  Pods
//
//  Created by yangning on 15-2-11.
//
//

#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

- (void)safeAddObject:(id)anObject
{
    if (anObject != nil) {
        [self addObject:anObject];
    }
}

@end
