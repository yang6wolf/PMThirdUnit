//
//  AppInfoUtils.h
//  Pods
//
//  Created by 高振伟 on 16/8/10.
//
//

#import <Foundation/Foundation.h>

@interface NLDAppInfoUtils : NSObject

+ (NSString *)appBundle;
+ (NSString *)appVersion;
+ (NSString *)appBuildVersion;
+ (NSString *)idfa;
+ (NSString *)systemVersion;

@end
