//
//  LDRemoteCommandNetDiagnoseService.h
//  NeteaseLottery
//
//  Created by david on 16/4/21.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDRemoteCommandNetDiagnoseService : NSObject

+ (instancetype)sharedInstance;

- (void)setDiagnoseDomains:(NSArray<NSString *> *)urlList;

- (void)start;

@end
