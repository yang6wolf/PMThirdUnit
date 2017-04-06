//
//  NetEaseMADiagnoseModel.m
//  MobileAnalysis
//
//  Created by 高振伟 on 16/9/5.
//  
//

#import "NetEaseMADiagnoseModel.h"

@implementation NetEaseMADiagnoseModel

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self parseDictionary:dic];
    }
    
    return self;
}

- (void)parseDictionary:(NSDictionary *)dic {
    if (!dic) {
        return;
    }
    // 默认tag为all
    self.tag = @"all";
    // 默认开启时间是一天
    self.expiredDate = [NSDate dateWithTimeIntervalSinceNow:24 * 60 * 60];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj == [NSNull null]) {
            obj = nil;
        }
        
        if ([key isEqualToString:@"tag"]) {
            self.tag = obj;
        } else if ([key isEqualToString:@"time"]) {  // 后台配置的时间单位是分钟
            double time = [obj doubleValue] * 60;
            self.expiredDate = [NSDate dateWithTimeIntervalSinceNow:time];
        }
    }];
}

@end
