//
//  UIViewController+ECLaunch.m
//  Pods
//
//  Created by Hima on 11/26/15.
//
//

#import "UIViewController+ECLaunch.h"

@implementation UIViewController (ECLaunch)

- (UIViewController *)ecl_frontViewController
{
    UIViewController *frontViewController = nil;
    
    if (self.presentedViewController) {
        frontViewController = self.presentedViewController;
    } else if ([self isKindOfClass:[UITabBarController class]]) {
        frontViewController = [(UITabBarController *)self selectedViewController];
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        frontViewController = [(UINavigationController *)self topViewController];
    }
    
    return frontViewController;
}

- (UIViewController *)ecl_farthestAncestorViewController
{
    UIViewController *farthestAncestor = self.parentViewController;
    while (farthestAncestor.parentViewController) {
        farthestAncestor = farthestAncestor.parentViewController;
    }
    return farthestAncestor;
}

- (void)ecl_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    UIViewController *farthestAncestor = [self ecl_farthestAncestorViewController];
    if (farthestAncestor.presentedViewController) {
        [farthestAncestor dismissViewControllerAnimated:flag completion:^{
            if (completion) {
                completion();
            }
        }];
    } else {
        if (self.presentedViewController) {
            [self dismissViewControllerAnimated:flag completion:^{
                if (completion) {
                    completion();
                }
            }];
        } else {
            if (completion) {
                completion();
            }
        }
    }
}

- (void)ecl_makeVisibleInTabBarController
{
    UIViewController *viewController = self;
    while (viewController) {
        UITabBarController *tabBarController = viewController.tabBarController;
        if (tabBarController) {
            NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
            if (index >= 0 && index < tabBarController.viewControllers.count) {
                tabBarController.selectedIndex = index;
            }
        }
        viewController = viewController.parentViewController;
    }
}

- (void)ecl_makeVisibleInNavigationController
{
    UIViewController *viewController = self;
    while (viewController) {
        UINavigationController *navigationController = viewController.navigationController;
        if (navigationController) {
            NSInteger index = [navigationController.viewControllers indexOfObject:viewController];
            if (index >= 0 && index < navigationController.viewControllers.count) {
                [navigationController popToViewController:viewController animated:YES];
            }
        }
        viewController = viewController.parentViewController;
    }
}

- (void)ecl_makeVisibleAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self ecl_dismissViewControllerAnimated:flag completion:^{
        [self ecl_makeVisibleInTabBarController];
        [self ecl_makeVisibleInNavigationController];
        
        if (completion) {
            completion();
        }
    }];
}

@end
