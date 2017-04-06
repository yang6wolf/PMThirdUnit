//
//  UIViewController+NLDAdditionalInfo.h
//  LDEventCollection
//
//  Created by 高振伟 on 16/11/23.
//  Copyright © 2016 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NLDControllerAdditionalInfoProtocol <NSObject>
@optional

- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForView:(nullable UIView *)view;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForTableView:(nullable UITableView *)view atIndexPath:(nullable NSIndexPath *)indexPath;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForCollectionView:(nullable UICollectionView *)view atIndexPath:(nullable NSIndexPath *)indexPath;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForView:(nullable UIView *)view gesture:(nullable UIGestureRecognizer *)gesture;

- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForPushController:(nullable UIViewController *)controller;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForPopController:(nullable UIViewController *)controller;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForPresentController:(nullable UIViewController *)controller;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForDismissController:(nullable UIViewController *)controller;

- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForNewController;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForShowController;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForHideController;
- (nullable NSDictionary<NSString *, NSString *> *)NLD_addInfoForDestoryController;

@end

@interface UIViewController (NLDAdditionalInfo) <NLDControllerAdditionalInfoProtocol>

/**
 *  用于设置原生页面别名，如果未设置则默认的页面名字是controller的类名
 */
@property (nonatomic, copy, nullable) NSString *pageAlias;

/**
 *  用于设置RN页面别名（通常使用 ModuleName 作为页面别名）
 *  适用范围：进行原生与RN的混合开发时，每个VC实例对应每个RN页面
 */
@property (nonatomic, copy, nullable) NSString *pageAliasInRN;

/**
 *  用于保存RN页面中当前展示的component（通常使用 componentName 作为RN页面别名）
 *  适用范围：进行纯RN的开发时，项目中只有一个VC实例，每个页面对应一个component
 */
@property (nonatomic, copy, nullable) NSString *componentName;

@end
