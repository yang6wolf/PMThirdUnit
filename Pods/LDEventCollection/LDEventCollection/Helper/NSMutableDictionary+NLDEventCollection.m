//
//  NSMutableDictionary+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/18/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NSMutableDictionary+NLDEventCollection.h"
#import "UIView+NLDHierarchy.h"
#import "NSString+NLDAddition.h"
#import "UIViewController+NLDInternalMethod.h"
#import "UIViewController+NLDAdditionalInfo.h"

@implementation NSMutableDictionary (NLDEventCollection)

+ (instancetype)NLD_dictionary
{
    return [self NLD_dictionaryWithView:nil];
}

+ (nonnull instancetype)NLD_dictionaryWithView:(nullable UIView *)view
{
    NSString *timeStamp = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:timeStamp forKey:@"timeStamp"];
    [dict NLD_setViewOrNil:view];
    
    return dict;
}

- (void)NLD_setViewOrNil:(nullable UIView *)aView
{
    if (!aView) {
        return;
    }
    
    NSString *aKey = @"view";
    [self setValue:[NSStringFromClass([aView class]) NLD_removeSwiftModule] forKey:aKey];
    
    UIViewController *viewController = [aView NLD_controller];
    NSString *pageName = nil;
    if (viewController) {
        pageName = [viewController controllerName];
        [self setValue:pageName forKey:@"controller"];
        
        [self replacePageNameIfNeeded:viewController];
    }
    
    // 如果pageName获取失败，则取最上层的controller(系统弹窗默认获取的controller是nil)
    if (!pageName) {
        pageName = [UIViewController controllerNameForAlertView];
        [self setValue:pageName forKey:@"controller"];
    }
    
    // 接下来使用原始的controllerName作为pageName
    pageName = [[self[@"controller"] componentsSeparatedByString:@"#"] firstObject];
    
    pageName = [pageName NLD_removeSwiftModule];
    
    NSString *viewFrameKey = [NSString stringWithFormat:@"%@Frame", aKey];
    [self setValue:[NSValue valueWithCGRect:[aView NLD_absoluteRectToWindow]] forKey:viewFrameKey];
    
    NSString *depthPathKey = [NSString stringWithFormat:@"%@DepthPath", aKey];
    NSString *depthPath = [aView NLD_depthPathInControllerOrWindow];
    [self setValue:depthPath forKey:depthPathKey];
    
    NSString *viewPathKey = [NSString stringWithFormat:@"%@Path", aKey];
    NSString *viewPath = [aView NLD_viewPathInControllerOrWindow];
    
    /* 不再替换viewPath
    if (viewController && [viewController isKindOfClass:[UINavigationController class]]) {
        viewPath = [self replaceViewPath:viewPath withPageName:pageName];
    } */
    
    NSString *path = [NSString stringWithFormat:@"%@&%@", viewPath, depthPath];
    [self setValue:path forKey:viewPathKey];
    
    // page=""&viewPath=""&depthPath=""
    NSString *viewIdString = [NSString stringWithFormat:@"%@&%@&%@", pageName ?: @"", viewPath, depthPath];
    NSString *viewId = [viewIdString NLD_md5String];
    NSString *viewIdKey = [NSString stringWithFormat:@"%@Id", aKey];
    [self setValue:viewId forKey:viewIdKey];
}

- (void)NLD_setButtonOrNil:(nullable NSObject *)aButton
{
    NSString *aKey = @"view";
    
    NSString *titleKey = [NSString stringWithFormat:@"%@Title", aKey];
    if ([aButton isKindOfClass:[UIBarItem class]]) {
        [self setValue:[NSStringFromClass([aButton class]) NLD_removeSwiftModule] forKey:aKey];
        [self setValue:((UIBarItem *)aButton).title forKey:titleKey];
    }
    else if ([aButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
        [self NLD_setViewOrNil:(UIView *)aButton];
        NSString *text = ((UILabel *)[aButton valueForKey:@"label"]).text;
        [self setValue:text forKey:titleKey];
    }
    else if ([aButton isKindOfClass:[UIButton class]]) {
        [self NLD_setViewOrNil:(UIButton *)aButton];
        [self setValue:((UIButton *)aButton).currentTitle forKey:titleKey];
    }
    else if ([aButton isKindOfClass:[UIView class]]) {
        [self NLD_setViewOrNil:(UIButton *)aButton];
    }
    else {
        [self setValue:[NSStringFromClass([aButton class]) NLD_removeSwiftModule] forKey:aKey];
    }
}

- (void)replacePageNameIfNeeded:(UIViewController *)viewController
{
    if (![viewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    NSString *newPageName = [UIViewController controllerNameForNavigation];
    [self setValue:newPageName forKey:@"controller"];
}

- (nullable NSString *)replaceViewPath:(nullable NSString *)viewPath withPageName:(nullable NSString *)pageName
{
    if (!viewPath || !pageName) {
        return viewPath;
    }
    NSMutableArray *paths = [[viewPath componentsSeparatedByString:@"-"] mutableCopy];
    [paths replaceObjectAtIndex:0 withObject:pageName];
    NSString *newViewPath = [paths componentsJoinedByString:@"-"];
    
    return newViewPath;
}

@end
