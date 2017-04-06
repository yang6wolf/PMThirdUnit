//
//  NSMutableArray+Safe.h
//  Pods
//
//  Created by yangning on 15-2-11.
//
//  对象不为空的情况下添加对象到数组中

#import <Foundation/Foundation.h>

@interface NSMutableArray (Safe)

- (void)safeAddObject:(id)anObject;

@end
