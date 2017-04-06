//
//  NSMutableDictionary+NLDUUID.m
//  LDEventCollection
//
//  Created by SongLi on 6/1/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSMutableDictionary+NLDUUID.h"
#import "NSString+NLDAddition.h"

@implementation NSMutableDictionary (NLDUUID)

- (nullable NSString *)NLD_setObjectOrNilForRandomUUID:(id)obj
{
    if (obj == nil) {
        return nil;
    }
    
    NSString *uuidString = [NSString NLD_RandomUUIDString];
    [self setObject:obj forKey:uuidString];
    return uuidString;
}

@end
