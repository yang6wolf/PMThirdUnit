//
//  UIActionSheet+NLDEventCollection.m
//  LDEventCollection
//
//  Created by 高振伟 on 16/12/1.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIActionSheet+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NSObject+MethodSwizzle.h"
#import "NLDEventCollectionManager.h"

@implementation UIActionSheet (NLDEventCollection)

+ (void)NLD_swizz
{
    SEL sel = @selector(setDelegate:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <UIActionSheetDelegate> delegate) {
        SEL subSel = @selector(actionSheet:clickedButtonAtIndex:);
        SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        __unused BOOL rest = [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UIActionSheetDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIActionSheet *actionSheet, NSInteger buttonIndex) {
            
            NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:actionSheet];
            
            NSString *alertTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
            if (actionSheet.title && actionSheet.title.length > 0) {
                alertTitle = [NSString stringWithFormat:@"%@&%@", actionSheet.title, alertTitle];
            }
            userInfo[@"viewTitle"] = alertTitle;
            
            if (collectManager.infoBlock) {
                collectManager.infoBlock(userInfo, actionSheet);
            }
            else {
                if (collectManager.logInfoBlock) {
                    userInfo[@"eventName"] = @"ButtonClick";
                    collectManager.logInfoBlock(userInfo);
                }
                [NSNotificationCenter NLD_postEventCollectionNotificationName:@"NLDNotificationButtonClick" object:nil userInfo:userInfo.copy];
            }

            if ([receiver respondsToSelector:subNewSel] && !collectManager.infoBlock) {
                BOOL isMsgForward = [receiver invokeSelector:subNewSel withArguments:@[actionSheet, @(buttonIndex)]];
                if (!isMsgForward) {
                    ((BOOL ( *)(id, SEL, id, NSInteger))objc_msgSend)(receiver, subNewSel, actionSheet, buttonIndex);
                }
            }
            
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
        }];
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[delegate ?: [NSNull null]]]) {
                ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, delegate);
            }
        }
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
}

@end
