//
//  LDPassivePositioning.m
//  LDPositioningDemo
//
//  Created by wuxu on 16/5/27.
//  Copyright © 2016年 wuxu. All rights reserved.
//

#import "LDPassivePositioning.h"
#import "UIView+Positioning.h"
#import "UITableViewCell+Positioning.h"
#import "UICollectionViewCell+Positioning.h"

@implementation LDPassivePositioning

+ (BOOL)isRoute:(id<LDPassiveRoute>)route matchToView:(__kindof UIView *)view
{
    return [self isRoute:route matchToView:view ignoreSwiftModule:NO];
}

+ (BOOL)isRoute:(id<LDPassiveRoute>)route matchToView:(__kindof UIView *)view ignoreSwiftModule:(BOOL)ignore
{
    if (!view) {
        return NO;
    }
    
    if (!view.window) {
        return NO;
    }
    
    NSString *viewName = [self stringFromClass:[view class] ignoreSwiftModule:ignore];
    if (![viewName isEqualToString:route.viewName]) {
        return NO;
    }
    
    NSString *controllerName = [self stringFromClass:[[view ldp_nearViewController] class] ignoreSwiftModule:ignore];
    if (![controllerName isEqualToString:route.controllerName]) {
        return NO;
    }
    
    NSString *windowName = [self stringFromClass:[view.window class] ignoreSwiftModule:ignore];
    if (![windowName isEqualToString:route.windowName]) {
        return NO;
    }
    
    __block UIView *superView = view;
    __block BOOL result;
    
    [route.fromControllerViewPaths enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!([obj isEqualToString:[self stringFromClass:[superView class] ignoreSwiftModule:ignore]] ||
              [obj isEqualToString:[self stringFromClass:[[superView ldp_manageViewController] class] ignoreSwiftModule:ignore]])) {
            *stop = YES;
            result = NO;
            return;
        }
        
        if (idx != 0) {
            if ([superView isKindOfClass:[UITableViewCell class]]) {
                NSString *reuseCellDepthPath = route.fromControllerDepthPaths[idx];
                if (![reuseCellDepthPath isEqualToString:@"*:*"]) {   // 如果是 *:* ，表示通用匹配
                    NSArray<NSString *> *indexArray = [reuseCellDepthPath componentsSeparatedByString:@":"];
                    NSIndexPath *indexP = [NSIndexPath indexPathForRow:[indexArray[1] integerValue] inSection:[indexArray[0] integerValue]];
                    
                    UITableViewCell *cell = (UITableViewCell *)superView;
                    UITableView *tableView = [cell ldp_manageTableView];
                    NSIndexPath *path = [tableView indexPathForCell:cell];
                    
                    if (path) {
                        if (path.section != indexP.section || path.row != indexP.row) {
                            *stop = YES;
                            result = NO;
                            return;
                        }
                    } else {
                        *stop = YES;
                        result = NO;
                        return;
                    }
                }
            } else if ([superView isKindOfClass:[UICollectionViewCell class]]) {
                NSString *reuseCellDepthPath = route.fromControllerDepthPaths[idx];
                if (![reuseCellDepthPath isEqualToString:@"*:*"]) {   // 如果是 *:* ，表示通用匹配
                    NSArray<NSString *> *indexArray = [reuseCellDepthPath componentsSeparatedByString:@":"];
                    NSIndexPath *indexP = [NSIndexPath indexPathForRow:[indexArray[1] integerValue] inSection:[indexArray[0] integerValue]];
                    
                    UICollectionViewCell *cell = (UICollectionViewCell *)superView;
                    UICollectionView *tableView = [cell ldp_manageCollectionView];
                    NSIndexPath *path = [tableView indexPathForCell:cell];
                    
                    if (path) {
                        if (path.section != indexP.section || path.row != indexP.row) {
                            *stop = YES;
                            result = NO;
                            return;
                        }
                    } else {
                        *stop = YES;
                        result = NO;
                        return;
                    }
                }
            } else {
                NSUInteger num = [superView ldp_indexAtSuperViewSameSubviews];
                if ([route.fromControllerDepthPaths[idx] integerValue] != num) {
                    *stop = YES;
                    result = NO;
                    return;
                }
            }
        } else {
            *stop = YES;
            result = YES;
            return;
        }
        
        superView = superView.superview;
    }];
    
    return result;
}

+ (NSString *)stringFromClass:(Class)aClass ignoreSwiftModule:(BOOL)ignore
{
    NSString *className = NSStringFromClass(aClass);
    
    if (ignore && [className rangeOfString:@"."].location != NSNotFound) {
        NSArray *stringComponents = [className componentsSeparatedByString:@"."];
        if (stringComponents.count == 2) {
            className = stringComponents[1];
        }
    }
    
    return className;
}

@end
