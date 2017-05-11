//
//  NetEaseMADNSManager.h
//  MobileAnalysis
//
//  Created by wangjiale on 2017/4/5.
//  Copyright © 2017年 zhang jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetEaseMADNSTracker : NSObject

/*!
 * 通过域名获取服务器DNS地址
 */
+ (NSArray *)getDNSsWithDormain:(NSString *)hostName;

@end
