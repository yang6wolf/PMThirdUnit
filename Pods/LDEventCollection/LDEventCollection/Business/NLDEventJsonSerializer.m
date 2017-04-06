//
//  NLDEventJsonSerializer.m
//  LDEventCollection
//
//  Created by SongLi on 5/24/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDEventJsonSerializer.h"

@implementation NLDEventJsonSerializer

- (NSData *)dataWithObject:(NSDictionary *)entity
{
    return [NSJSONSerialization dataWithJSONObject:entity options:0 error:NULL];
}

- (NSData *)dataWithObjects:(NSArray<NSDictionary *> *)entityArray
{
    return [NSJSONSerialization dataWithJSONObject:entityArray options:0 error:NULL];
}

@end
