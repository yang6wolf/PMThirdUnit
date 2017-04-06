//
//  NSNotificationCenter+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSNotificationCenter+NLDEventCollection.h"

@implementation NSNotificationCenter (NLDEventCollection)

+ (void)NLD_postEventCollectionNotificationName:(NSString *)name object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSDictionary *userInfo = [self removeSwiftModuleInPage:aUserInfo];
        [[self defaultCenter] postNotificationName:name object:anObject userInfo:userInfo];
    });
}

+ (void)NLD_postMethodHookNotificationName:(NSString *)name userInfo:(nullable NSDictionary *)aUserInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[self defaultCenter] postNotificationName:name object:nil userInfo:aUserInfo];
    });
}


+ (NSDictionary *)removeSwiftModuleInPage:(NSDictionary *)originDict
{
    NSString *pageName = [originDict objectForKey:@"controller"];
    if (!pageName) {
        return originDict;
    }
    
    if ([pageName rangeOfString:@"."].location != NSNotFound) {
        NSMutableDictionary *resultDict = originDict.mutableCopy;
        NSArray *stringComponents = [pageName componentsSeparatedByString:@"."];
        if (stringComponents.count == 2) {
            NSString *newPageName = stringComponents[1];
            [resultDict setValue:newPageName forKey:@"controller"];
            return resultDict.copy;
        }
    }
    
    return originDict;
}

@end
