//
//  FeedBackHttpRequest.m
//  movie163
//
//  Created by ypchen on 14-5-16.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NFBHttpRequest.h"
#import "NFBConfig.h"
#import "NFBUtil.h"

#define EMPTY_STRING_IF_NIL(a)           (((a) == nil) ? @"" : (a))

@implementation NFBHttpRequest

+ (NSString *)userAgent {
    CGSize size = [[UIScreen mainScreen] currentMode].size;
    NSString *agentString = [NSString stringWithFormat:@"NTES(ios %@;%@;%d*%d) %@/%@",
                             [[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice] model],(int) size.width,(int) size.height,
                             [NFBConfig sharedConfig].product,
                             [NFBConfig sharedConfig].version];
    
    return agentString;
}

+ (NSDictionary*)defaultParams {
  return @{@"product":EMPTY_STRING_IF_NIL([NFBConfig sharedConfig].product),
    @"productId":EMPTY_STRING_IF_NIL([NFBConfig sharedConfig].productId),
    @"accountId":EMPTY_STRING_IF_NIL([NFBConfig sharedConfig].accountId),
    @"mobileType":@"iPhone",
    @"ver":EMPTY_STRING_IF_NIL([NFBConfig sharedConfig].version),
    @"channel":EMPTY_STRING_IF_NIL([NFBConfig sharedConfig].channel),
    @"deviceId":EMPTY_STRING_IF_NIL([NFBConfig sharedConfig].deviceId)};
}

//By default, AFJSONRequestOperation accepts only "text/json", "application/json" or "text/javascript" content-types from server, but you are getting "text/html".
+ (void)startRequestWithUrl:(NSString*)url params:(NSDictionary*)params
 completionBlockWithSuccess:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure {
    
    url = [self appendString:url withUrlParameters:[self defaultParams]];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:url parameters:params progress:nil success:success failure:failure];
}


+ (void)startRequestWithUrl:(NSString*)url params:(NSDictionary*)params image:(UIImage*)img
 completionBlockWithSuccess:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure
{
    [self startRequestWithUrl:url params:params image:img completionBlockWithSuccess:success failure:failure progressBlock:nil];
}

+ (void)startRequestWithUrl:(NSString*)url params:(NSDictionary*)params image:(UIImage*)img
 completionBlockWithSuccess:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure
              progressBlock:(void (^)(NSUInteger uploadProgress))progressBlock
{
    NSData *imageToUpload = UIImageJPEGRepresentation(img, 1.0);
    if (imageToUpload)
    {
        url = [self appendString:url withUrlParameters:[self defaultParams]];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSString *filename = [NSString stringWithFormat:@"%f.jpg",[[NSDate date] timeIntervalSince1970] ];
            [formData appendPartWithFileData: imageToUpload name:@"image" fileName:filename mimeType:@"image/jpeg"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            if (progressBlock) {
                if (uploadProgress.totalUnitCount > 0) {
                    CGFloat progress = (CGFloat)uploadProgress.completedUnitCount/(CGFloat)uploadProgress.totalUnitCount * 100.0f;
                    progressBlock((NSUInteger)progress);
                }
            }
        } success:success failure:failure];
    }
}

+ (NSString*)appendString:(NSString*)string withUrlParameters:(NSDictionary *)params
{
    if (params == nil || [params count] == 0) {
        return string;
    }
    NSMutableString *newString = [string mutableCopy];
    NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *firstKey = [keys objectAtIndex:0];
    NSString *firstValue = [params objectForKey:firstKey];
    
    if ([string rangeOfString:@"="].length != 0) {
        [newString appendFormat:@"&%@=%@", firstKey,[NFBUtil URLEncodedString:firstValue]];
    } else {
        [newString appendFormat:@"?%@=%@", firstKey, [NFBUtil URLEncodedString:firstValue]];
    }
    for (NSUInteger i = 1; i < [keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [params objectForKey:key];
        [newString appendFormat:@"&%@=%@", key, [NFBUtil URLEncodedString:value]];
    }
    return newString;
}

@end
