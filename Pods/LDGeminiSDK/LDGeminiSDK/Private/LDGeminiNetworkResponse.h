//
//  LDGeminiNetworkResponse.h
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import <Foundation/Foundation.h>

@interface LDGeminiNetworkResponse : NSObject

@property (nonatomic, strong, nullable) NSData *data;
@property (nonatomic, strong, nullable) NSURLResponse *response;
@property (nonatomic, strong, nullable) NSError *error;

- (instancetype)initWithData:(nullable NSData *)data
                 URLResponse:(nullable NSURLResponse *)response
                       error:(nullable NSError *)error;

@end
