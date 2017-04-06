//
//  LDSPErrorUploader.h
//  Pods
//
//  Created by liubing on 9/10/15.
//
//

#import <Foundation/Foundation.h>

@interface LDSPErrorUploader : NSObject

+ (instancetype)sharedInstance;
- (void)setErrorLogHost:(NSString *)errorLogHost;   // 设置错误日志上传Host，传nil或者不掉用该方法，为默认hosthttp://mt.analytics.163.com
- (void)uploadSocketErrorIfNeed:(NSError *)error;

@end
