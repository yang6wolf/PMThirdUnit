//
//  NFBConfig.m
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "NFBConfig.h"

#define SERVICE_PHONE  @"020-83568090"

@implementation NFBConfig

+ (NFBConfig*)sharedConfig {
    static NFBConfig *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[NFBConfig alloc] init];
    });
    return sInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        //对每一个参数初始化，防止因为不传值导致NFBHttpRequest类中方法出错
        self.product = @"";
        self.productId = @"";
        self.deviceId = @"";
        self.version = @"";
        self.channel = @"";
        self.helpLink = @"";
        self.accountId = @"";
        self.host = @"http://chat.zxkf.163.com";    
        self.servicePhone = SERVICE_PHONE;
        
        self.domains = [NSMutableArray array];
    }
    return self;
}

@end
