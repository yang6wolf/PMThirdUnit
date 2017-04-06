//
//  LDPositioningCommon.m
//  NeteaseLottery
//
//  Created by wuxu on 16/5/10.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "LDPositioningCommon.h"
#import "UIView+Positioning.h"

@implementation LDPositioningCommon

+ (BOOL)isView:(__kindof UIView *)view equalToPaths:(NSArray<NSString *> *)paths andDepths:(NSArray<NSString *> *)depths
{
    NSParameterAssert(view);
    NSParameterAssert(paths);
    NSParameterAssert(depths);
    
    if (!view || !paths || !depths || paths.count != depths.count) {
        return NO;
    }
    
    __block UIView *superView = view;
    __block BOOL result = NO;
    
    [paths enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!([obj isEqualToString:NSStringFromClass([superView class])] ||
              [obj isEqualToString:NSStringFromClass([[superView ldp_manageViewController] class])])) {
            result = NO;
            *stop = YES;
            return;
        }
        
        if (idx != 0) {
            if ([depths[idx] integerValue] != [superView ldp_indexAtSuperViewSameSubviews]) {
                result = NO;
                *stop = YES;
                return;
            }
        } else {
            result = YES;
            *stop = YES;
            return;
        }
        
        superView = superView.superview;
    }];
    
    return result;
}

+ (nullable __kindof UIView *)findTargetWithRootView:(__kindof UIView *)view paths:(NSArray<NSString *> *)paths indexs:(NSArray<NSString *> *)indexs
{
    NSParameterAssert(view);
    NSParameterAssert(paths);
    NSParameterAssert(indexs);
    
    if (!view || !paths || !indexs || paths.count != indexs.count) {
        return nil;
    }
    
    __block UIView *subView = view;
    __block BOOL result = NO;
    
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger index = [indexs[idx] integerValue];
        NSArray *sameSubviews = [subView ldp_subviewsOf:NSClassFromString(obj)];
        
        if (sameSubviews.count < index) {
            result = NO;
            *stop = YES;
            return;
        } else {
            subView = sameSubviews[index];
            
            if (idx == paths.count - 1) {
                result = YES;
            }
        }
    }];
    
    return result ? subView : nil;
}

@end
