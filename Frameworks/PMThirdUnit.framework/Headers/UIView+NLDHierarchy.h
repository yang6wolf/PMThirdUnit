//
//  UIView+NLDHierarchy.h
//  LDEventCollection
//
//  Created by SongLi on 5/18/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (NLDHierarchy)

/**
 *  通过ResponseChain寻找此View所在的ViewController。
 *  如果找不到，返回nil。
 */
- (nullable UIViewController *)NLD_controller;

/**
 *  如果此View处在Controller中，返回Controller到此View的层级关系，
 *  否则，如果此View处在Window中，返回Controller到此View的层级关系，
 *  否则，返回nil。
 *
 *  示例:UIViewController-UIScrollView-UIView-UIButton
 */
- (nullable NSString *)NLD_pathToControllerOrWindow;

- (nullable NSString *)NLD_viewPathInControllerOrWindow;
- (nullable NSString *)NLD_depthPathInControllerOrWindow;

/**
 *  此View相对窗口的绝对位置。
 *  如果此View处在ScrollView中，会加上ScrollView的Offset。
 *  如果此View不处在Window上，返回CGRectZero。
 */
- (CGRect)NLD_absoluteRectToWindow;

@end
