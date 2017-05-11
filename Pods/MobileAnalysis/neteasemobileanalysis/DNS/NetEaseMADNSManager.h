//
//  NetEaseMADNSManager.h
//  MobileAnalysis
//
//  Created by wangjiale on 2017/4/5.
//  Copyright © 2017年 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NeteaseMASessionHTTPProtocol.h"

@interface NetEaseMADNSManager : NSObject

@property (nonatomic, weak) id<NeteaseMAHTTPProtocolDelegate> delegate;

+ (instancetype)shareInstance;
- (void)setDNSTrackerDomains:(NSArray *)domains;

@end
