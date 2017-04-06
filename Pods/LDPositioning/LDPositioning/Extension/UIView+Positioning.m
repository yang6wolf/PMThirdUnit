//
//  UIView+Positioning.m
//  NeteaseLottery
//
//  Created by wuxu on 16/5/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "UIView+Positioning.h"
#import <objc/runtime.h>

@implementation UIView (Positioning)

#pragma mark -

- (nullable UIViewController *)ldp_manageViewController
{
    UIViewController *viewController = nil;
    SEL viewDelSel = NSSelectorFromString([NSString stringWithFormat:@"%@ewDelegate", @"_vi"]);
    if ([self respondsToSelector:viewDelSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        viewController = [self performSelector:viewDelSel];
#pragma clang diagnostic pop
    }
    return viewController;
}

- (nullable UIViewController *)ldp_nearViewController
{
    UIView *view = self;
    UIViewController *viewController = nil;
    
    do {
        viewController = [view ldp_manageViewController];
        view = view.superview;
    } while (!viewController && view);
    
    return viewController;
}

- (NSUInteger)ldp_indexAtSuperView
{
    return [self.superview.subviews indexOfObject:self];
}

- (NSUInteger)ldp_indexAtSuperViewSameSubviews
{
    return [[self.superview ldp_subviewsOf:self.class] indexOfObject:self];
}

- (nullable NSArray *)ldp_subviewsOf:(Class)aClass
{
    NSMutableArray *temp = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:aClass]) {
            [temp addObject:view];
        }
    }
    
    return temp;
}

@end
