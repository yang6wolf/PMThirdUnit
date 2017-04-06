//
//  AppInfoUtils.m
//  Pods
//
//  Created by 高振伟 on 16/8/10.
//
//

#import "NLDAppInfoUtils.h"
#import "UIDevice+NLDEventCollection.h"

@implementation NLDAppInfoUtils

+ (NSString *)appBundle
{
    static NSString *appBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appBundle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    });
    return appBundle;
}

+ (NSString *)appVersion
{
    static NSString *appVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    });
    return appVersion;
}

+ (NSString *)appBuildVersion
{
    static NSString *appBuildVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    });
    return appBuildVersion;
}

+ (NSString *)idfa
{
    static NSString *idfa;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idfa = [[UIDevice currentDevice] NLD_idfa];
    });
    return idfa;
}

+ (NSString *)systemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

@end
