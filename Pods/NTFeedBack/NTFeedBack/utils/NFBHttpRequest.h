//
//  FeedBackHttpRequest.h
//  movie163
//
//  Created by ypchen on 14-5-16.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface NFBHttpRequest : NSObject

+ (void)startRequestWithUrl:(NSString*)url params:(NSDictionary*)params
 completionBlockWithSuccess:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;

+ (void)startRequestWithUrl:(NSString*)url params:(NSDictionary*)params image:(UIImage*)img
 completionBlockWithSuccess:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;

+ (void)startRequestWithUrl:(NSString*)url params:(NSDictionary*)params image:(UIImage*)img
 completionBlockWithSuccess:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure
              progressBlock:(void (^)(NSUInteger uploadProgress))progressBlock;

@end
