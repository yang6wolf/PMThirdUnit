//
//  NSMutableArray+String.h
//  NeteaseLottery
//
//  Created by xuguoxing on 12-5-17.
//  Copyright (c) 2012年 netease. All rights reserved.
//  合并数组（字符串数组）、数组中字符串排序

#import <Foundation/Foundation.h>

@interface NSMutableArray (String)

- (void)mergeStringArray:(NSArray *)array;

- (void)sortString;

- (void)revertSortString;

@end
