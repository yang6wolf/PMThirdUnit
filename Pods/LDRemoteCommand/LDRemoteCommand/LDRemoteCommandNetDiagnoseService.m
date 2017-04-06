//
//  LDRemoteCommandNetDiagnoseService.m
//  NeteaseLottery
//
//  Created by david on 16/4/21.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "LDRemoteCommandNetDiagnoseService.h"
#import "LDNetDiagnoService.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "LDRemoteCommandDefine.h"
#import "LDRemoteCommandResultHandler.h"
#import "LDRemoteCommandConfig.h"

#define NETWORK_RESULT_UNKNOWN @"unknown"

@interface LDRemoteCommandNetDiagnoseService ()<LDNetDiagnoServiceDelegate>

@property (nonatomic, assign) BOOL diagnosing;
@property (nonatomic, strong) NSMutableArray *domains;
@property (nonatomic, strong) LDNetDiagnoService *service;
@property (nonatomic, strong) LDRemoteCommandResultHandler *handler;

@end

@implementation LDRemoteCommandNetDiagnoseService

+ (instancetype)sharedInstance {
    static LDRemoteCommandNetDiagnoseService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LDRemoteCommandNetDiagnoseService alloc] init];
    });
    return instance;
}

#pragma mark - Public Methods
- (void)setDiagnoseDomains:(NSArray<NSString *> *)urlList
{
    if (self.diagnosing) {
        return;
    }
    self.domains = [urlList mutableCopy];
}

- (void)start
{
    if (self.service || self.diagnosing) {
        return;
    }
    
    if (self.domains.count == 0) {
        return;
    }
    
    self.diagnosing = YES;
    
    [self startDiagnoseDomain:self.domains[0]];
}

#pragma mark - Private Methods

- (NSString *)carrierName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    if (carrier && carrier.carrierName) {
        return carrier.carrierName;
    } else {
        return NETWORK_RESULT_UNKNOWN;
    }
}

- (NSString *)mobileCountryCode
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    if (carrier && carrier.mobileCountryCode) {
        return carrier.mobileCountryCode;
    } else {
        return NETWORK_RESULT_UNKNOWN;
    }
}

- (NSString *)mobileNetworkCode
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    if (carrier && carrier.mobileNetworkCode) {
        return carrier.mobileNetworkCode;
    } else {
        return NETWORK_RESULT_UNKNOWN;
    }
}

- (void)startDiagnoseDomain:(NSString*)domain
{
    self.handler = [[LDRemoteCommandResultHandler alloc] init];
    
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
    
    self.service.delegate = nil;
    self.service = nil;
    
    NSString *userId = [LDRemoteCommandConfig sharedConfig].accountId ?: @"";
    self.service = [[LDNetDiagnoService alloc] initWithAppCode:[LDRemoteCommandConfig sharedConfig].productId
                                                       appName:appName
                                                appVersion:[LDRemoteCommandConfig sharedConfig].version
                                                    userID:userId
                                                  deviceID:[LDRemoteCommandConfig sharedConfig].deviceId
                                                   dormain:domain
                                               carrierName:self.carrierName
                                            ISOCountryCode:nil
                                         MobileCountryCode:self.mobileCountryCode
                                             MobileNetCode:self.mobileNetworkCode];
    
    self.service.delegate = self;
    [self.service startNetDiagnosis];
}

- (void)completeDiagnose
{
    self.diagnosing = NO;
    self.service.delegate = nil;
    self.service = nil;
    self.handler = nil;
    self.domains = nil;
}

-(void)netDiagnosisDidStarted
{
    
}

-(void)netDiagnosisStepInfo:(NSString *)stepInfo
{
    
}


-(void)netDiagnosisDidEnd:(NSString *)allLogInfo
{
    //注:此网络诊断回调方法在子线程中
    if (!allLogInfo) {
        allLogInfo = @"";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(&*self) weakself = self;
        [self.handler uploadExecuteResultToFile:netDiagnoseFilePath content:allLogInfo completed:^(BOOL result, NSDictionary *response, NSError *error) {
            __strong typeof(&*weakself) strongself = weakself;
            if (result) {
                [strongself.domains removeObjectAtIndex:0];
                if (strongself.domains.count > 0) {
                    [strongself startDiagnoseDomain:strongself.domains[0]];
                } else {
                    [strongself completeDiagnose];
                }
            } else {
                [strongself completeDiagnose];
            }
        }];
    });
}

@end
