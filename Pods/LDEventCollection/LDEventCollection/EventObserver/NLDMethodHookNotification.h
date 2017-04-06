//
//  NLDMethodHookNotification.h
//  LDEventCollection
//
//  Created by 高振伟 on 17/3/24.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

// UIViewController
// 通过userInfo传递当前的controller名称，例如:{@"pageName": @"UIViewController"}

extern NSString * const kNLDViewDidLoadNotification;       // viewDidLoad
extern NSString * const kNLDViewWillAppearNotification;    // viewWillAppear:
extern NSString * const kNLDViewDidAppearNotification;     // viewDidAppear:
extern NSString * const kNLDViewWillDisappearNotification; // viewWillDisappear:
extern NSString * const kNLDDeallocNotification;           // dealloc

