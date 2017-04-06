//
//  UIView+Positioning.h
//  NeteaseLottery
//
//  Created by wuxu on 16/5/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Positioning)

/**
 *  返回直接管理View的ViewController
 *
 *  @return UIViewController 可能为空
 */
- (nullable UIViewController *)ldp_manageViewController;

/**
 *  返回距离View最近的ViewController
 *
 *  @return UIViewController 可能为空（eg：当View直接被添加在UIWindow时）
 */
- (nullable UIViewController *)ldp_nearViewController;

/**
 *  获取在父View中的位置信息
 *
 *  @return 位置
 */
- (NSUInteger)ldp_indexAtSuperView;

/**
 *  获取在父View中同类子View中的位置信息
 *
 *  @return 位置
 */
- (NSUInteger)ldp_indexAtSuperViewSameSubviews;

/**
 *  获取某种View的子集
 *
 *  @return View子集
 */
- (nullable NSArray *)ldp_subviewsOf:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
