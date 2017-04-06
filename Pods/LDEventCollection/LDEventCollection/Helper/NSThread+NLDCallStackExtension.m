//
//  NSThread+NLDCallStackExtension.m
//  LDEventCollection
//
//  Created by SongLi on 5/11/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSThread+NLDCallStackExtension.h"
#include <execinfo.h>
#include <string.h>

#define NLD_StackMaxBufferLimit (256)

@implementation NSThread (NLDCallStackExtension)

+ (BOOL)isInternalMethodCallAtIndex:(NSInteger)index
{
    if (index + 2 > NLD_StackMaxBufferLimit) {
        return YES;
    }
    
    static dispatch_once_t onceToken;
    static NSString *productName;
    dispatch_once(&onceToken, ^{
        productName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    });
    
    // 每次获取大概耗时3ms左右
    void *buffer[NLD_StackMaxBufferLimit];
    int count = backtrace(buffer, (int)index + 2);
    if (count >= index + 2) {
        char **strings;
        strings = backtrace_symbols(buffer, count);
        char *subStrIndex = strstr(strings[(int)index + 1], [productName UTF8String]);
        free(strings);
        return (subStrIndex == NULL);
    }
    
    return YES;
    
//    NSArray *stringArr = [self callStackSymbols];
//    NSString *symbol = stringArr[index+1];
//    
//    return [symbol rangeOfString:productName].location == NSNotFound;
}

@end
