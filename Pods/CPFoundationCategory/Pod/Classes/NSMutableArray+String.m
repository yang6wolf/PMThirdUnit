//
//  NSMutableArray+String.m
//  NeteaseLottery
//
//  Created by xuguoxing on 12-5-17.
//  Copyright (c) 2012年 netease. All rights reserved.
//

#import "NSMutableArray+String.h"

NSInteger sort(id object1, id object2, void *context) {
    NSString *string1 = (NSString *) object1;
    NSString *string2 = (NSString *) object2;
    return [string1 compare:string2];
}

NSInteger revertSort(id object1, id object2, void *context) {
    NSString *string1 = (NSString *) object1;
    NSString *string2 = (NSString *) object2;
    return [string2 compare:string1];
}

@implementation NSMutableArray (String)

- (void)mergeStringArray:(NSArray *)array
{
    if (self.count > 0) {
        id object = [self objectAtIndex:0];
        if (![object isKindOfClass:[NSString class]]) {
            return;
        }
    }
    if (array.count <= 0) {
        return;
    }
    id object = [array objectAtIndex:0];
    if (![object isKindOfClass:[NSString class]]) {
        return;
    }
    for (NSString *outString in array) {
        BOOL find = NO;
        for (NSString *inString in self) {
            if ([outString isEqualToString:inString]) {
                find = YES;
                break;
            }
        }
        if (find == NO) {
            [self addObject:outString];
        }

    }
}

- (void)sortString
{
    if (self.count > 0) {
        id object = [self objectAtIndex:0];
        if (![object isKindOfClass:[NSString class]]) {
            return;
        }
    }
    [self sortUsingFunction:sort context:nil];
}

- (void)revertSortString
{
    if (self.count > 0) {
        id object = [self objectAtIndex:0];
        if (![object isKindOfClass:[NSString class]]) {
            return;
        }
    }
    [self sortUsingFunction:revertSort context:nil];
}

@end
