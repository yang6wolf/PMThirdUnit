//
//  UIWebView+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/12/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 由webView对象发出，UserInfo包含"webView":UIWebView,"request":NSURLRequest
extern NSString * const NLDNotificationWebWillLoadRequest;

/// 由webView对象发出，UserInfo包含"webView":UIWebView
extern NSString * const NLDNotificationWebStartLoad;

/// 由webView对象发出，UserInfo包含"webView":UIWebView
extern NSString * const NLDNotificationWebFinishLoad;

/// 由webView对象发出，UserInfo包含"webView":UIWebView,"error":NSError
extern NSString * const NLDNotificationWebFailedLoad;


@interface UIWebView (NLDEventCollection)

@end
