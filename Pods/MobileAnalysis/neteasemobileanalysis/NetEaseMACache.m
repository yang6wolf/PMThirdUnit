//
//  CacheManager.m
//  MobileAnalysis
//
//  Created by zhang jie on 13-4-17.
//  Copyright (c) 2013年 zhang jie. All rights reserved.
//

#import "NetEaseMACache.h"
#import "NetEaseMAUtils.h"
#import "JSONKit.h"

#define MOBILE_ANALYSIS_DIR @"mobileagent"
#define SESSION_DIR @"session"
#define PERFORM_DIR @"perform"


@interface NetEaseMACache()
@property(nonatomic,strong) NSString *sessionCacheDirectory;
@property(nonatomic,strong) NSString *performCacheDirectory;
@end

@implementation NetEaseMACache


- (id)init {
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *cacheFileDirectory=[documentsDirectory stringByAppendingPathComponent:MOBILE_ANALYSIS_DIR];
        self.sessionCacheDirectory = [cacheFileDirectory stringByAppendingPathComponent:SESSION_DIR];
        self.performCacheDirectory = [cacheFileDirectory stringByAppendingPathComponent:PERFORM_DIR];

        [[NSFileManager defaultManager] createDirectoryAtPath:self.sessionCacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:self.performCacheDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return self;
}

- (void)removeCachedFiles:(NSArray*)fileArray {
    for (NSString *path in fileArray) {
#ifdef DEBUG
        if([path rangeOfString:SESSION_DIR].location == NSNotFound){
            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];

            NSMutableString *sendContent = [[NSMutableString alloc] initWithCapacity:200];
            if([jsonData objectForKey:@"i"] != nil){
                [sendContent appendFormat:@"info==%@\n", jsonData[@"i"]];
            }

            if([jsonData objectForKey:@"launch"] != nil){
                [sendContent appendFormat:@"launch==%@\n", jsonData[@"launch"]];
                NSDictionary *dict = jsonData[@"launch"];
                int duration = (int)([dict[@"et"] longLongValue] - [dict[@"st"] longLongValue]);
                [sendContent appendFormat:@"app startup time====%dms\n", duration];
            }

            if([jsonData objectForKey:@"dns"] != nil){
                [sendContent appendFormat:@"dns==%@\n", jsonData[@"dns"]];
            }

            if([jsonData objectForKey:@"url"] != nil){
                NSArray *urlTimeArray = [jsonData objectForKey:@"url"];
                for(NSDictionary *dict in urlTimeArray){
                    long long et = [dict[@"et"] longLongValue];
                    long long st = [dict[@"st"] longLongValue];
                    int code = [dict[@"c"] intValue];
                    int rxBytes = 0;
                    int txBytes = 0;
                    if(code != 1000){
                        rxBytes = [dict[@"rx"] intValue];
                        txBytes = [dict[@"tx"] intValue];
                    }
                    int duration = (int)((et - st));
                    [sendContent appendFormat:@"delay:%dms\tcode:%d\t\tup:%dBytes\tdown:%dBytes\t%@\t\n", duration, code, txBytes, rxBytes, dict[@"n"]];
                }
            }

            NSLog(@"====================================");
            NSLog(@"%@", sendContent);
            NSLog(@"====================================");
        }
#endif
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            NSLog(@"|||||delete file====%@|||", path);
        }
    }
}


-(void)saveSessionTrunk:(NSDictionary*)dict {
    NSString *string = [self.sessionCacheDirectory stringByAppendingPathComponent:[NetEaseMaUtils createUUIDString]];
    [[dict JSONData] writeToFile:string atomically:YES];
}


- (NSArray*)getCachedSessionFiles {
    return [self getCachedFilesInDirectory:self.sessionCacheDirectory];
}


#pragma cache performance data
-(void)savePerformanceTrunk:(NSDictionary*)dict {
    NSString *string = [self.performCacheDirectory stringByAppendingPathComponent:[NetEaseMaUtils createUUIDString]];
    [[dict JSONData] writeToFile:string atomically:YES];
}

- (NSArray*)getCachedPerformanceFiles {
    return [self getCachedFilesInDirectory:self.performCacheDirectory];
}


#pragma private
- (NSArray*)getCachedFilesInDirectory:(NSString*)directory {
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *filePathArray = [NSMutableArray array];
    for (NSString *file in fileArray) {
        NSString *filePath = [directory stringByAppendingPathComponent:file];
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
        if ([[fileAttr fileCreationDate] timeIntervalSinceNow]<-5*24*60*60) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
            continue;
        }
        [filePathArray addObject:filePath];
    }
    return filePathArray;
}


@end
