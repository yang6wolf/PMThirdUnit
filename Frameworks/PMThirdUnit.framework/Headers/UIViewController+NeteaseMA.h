//
//  UIViewController+NeteaseMA.h
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/13/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NeteaseMAViewControllerDelegate;

@interface UIViewController (NeteaseMA)
+ (void)neteasema_startProbe;
+ (void)neteasema_setDelegate:(id<NeteaseMAViewControllerDelegate>)newValue;
@end

@protocol NeteaseMAViewControllerDelegate <NSObject>
- (void)viewControllerLoadView:(UIViewController*)controller;
- (void)viewControllerViewDidLoad:(UIViewController *)controller;
- (void)viewControllerWillAppear:(UIViewController *)controller;
- (void)viewControllerWillDisappear:(UIViewController *)controller;
- (void)viewControllerDidAppear:(UIViewController *)controller;
- (void)viewControllerDealloc:(UIViewController *)controller;
@end