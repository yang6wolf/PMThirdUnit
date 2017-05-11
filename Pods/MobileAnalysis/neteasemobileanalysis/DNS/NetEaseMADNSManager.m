//
//  NetEaseMADNSManager.m
//  MobileAnalysis
//
//  Created by wangjiale on 2017/4/5.
//  Copyright © 2017年 zhang jie. All rights reserved.
//

#import "NetEaseMADNSManager.h"
#import "NetEaseMADNSTracker.h"

@interface NetEaseMADNSManager()

@property (nonatomic, strong) NSArray *domainArray;

@end

@implementation NetEaseMADNSManager

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t dispatchOnce;
    dispatch_once(&dispatchOnce, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)setDNSTrackerDomains:(NSArray *)domains {
    
    self.domainArray = domains;
    
    for (NSString *host in self.domainArray) {
        [self recordLocalDNSInfo:host];
    }
}

- (void)recordLocalDNSInfo:(NSString *)domain {
    
    NSString *ip = nil;
    
    long time_start = [[NSDate date] timeIntervalSince1970] * 1000;
    NSArray *hostAddress = [NSArray arrayWithArray:[NetEaseMADNSTracker getDNSsWithDormain:domain]];
    int time_duration = [[NSDate date] timeIntervalSince1970] * 1000 - time_start;
    if ([hostAddress count] == 0) {
        ip = @"";
    } else {
        ip = [hostAddress componentsJoinedByString:@","];
    }
    
    if ([_delegate respondsToSelector:@selector(protocolDidCompleteDNSResolve:dnsIP:dnsResolveTime:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate protocolDidCompleteDNSResolve:domain dnsIP:ip dnsResolveTime:time_duration];
        });
    }
}
@end
