//
//  LDGeminiNetworkResponse.m
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import "LDGeminiNetworkResponse.h"

@implementation LDGeminiNetworkResponse

- (instancetype)initWithData:(NSData *)data URLResponse:(NSURLResponse *)response error:(NSError *)error {
    self = [super init];
    if (self) {
        _data = data;
        _response = response;
        _error = error;
    }
    return self;
}

@end
