//
//  UIViewController+ECLaunch.h
//  Pods
//
//  Created by Hima on 11/26/15.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (ECLaunch)

- (UIViewController *)ecl_frontViewController;
- (UIViewController *)ecl_farthestAncestorViewController;

- (void)ecl_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
- (void)ecl_makeVisibleInTabBarController;
- (void)ecl_makeVisibleInNavigationController;

- (void)ecl_makeVisibleAnimated:(BOOL)flag completion:(void (^)(void))completion;

@end
