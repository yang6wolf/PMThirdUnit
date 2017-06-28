//
//  UIViewController+NLDInternalMethod.h
//  LDEventCollection
//
//  Created by 高振伟 on 16/11/23.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * currentShowingPage;   // 记录最后一个展示的页面名
extern NSString * currentClickedPage;   // 记录最后一个发生点击事件的页面名
extern NSString * currentActivePage;    // 记录最后一个发生show或点击事件的页面名

@interface UIViewController (NLDInternalMethod)

+ (UIViewController *)currentViewController;
+ (UIViewController *)currentVCOfIncludingChild:(BOOL)isChildInclude;
+ (UIViewController *)currentViewControllerForWindow:(UIWindow *)window;


/**
 *  截取指定页面的截图
 */
- (UIImage *)currentPageScreenShot;

/** 
 *  截取指定window的屏幕
 *  @param  window  指定的window，如果为nil，则默认使用 appdelgate.window
 */
+ (UIImage *)screenShotForWindow:(nullable UIWindow *)window;


- (NSString *)controllerName;
- (nullable NSString *)RN_pageName;


/**
 *  根据点击事件或PageShow事件进行更新变量值
 */
+ (void)updateCurrentPageWithEvent:(NSString *)eventName controller:(UIViewController *)viewController pageName:(NSString *)pageName;

/**
 *  获取弹窗点击应该归属的页面名
 */
+ (NSString *)controllerNameForAlertView;

/**
 *  获取导航点击应该归属的页面名
 */
+ (NSString *)controllerNameForNavigation;

/**
 *  判断当前controller是否是childViewController
 */
- (BOOL)isChildViewController;

/**
 *  查找当前最近的页面名
 */
- (UIViewController *)nearestViewController;

@end
NS_ASSUME_NONNULL_END
