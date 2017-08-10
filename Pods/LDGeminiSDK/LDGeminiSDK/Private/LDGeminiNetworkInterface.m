//
//  LDGeminiNetworkInterface.m
//  Pods
//
//  Created by 金秋实 on 06/02/2017.
//
//

#import "LDGeminiNetworkInterface.h"

@interface LDGeminiNetworkInterface ()

@property (nonatomic, strong) NSString *baseUrlString;

@end

@implementation LDGeminiNetworkInterface

+(instancetype)sharedInstance
{
    static LDGeminiNetworkInterface *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LDGeminiNetworkInterface alloc] init];
    });
    return  instance;
}

+ (void)setBaseUrl:(NSString *)baseUrl
{
    [LDGeminiNetworkInterface sharedInstance].baseUrlString = baseUrl;
}

+ (NSString *)queryUserCaseListUrl
{
    NSString *baseUrlString = [LDGeminiNetworkInterface sharedInstance].baseUrlString;
    return [baseUrlString stringByAppendingString:@"ab/interface/case/queryUserCaseList"];
}

#pragma mark - Getter

- (NSString *)baseUrlString
{
    if (!_baseUrlString) {
        _baseUrlString = @"https://adc.163.com/";
    }
    return _baseUrlString;
}

@end
