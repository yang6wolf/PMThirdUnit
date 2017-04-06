//
//  UIViewController+NeteaseMA.m
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/13/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import "UIViewController+NeteaseMA.h"
#import <objc/runtime.h>
#import "Aspects.h"

#define CHECK_CONTROLLER \
NSString *controllerName = NSStringFromClass([self class]); \
BOOL valid = !(controllerName.length==0||[controllerName hasPrefix:@"UI"]||[controllerName hasPrefix:@"_"]);

@implementation UIViewController (NeteaseMA)

static __weak id<NeteaseMAViewControllerDelegate> delegate;

+ (void)neteasema_startProbe {
    [UIViewController aspect_hookSelector:@selector(loadView) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        UIViewController *instance = [aspectInfo instance];
        [instance neteasema_loadView];
    } error:NULL];
    
    [UIViewController aspect_hookSelector:@selector(viewDidLoad) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        UIViewController *instance = [aspectInfo instance];
        [instance neteasema_viewDidLoad];
    } error:NULL];
    
    [UIViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo,BOOL animated) {
        UIViewController *instance = [aspectInfo instance];
        [instance neteasema_viewWillAppear:animated];
    } error:NULL];
    
    [UIViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo,BOOL animated) {
        UIViewController *instance = [aspectInfo instance];
        [instance neteasema_viewWillDisappear:animated];
    } error:NULL];
    
    
    [UIViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo,BOOL animated) {
        UIViewController *instance = [aspectInfo instance];
        [instance neteasema_viewDidAppear:animated];
    } error:NULL];
    
    NSString *deallocString = @"dealloc";
    [UIViewController aspect_hookSelector:NSSelectorFromString(deallocString) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        UIViewController *instance = [aspectInfo instance];
        [instance neteasema_dealloc];
    } error:NULL];
}

+ (void)neteasema_setDelegate:(id<NeteaseMAViewControllerDelegate>)newValue {
    delegate = newValue;
}

- (void)neteasema_loadView {
    CHECK_CONTROLLER
    if (valid) {
        [delegate viewControllerLoadView:self];
    }
}

- (void)neteasema_viewDidLoad {
    CHECK_CONTROLLER
    if (valid) {
        [delegate viewControllerViewDidLoad:self];
    }
}

- (void)neteasema_viewWillAppear:(BOOL)animated {
    CHECK_CONTROLLER
    if (valid) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [delegate viewControllerWillAppear:self];
                           });
                           
                       });
    }
}

- (void)neteasema_viewWillDisappear:(BOOL)animated {
    CHECK_CONTROLLER
    if (valid) {
        [delegate viewControllerWillDisappear:self];
    }
}


- (void)neteasema_viewDidAppear:(BOOL)animated {
    CHECK_CONTROLLER
    if (valid) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [delegate viewControllerDidAppear:self];
                           });
                           
                       });
    }
}

- (void)neteasema_dealloc {
    CHECK_CONTROLLER
    if (valid) {
        [delegate viewControllerDealloc:self];
    }
}

@end
