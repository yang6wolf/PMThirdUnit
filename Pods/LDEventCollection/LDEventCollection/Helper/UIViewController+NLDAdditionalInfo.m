//
//  UIViewController+NLDAdditionalInfo.m
//  LDEventCollection
//
//  Created by 高振伟 on 16/11/23.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIViewController+NLDAdditionalInfo.h"
#import <objc/runtime.h>

@implementation UIViewController (NLDAdditionalInfo)

- (NSString *)pageAlias
{
    return objc_getAssociatedObject(self, @selector(pageAlias));
}

- (void)setPageAlias:(NSString *)newPageAlias
{
    objc_setAssociatedObject(self, @selector(pageAlias), newPageAlias, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)pageAliasInRN
{
    return objc_getAssociatedObject(self, @selector(pageAliasInRN));
}

- (void)setPageAliasInRN:(NSString *)newPageAlias
{
    objc_setAssociatedObject(self, @selector(pageAliasInRN), newPageAlias, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)componentName
{
    return objc_getAssociatedObject(self, @selector(componentName));
}

- (void)setComponentName:(NSString *)newComponentName
{
    objc_setAssociatedObject(self, @selector(componentName), newComponentName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
