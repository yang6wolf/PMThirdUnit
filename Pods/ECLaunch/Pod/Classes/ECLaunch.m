//
//  ECLaunch.m
//  Pods
//
//  Created by Hima on 11/24/15.
//
//

#import "ECLaunch.h"
#import "ECNavigationController.h"
#import "UIWindow+ECLaunch.h"
#import "UIViewController+ECLaunch.h"

@implementation ECLaunch

+ (BOOL)standardLaunchViewController:(UIViewController *)viewController
                            inWindow:(UIWindow *)window
                   navigationCreator:(ECLNavigationControllerCreateBlock)navigationControllerCreateBlock
{
    UIViewController *visibleViewController = [window ecl_visibleViewController];
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [visibleViewController presentViewController:viewController animated:YES completion:nil];
    } else {
        if (visibleViewController.navigationController) {
            [visibleViewController.navigationController pushViewController:viewController animated:YES];
        } else if ([visibleViewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)visibleViewController pushViewController:viewController animated:YES];
        } else {
            UINavigationController *navigationController = navigationControllerCreateBlock();
            navigationController.viewControllers = @[viewController];
            [visibleViewController presentViewController:navigationController animated:YES completion:nil];
        }
    }
    
    return YES;
}

+ (BOOL)nestedPresentViewController:(UIViewController *)viewController
                           inWindow:(UIWindow *)window
                  navigationCreator:(ECLNavigationControllerCreateBlock)navigationControllerCreateBlock
{
    UIViewController *visibleViewController = [window ecl_visibleViewController];
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [visibleViewController presentViewController:viewController animated:YES completion:nil];
    } else {
        UINavigationController *navigationController = navigationControllerCreateBlock();
        navigationController.viewControllers = @[viewController];
        [visibleViewController presentViewController:navigationController animated:YES completion:nil];
    }
    
    return YES;
}

+ (BOOL)presentViewController:(UIViewController *)viewController
                     inWindow:(UIWindow *)window
{
    UIViewController *visibleViewController = [window ecl_visibleViewController];
    [visibleViewController presentViewController:viewController animated:YES completion:nil];
    
    return YES;
}

+ (BOOL)launchViewController:(UIViewController *)viewController
                    inWindow:(UIWindow *)window
                       style:(ECLaunchStyle)style
           navigationCreator:(ECLNavigationControllerCreateBlock)navigationControllerCreateBlock
{
    NSInteger status = NO;
    switch (style) {
        case ECLaunchStyleStandard:
        {
            status = [self standardLaunchViewController:viewController
                                               inWindow:window
                                      navigationCreator:navigationControllerCreateBlock];
        }
            break;
        case ECLaunchStyleNestedPresent:
        {
            status =  [self nestedPresentViewController:viewController
                                               inWindow:window
                                      navigationCreator:navigationControllerCreateBlock];
        }
            break;
        case ECLaunchStyleForcePresent:
        {
            status = [self presentViewController:viewController
                                        inWindow:window];
        }
            break;
        default:
            status =  [self standardLaunchViewController:viewController
                                                inWindow:window
                                       navigationCreator:navigationControllerCreateBlock];
            break;
    }
    
    return status;
}

+ (instancetype)defaultLauncher
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

+ (BOOL)launchViewController:(UIViewController *)viewController
{
    return [[self defaultLauncher] launchViewController:viewController];
}

+ (BOOL)launchViewController:(UIViewController *)viewController
                       style:(ECLaunchStyle)style
{
    return [[self defaultLauncher] launchViewController:viewController style:style];
}

+ (BOOL)launchSingleTopViewControllerWithStyle:(ECLaunchStyle)style
                                    equalBlock:(ECLEqualBlock)equalBlock
                                   configBlock:(ECLViewControllerConfigBlock)configBlock
{
    return [[self defaultLauncher] launchSingleTopViewControllerWithStyle:style equalBlock:equalBlock configBlock:configBlock];
}

+ (BOOL)launchSingleTaskViewControllerWithStyle:(ECLaunchStyle)style
                                     equalBlock:(ECLEqualBlock)equalBlock
                                    configBlock:(ECLViewControllerConfigBlock)configBlock
{
    return [[self defaultLauncher] launchSingleTaskViewControllerWithStyle:style equalBlock:equalBlock configBlock:configBlock];
}

+ (BOOL)launchSingleInstanceViewController:(UIViewController *)sharedInstance style:(ECLaunchStyle)style
{
    return [[self defaultLauncher] launchSingleInstanceViewController:sharedInstance style:style];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _navigationControllerCreateBlock = ^(){
            return [ECNavigationController new];
        };
    }
    return self;
}

- (BOOL)launchViewController:(UIViewController *)viewController
{
    return [self launchViewController:viewController
                                style:ECLaunchStyleStandard];
}

- (BOOL)launchViewController:(UIViewController *)viewController
                       style:(ECLaunchStyle)style
{
    return [self.class launchViewController:viewController
                                   inWindow:self.window
                                      style:style
                          navigationCreator:self.navigationControllerCreateBlock];
}



- (BOOL)launchSingleTopViewControllerWithStyle:(ECLaunchStyle)style
                                    equalBlock:(ECLEqualBlock)equalBlock
                                   configBlock:(ECLViewControllerConfigBlock)configBlock
{
    NSInteger status = NO;
    UIViewController *visibleViewController = [self.window ecl_visibleViewController];
    
    if (equalBlock(visibleViewController)) {
        if (configBlock) {
            configBlock(visibleViewController);
        }
        status = YES;
    } else {
        if (configBlock) {
            status = [self launchViewController:configBlock(nil) style:style];
        }
    }
    return status;
}

- (BOOL)launchSingleTaskViewControllerWithStyle:(ECLaunchStyle)style
                                     equalBlock:(ECLEqualBlock)equalBlock
                                    configBlock:(ECLViewControllerConfigBlock)configBlock
{
    if (!equalBlock) {
        return NO;
    }
    
    NSInteger status = NO;
    
    UIViewController *visibleViewController = [self.window ecl_visibleViewController];
    if (equalBlock(visibleViewController)) {
        status = YES;
        if (configBlock) {
            configBlock(visibleViewController);
        }
    } else {
        NSArray *viewControllerArray = visibleViewController.navigationController.viewControllers;
        UIViewController *targetViewControler = nil;
        
        for (UIViewController *viewController in viewControllerArray) {
            if (equalBlock(viewController)) {
                targetViewControler = viewController;
                break;
            }
        }
        
        if (targetViewControler) {
            [targetViewControler ecl_makeVisibleAnimated:YES completion:nil];
            if (configBlock) {
                configBlock(targetViewControler);
            }
            status = YES;
        } else {
            if (configBlock) {
                status = [self launchViewController:configBlock(nil) style:style];
            }
        }
    }
    
    return status;
}

- (BOOL)launchSingleInstanceViewController:(UIViewController *)sharedInstance style:(ECLaunchStyle)style
{
    UIViewController *visibleViewController = [self.window ecl_visibleViewController];
    
    if (visibleViewController == sharedInstance) {
        return YES;
    } else if (sharedInstance.parentViewController || sharedInstance.presentingViewController) {
        [sharedInstance ecl_makeVisibleAnimated:YES completion:nil];
        return YES;
    } else {
        return [self launchViewController:sharedInstance style:style];
    }
}

@end
