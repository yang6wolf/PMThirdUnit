//
//  UINavigationController+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 由NavigationController发出，UserInfo包含"navigationController":UINavigationController,"controller":UIViewController,"addition":NSDictionary
extern NSString * const NLDNotificationPushController;

/// 由NavigationController发出，UserInfo包含"navigationController":UINavigationController,"controller":UIViewController,"addition":NSDictionary
extern NSString * const NLDNotificationPopController;

/// 由NavigationController发出，UserInfo包含"navigationController":UINavigationController,"controllers":NSArray<__kindof UIViewController *>
extern NSString * const NLDNotificationPopToController;

/// 由NavigationController发出，UserInfo包含"navigationController":UINavigationController,"controllers":NSArray<__kindof UIViewController *>
extern NSString * const NLDNotificationPopToRoot;


@interface UINavigationController (NLDEventCollection)

@end
