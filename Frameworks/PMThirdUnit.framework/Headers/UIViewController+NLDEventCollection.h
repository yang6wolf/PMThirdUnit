//
//  UIViewController+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 由UIViewController发出，UserInfo包含"controller":UIViewController,"addition":NSDictionary
extern NSString * const NLDNotificationNewController;

/// 由UIViewController发出，UserInfo包含"controller":UIViewController,"addition":NSDictionary
extern NSString * const NLDNotificationShowController;

/// 由UIViewController发出，对应 viewDidAppear: 方法，UserInfo包含"controller":UIViewController,"addition":NSDictionary
extern NSString * const NLDNotificationDidShowController;

/// 由UIViewController发出，UserInfo包含"controller":UIViewController,"addition":NSDictionary
extern NSString * const NLDNotificationHideController;

/// 由[UIViewController class]发出，UserInfo包含"controllerClass":NSString,"addition":NSDictionary
extern NSString * const NLDNotificationDestoryController;

/// 由UIViewController发出，UserInfo包含"controller":UIViewController,"presentController":UIViewController,"addition":NSDictionary
extern NSString * const NLDNotificationPresentController;

/// 由UIViewController发出，UserInfo包含"controller":UIViewController,"dismissController":UIViewController,"addition":NSDictionary
extern NSString * const NLDNotificationDismissController;


@interface UIViewController (NLDEventCollection)

@end
