//
//  UIScrollView+NLDEventCollection.h
//  LDEventCollection
//
//  Created by SongLi on 5/6/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 由scrollView对象发出，UserInfo包含"scrollView":UIScrollView,"velocity":NSValue(CGPoint)
extern NSString * const NLDNotificationScrollViewWillEndDragging;

/// 由scrollView对象发出，UserInfo包含"scrollView":UIScrollView,"view":UIView,"scale":NSNumber(CGFloat)
extern NSString * const NLDNotificationScrollViewDidEndZooming;

/// 由scrollView对象发出，UserInfo包含"scrollView":UIScrollView
extern NSString * const NLDNotificationScrollViewDidScrollToTop;

///
extern NSString * const NLDNotificationScrollViewDidStop;


@interface UIScrollView (NLDEventCollection)

@end
