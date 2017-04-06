//
//  UIAlertAction+NLDEventCollection.m
//  LDEventCollection
//
//  Created by 高振伟 on 16/12/6.
//  Copyright © 2016 netease. All rights reserved.
//

#ifdef __IPHONE_8_0

#import "UIAlertAction+NLDEventCollection.h"
#import "NSObject+MethodSwizzle.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import "UIViewController+NLDInternalMethod.h"
#import "NSString+NLDAddition.h"
#import "NLDMacroDef.h"
#import "NLDEventCollectionManager.h"

@implementation UIAlertAction (NLDEventCollection)

+ (void)NLD_swizz
{
    [self NLD_swizzStaticSel:@selector(actionWithTitle:style:handler:) newSel:@selector(NLD_hookActionWithTitle:style:handler:)];
}

+ (instancetype)NLD_hookActionWithTitle:(nullable NSString *)title style:(UIAlertActionStyle)style handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    return [self NLD_hookActionWithTitle:title style:style handler:^(UIAlertAction *action) {
        
        LDECLog(@"监测到系统调用的方法：actionWithTitle:style:handler:");
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
        NSString *timeStamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
        userInfo[@"timeStamp"] = timeStamp;
        NSString *clsName = NSStringFromClass([self class]);
        userInfo[@"view"] = [clsName NLD_removeSwiftModule];
        
        // 点击事件的title，由弹窗的标题、按钮的文字使用连接符（&）组成
        NSString *alertTitle = title;
        UIAlertController *alertController = [action valueForKey:@"__alertController"];
        if (alertController.title && alertController.title.length > 0) {
            alertTitle = [NSString stringWithFormat:@"%@&%@", alertController.title, alertTitle];
        } else if (alertController.message && alertController.message.length > 0) {
            NSString *subMsg = alertController.message;
            if (subMsg.length > 5) {
                subMsg = [subMsg substringToIndex:5];
            }
            alertTitle = [NSString stringWithFormat:@"%@&%@", subMsg, alertTitle];
        }
        userInfo[@"viewTitle"] = alertTitle;
        
        NSString *pageName = [UIViewController controllerNameForAlertView];
        userInfo[@"controller"] = pageName;
        NSString *viewPath = [NSString stringWithFormat:@"UIAlertController-%@&0-0", clsName];
        userInfo[@"viewPath"] = viewPath;
        userInfo[@"viewDepthPath"] = @"0-0";
        NSString *viewIdString = [NSString stringWithFormat:@"%@&%@&0-0", pageName, viewPath];
        userInfo[@"viewId"] = [viewIdString NLD_md5String];
        
        NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];
        
        if (collectManager.infoBlock) {
//            collectManager.infoBlock(userInfo, action);
        }
        else {
            if (collectManager.logInfoBlock) {
                userInfo[@"eventName"] = @"ButtonClick";
                collectManager.logInfoBlock(userInfo);
            }
            
            [NSNotificationCenter NLD_postEventCollectionNotificationName:@"NLDNotificationButtonClick" object:nil userInfo:userInfo.copy];
        }

        if (handler && !collectManager.infoBlock) {
            handler(action);
        }
    }];
}

@end

#endif
