//
//  LDGeminiSDK+Helper.m
//  Pods
//
//  Created by wangkaird on 2016/12/29.
//
//

#import "LDGeminiSDK+Helper.h"
#import "LDGeminiHelper.h"
#import "LDGeminiMacro.h"

@implementation LDGeminiSDK (Helper)

+ (id)getFlagWithName:(NSString *)name defaultFlag:(id)defaultFlag {
    NSString *caseId = [LDGeminiHelper caseIdForName:name];
    return caseId ? [LDGeminiSDK getFlag:caseId defaultFlag:defaultFlag] : defaultFlag;
}

+ (void)asyncGetFlagWithName:(NSString *)name defaultFlag:(id)defaultFlag handler:(LDGeminiAsyncGetHandler)handler {
    NSString *caseId = [LDGeminiHelper caseIdForName:name];
    if (caseId) {
        [LDGeminiSDK asyncGetFlag:caseId defaultFlag:defaultFlag handler:handler];
    } else {
        NSString *msg = [NSString stringWithFormat:@"LDGeminiSDK无法识别的name: %@", name];
        NSError *error = [NSError errorWithDomain:LDGeminiSDKDomain
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : msg}];
        handler(defaultFlag, error);
    }
}

+ (id)syncGetFlagWithName:(NSString *)name defaultFlag:(id)defaultFlag timeout:(NSTimeInterval)timeout error:(NSError * _Nullable __autoreleasing *)error {
    NSString *caseId = [LDGeminiHelper caseIdForName:name];
    return caseId ? [LDGeminiSDK syncGetFlag:caseId defaultFlag:defaultFlag timeout:timeout error:error] : defaultFlag;
}

@end
