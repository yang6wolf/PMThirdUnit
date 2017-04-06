//
//  NLDRNPageManager.m
//  LDEventCollection
//
//  Created by 高振伟 on 16/12/23.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDRNPageManager.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import "NLDRNPageManager.h"
#import "UIViewController+NLDAdditionalInfo.h"
#import "UIViewController+NLDInternalMethod.h"

@implementation NLDRNPageManager

+ (instancetype)defaultManager
{
    static NLDRNPageManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NLDRNPageManager alloc] init];
    });
    return instance;
}

- (void)RN_viewWillAppearWithComponentName:(NSString *)componentName
{
    UIViewController *currentVC = [UIViewController currentVCOfIncludingChild:NO];
    NSString *preComponentName = currentVC.componentName;
    if (preComponentName) {
        if ([preComponentName isEqualToString:componentName]) return;
        
        [self triggerPageEventWithType:RNPageEventHide componentName:preComponentName];
    }
    currentVC.componentName = componentName;
    [self triggerPageEventWithType:RNPageEventShow componentName:componentName];
}

- (void)triggerPageEventWithType:(RNPageEvent)event componentName:(nullable NSString *)componentName
{
    if (!componentName) return;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionary];
//    NSString *pageName = [currentVC controllerName];
//    NSString *rnPageName = [NSString stringWithFormat:@"%@-%@", pageName, componentName];
    [userInfo setValue:componentName forKey:@"controller"];
    
    if (event == RNPageEventShow) {
        [NSNotificationCenter NLD_postEventCollectionNotificationName:@"NLDNotificationShowController" object:nil userInfo:userInfo.copy];
    } else if (event == RNPageEventHide) {
        [NSNotificationCenter NLD_postEventCollectionNotificationName:@"NLDNotificationHideController" object:nil userInfo:userInfo.copy];
    }
}

@end
