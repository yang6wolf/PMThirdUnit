//
//  DataBackupPool.m
//  YouHui
//
//  Created by  on 11-11-16.
//  Copyright (c) 2011年 netease. All rights reserved.
//

#import "NFBDataBackupPool.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NFBDataBackupPool


+(NSString *) imageDir{
    NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/fbimgcache/"];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cacheDirectory;
}

+ (NSString *)fileNameForKey:(NSString*)key
{
    const char* str = [key UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *returnHashSum = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [returnHashSum appendFormat:@"%02x", result[i]];
    }
	return returnHashSum;
}


+(void)addData:(NSData *)data forKey:(NSString *)key autoexpire:(BOOL)autoexpire expire:(NSString *)expire {
    if ([key length]==0) {
        return;
    }
    NSString *filename = [[NFBDataBackupPool imageDir] stringByAppendingString:[self fileNameForKey:key]];
    [data writeToFile:filename atomically:YES];
}

+(void)addData:(NSData *)data forKey:(NSString *)key expire:(NSString *)expire {
    if (!data || !key) {
        return;
    }
    if (expire==nil) {
        [self addData:data forKey:key];
    } else {
        [self addData:data forKey:key autoexpire:NO expire:expire];
    }
}

+(void)addData:(NSData *)data forKey:(NSString*)key {
    if (!data || !key) {
        return;
    }
    
    [self addData:data forKey:key autoexpire:YES expire:nil];
}

+(NSData *) dataForKey:(NSString *)key{
    if (! key) {
        return nil;
    }
    NSString *filename = [[NFBDataBackupPool imageDir] stringByAppendingString:[self fileNameForKey:key]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return [NSData dataWithContentsOfFile:filename];
    }else{
        return nil;
    }
}

+(BOOL) hasDataForKey:(NSString *)key{
    if (! key) {
        return NO;
    }
    NSString *filename = [[NFBDataBackupPool imageDir] stringByAppendingString:[self fileNameForKey:key]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return YES;
    }else{
        return NO;
    }
}

@end


