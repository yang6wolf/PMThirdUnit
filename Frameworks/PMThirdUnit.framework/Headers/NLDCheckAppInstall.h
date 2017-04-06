//
//  NLDCheckAppInstall.h
//  Pods
//
//  Created by 高振伟 on 16/7/1.
//  Copyright © 2016年 Zhenwei Gao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const NLDNotificationAppInstallList;

@interface NLDCheckAppInstall : NSObject

/**
 *  根据应用列表开始检测这些应用是否已安装
 *
 *  @param appList 应用列表
 */
+ (void)startCheckAppInstallWithList:(NSArray<NSString *> *)appList;

@end

NS_ASSUME_NONNULL_END
