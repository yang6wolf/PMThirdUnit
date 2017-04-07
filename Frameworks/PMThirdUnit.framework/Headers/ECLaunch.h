//
//  ECLaunch.h
//  Pods
//
//  Created by Hima on 11/24/15.
//
//

#import <UIKit/UIKit.h>

#import "UIWindow+ECLaunch.h"

typedef NS_ENUM(NSInteger, ECLaunchStyle) {
    ECLaunchStyleStandard,
    ECLaunchStyleNestedPresent,
    ECLaunchStyleForcePresent,
};

typedef UINavigationController *(^ECLNavigationControllerCreateBlock)();
typedef UIViewController *(^ECLViewControllerConfigBlock)(id viewController);
typedef BOOL (^ECLEqualBlock)(id viewController);

@interface ECLaunch : NSObject

@property (nonatomic,weak) UIWindow *window;
@property (nonatomic,copy) ECLNavigationControllerCreateBlock navigationControllerCreateBlock;

+ (instancetype)defaultLauncher;

+ (BOOL)launchViewController:(UIViewController *)viewController;

+ (BOOL)launchViewController:(UIViewController *)viewController style:(ECLaunchStyle)style;

+ (BOOL)launchSingleTopViewControllerWithStyle:(ECLaunchStyle)style
                                    equalBlock:(ECLEqualBlock)equalBlock
                                   configBlock:(ECLViewControllerConfigBlock)configBlock;

+ (BOOL)launchSingleTaskViewControllerWithStyle:(ECLaunchStyle)style
                                     equalBlock:(ECLEqualBlock)equalBlock
                                    configBlock:(ECLViewControllerConfigBlock)configBlock;

+ (BOOL)launchSingleInstanceViewController:(UIViewController *)sharedInstance style:(ECLaunchStyle)style;


- (BOOL)launchViewController:(UIViewController *)viewController;

- (BOOL)launchViewController:(UIViewController *)viewController style:(ECLaunchStyle)style;

- (BOOL)launchSingleTopViewControllerWithStyle:(ECLaunchStyle)style
                                    equalBlock:(ECLEqualBlock)equalBlock
                                   configBlock:(ECLViewControllerConfigBlock)configBlock;

- (BOOL)launchSingleTaskViewControllerWithStyle:(ECLaunchStyle)style
                                     equalBlock:(ECLEqualBlock)equalBlock
                                    configBlock:(ECLViewControllerConfigBlock)configBlock;

- (BOOL)launchSingleInstanceViewController:(UIViewController *)sharedInstance style:(ECLaunchStyle)style;

@end
