//
//  NLDCheckAppInstall.m
//  Pods
//
//  Created by 高振伟 on 16/7/1.
//  Copyright © 2016年 Zhenwei Gao. All rights reserved.
//

#import "NLDCheckAppInstall.h"
#import "NSNotificationCenter+NLDEventCollection.h"

NLDNotificationNameDefine(NLDNotificationAppInstallList)

@implementation NLDCheckAppInstall

+ (void)startCheckAppInstallWithList:(NSArray<NSString *> *)appList
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:appList.count];
    UIApplication *application = [UIApplication sharedApplication];
    for (NSString *app in appList) {
        NSURL *urlScheme = [NSURL URLWithString:[app stringByAppendingString:@"://"]];
        if ([application canOpenURL:urlScheme]) {
            [dic setValue:@"1" forKey:app];
        } else {
            [dic setValue:@"0" forKey:app];
        }
    }
    [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationAppInstallList object:nil userInfo:dic.copy];
}

@end
