//
//  UIWindow+ECLaunch.m
//  Pods
//
//  Created by Hima on 11/26/15.
//
//

#import "UIWindow+ECLaunch.h"
#import "UIViewController+ECLaunch.h"

@implementation UIWindow (ECLaunch)

- (UIViewController *)ecl_visibleViewController
{
    UIViewController *visibleViewController = self.rootViewController;
    UIViewController *frontViewController = self.rootViewController;
    
    while (frontViewController) {
        visibleViewController = frontViewController;
        frontViewController = [frontViewController ecl_frontViewController];
    }
    
    return visibleViewController;
}

@end
