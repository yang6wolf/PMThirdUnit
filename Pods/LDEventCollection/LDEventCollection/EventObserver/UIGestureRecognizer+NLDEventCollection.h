//
//  UIGestureRecognizer+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 由作用View发出，UserInfo包含"view":UIView,"gesture":UITapGestureRecognizer,"target":id,"action":NSString,"addition":NSDictionary
extern NSString * const NLDNotificationTapGesture;

/// 由作用View发出，UserInfo包含"view":UIView,"gesture":NLDNotificationLongPressGesture,"target":id,"action":NSString,"addition":NSDictionary
extern NSString * const NLDNotificationLongPressGesture;

/// 由作用View发出，UserInfo包含"view":UIView,"gesture":NLDNotificationPanGesture,"target":id,"action":NSString,"addition":NSDictionary
extern NSString * const NLDNotificationPanGesture;

/// 由作用View发出，UserInfo包含"view":UIView,"gesture":NLDNotificationSwipeGesture,"target":id,"action":NSString,"addition":NSDictionary
extern NSString * const NLDNotificationSwipeGesture;


@interface UIGestureRecognizer (NLDEventCollection)

@end
