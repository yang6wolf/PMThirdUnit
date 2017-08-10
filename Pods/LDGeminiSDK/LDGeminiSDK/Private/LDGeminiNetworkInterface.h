//
//  LDGeminiNetworkInterface.h
//  Pods
//
//  Created by 金秋实 on 06/02/2017.
//
//

#import <Foundation/Foundation.h>

@interface LDGeminiNetworkInterface : NSObject

+ (void)setBaseUrl:(NSString *)baseUrl;

+ (NSString *)queryUserCaseListUrl;

@end
