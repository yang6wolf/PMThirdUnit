//
//  NFBNetworkDiagnoser.m
//  NTFeedBack
//
//  Created by  龙会湖 on 11/28/14.
//  Copyright (c) 2014 netease. All rights reserved.
//

#import "NFBNetworkDiagnoser.h"
#import "LDNetDiagnoService.h"
#import "NFBHttpRequest.h"
#import "NFBConfig.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#define NETWORK_RESULT_UNKNOWN @"unknown"

@interface NFBNetworkDiagnoser()<LDNetDiagnoServiceDelegate>

@end

@implementation NFBNetworkDiagnoser {
    LDNetDiagnoService *_service;
    NSMutableArray *_domains;
}

+ (instancetype)sharedInstance {
    static NFBNetworkDiagnoser *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NFBNetworkDiagnoser alloc] init];
    });
    return instance;
}


- (void)start {
    if (_service) return;
    
    _domains = [[NFBConfig sharedConfig].domains mutableCopy];
    if (_domains.count==0) {
        return;
    }
    
    [self startDiagnoseDomain:_domains[0]];
}


- (NSString *)carrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    if (carrier && carrier.carrierName) {
        return carrier.carrierName;
    } else {
        return NETWORK_RESULT_UNKNOWN;
    }
}

- (NSString *)mobileCountryCode {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    if (carrier && carrier.mobileCountryCode) {
        return carrier.mobileCountryCode;
    } else {
        return NETWORK_RESULT_UNKNOWN;
    }
}

- (NSString *)mobileNetworkCode {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    if (carrier && carrier.mobileNetworkCode) {
        return carrier.mobileNetworkCode;
    } else {
        return NETWORK_RESULT_UNKNOWN;
    }
}

- (void)startDiagnoseDomain:(NSString*)domain {
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
    
    _service.delegate = nil;
    _service = nil;
    
    _service = [[LDNetDiagnoService alloc] initWithAppCode:[NFBConfig sharedConfig].productId
                                                   appName:appName
                                                    appVersion:[[NFBConfig sharedConfig] version]
                                                    userID:[NFBConfig sharedConfig].accountId
                                                  deviceID:[NFBConfig sharedConfig].deviceId
                                                   dormain:domain
                                               carrierName:self.carrierName
                                            ISOCountryCode:nil
                                         MobileCountryCode:self.mobileCountryCode
                                             MobileNetCode:self.mobileNetworkCode];
    
    _service.delegate = self;
    [_service startNetDiagnosis];
}

- (void)completeDiagnose {
    _service.delegate = nil;
    _service = nil;
}

-(void)netDiagnosisDidStarted {
    
}

-(void)netDiagnosisStepInfo:(NSString *)stepInfo {
    
}


-(void)netDiagnosisDidEnd:(NSString *)allLogInfo {
    if (!allLogInfo) {
        allLogInfo = @"";
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:allLogInfo forKey:@"msg"];
    [NFBHttpRequest startRequestWithUrl:[[NFBConfig sharedConfig].host stringByAppendingString:@"/service/networkDiagnosisFeedback.do"]
                                 params:params
             completionBlockWithSuccess:^(NSURLSessionDataTask *dataTask, id responseObject) {
                 [_domains removeObjectAtIndex:0];
                 if (_domains.count>0) {
                     [self startDiagnoseDomain:_domains[0]];
                 } else {
                     [self completeDiagnose];
                 }
             }
                                failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                                    [self completeDiagnose];
                                    
                                }];
    

}

@end
