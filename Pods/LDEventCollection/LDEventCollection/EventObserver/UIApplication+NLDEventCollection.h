//
//  UIApplication+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/5/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 由sender对象发出，UserInfo包含"sender":id,"target":id,"action":NSString(SEL)
extern NSString * const NLDNotificationButtonClick;

/// 由UIApplication发出，UserInfo包含"timeStamp":NSNumber(NSTimeInterval),"url":NSURL,"succeed":NSNumber(BOOL)
extern NSString * const NLDNotificationAppOpenUrl;

/// 由UIApplication发出，UserInfo包含"view":UIView,"event":UIEvent,"touch":UITouch
extern NSString * const NLDNotificationScreenSingleTouch;

extern NSString * const NLDNotificationReceiveRemoteNotification;


@interface UIApplication (NLDEventCollection)

@end
