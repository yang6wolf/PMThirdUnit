//
//  NFBConfig.h
//  NTFeedBack
//
//  Created by  龙会湖 on 14-7-21.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFBConfig : NSObject
@property(nonatomic,strong) NSString *host;
@property(nonatomic,strong) NSString *product;
@property(nonatomic,strong) NSString *productId;
@property(nonatomic,strong) NSString *deviceId;
@property(nonatomic,strong) NSString *version;
@property(nonatomic,strong) NSString *channel;
@property(nonatomic,strong) NSString *helpLink;
@property(nonatomic,strong) NSString *accountId;
@property(nonatomic,strong) NSString *servicePhone;
@property(nonatomic,strong) NSMutableArray *domains;
+ (NFBConfig*)sharedConfig;
@end
