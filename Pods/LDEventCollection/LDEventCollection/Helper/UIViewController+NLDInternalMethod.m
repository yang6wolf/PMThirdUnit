//
//  UIViewController+NLDInternalMethod.m
//  LDEventCollection
//
//  Created by 高振伟 on 16/11/23.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIViewController+NLDInternalMethod.h"
#import "UIViewController+NLDAdditionalInfo.h"

NSString * currentShowingPage = @"";
NSString * currentClickedPage = @"";
NSString * currentActivePage = @"";

@implementation UIViewController (NLDInternalMethod)

+ (UIViewController *)currentViewController
{
    return [self currentViewControllerForWindow:[UIApplication sharedApplication].delegate.window];
}

+ (UIViewController *)currentViewControllerForWindow:(UIWindow *)window
{
    return [self currentViewControllerForWindow:window includeChild:YES];
}

+ (UIViewController *)currentVCOfIncludingChild:(BOOL)isChildInclude
{
    return [self currentViewControllerForWindow:[UIApplication sharedApplication].delegate.window includeChild:isChildInclude];
}

+ (UIViewController *)currentViewControllerForWindow:(UIWindow *)window includeChild:(BOOL)isChildInclude
{
    UIViewController *rootVC = window.rootViewController;
    if (!rootVC) {
        rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return [self currentViewControllerRecursivityWithRootViewController:rootVC includeChild:isChildInclude];
}

+ (UIViewController *)currentViewControllerRecursivityWithRootViewController:(UIViewController *)rootViewController
                                                                includeChild:(BOOL)isChildInclude
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self currentViewControllerRecursivityWithRootViewController:tabBarController.selectedViewController includeChild:isChildInclude];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self currentViewControllerRecursivityWithRootViewController:navigationController.topViewController includeChild:isChildInclude];
    } else if (rootViewController.presentedViewController) {
        UIViewController *prensentedViewController = rootViewController.presentedViewController;
        return [self currentViewControllerRecursivityWithRootViewController:prensentedViewController includeChild:isChildInclude];
    } else {
        if (isChildInclude) {
            //如果只有一个子VC，则直接返回此VC
            if (rootViewController.childViewControllers && rootViewController.childViewControllers.count == 1) {
                UIViewController *childViewController = [rootViewController.childViewControllers lastObject];
                return [self currentViewControllerRecursivityWithRootViewController:childViewController includeChild:isChildInclude];
            } else {
                return rootViewController;
            }
        } else {
            return rootViewController;
        }
    }
}

+ (UIImage *)currentPageScreenShot
{
    // 截取当前页面
    //    UIGraphicsBeginImageContext(self.view.frame.size);
    //    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //
    //    return viewImage;
    
    // 截取整个屏幕
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    return [self screenShotForWindow:window];
}

+ (UIImage *)screenShotForWindow:(UIWindow *)window {
    if (![window isKindOfClass:[UIWindow class]]) {
        return nil;
    }
    
    UIGraphicsBeginImageContext(window.frame.size);
//    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    [window drawViewHierarchyInRect:window.frame afterScreenUpdates:NO];
    UIImage *screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShotImage;
}

- (NSString *)controllerName
{
    if (self.pageAliasInRN) {
        return self.pageAliasInRN;
    }
    
    NSString *pageName;
    if (self.pageAlias) {
        pageName = [NSString stringWithFormat:@"%@#%@", NSStringFromClass([self class]), self.pageAlias];
    } else {
        pageName = NSStringFromClass([self class]);
    }
    
    return pageName;
}

- (nullable NSString *)RN_pageName
{
    return self.componentName ?: self.controllerName;
    
//    NSString *pageName = [self controllerName];
//    if (self.componentName) {
//        pageName = [NSString stringWithFormat:@"%@-%@", pageName, self.componentName];
//    }
//    return pageName;
}

+ (void)updateCurrentPageWithEvent:(NSString *)eventName pageName:(NSString *)pageName
{
    if ([eventName isEqualToString:@"NLDNotificationShowController"]) {
        // TODO: 后续需要继续补充此列表
        NSArray *blackList = @[@"UIAlertController", @"UIInputWindowController", @"UICompatibilityInputViewController"];
        if (![blackList containsObject:pageName]) {
            currentShowingPage = pageName;
            currentActivePage = pageName;
        }
    } else if ([eventName isEqualToString:@"NLDNotificationTapGesture"] || [eventName isEqualToString:@"NLDNotificationButtonClick"]) {
        currentClickedPage = pageName;
        currentActivePage = pageName;
    }
}

+ (NSString *)controllerNameForAlertView
{
    UIViewController *currentVC = [self currentViewController];
    if (currentVC.childViewControllers && currentVC.childViewControllers.count > 1) {
        return currentActivePage;
//        return currentClickedPage;
    }
    return [currentVC controllerName];
}

+ (NSString *)controllerNameForNavigation
{
    UIViewController *currentVC = [self currentViewController];
    if (currentVC.childViewControllers && currentVC.childViewControllers.count > 1) {
        return currentActivePage;
//        return currentShowingPage;
    }
    return [currentVC controllerName];
}

@end
