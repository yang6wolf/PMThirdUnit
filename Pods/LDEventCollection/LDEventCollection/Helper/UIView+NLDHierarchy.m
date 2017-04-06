//
//  UIView+NLDHierarchy.m
//  LDEventCollection
//
//  Created by SongLi on 5/18/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIView+NLDHierarchy.h"
#import "UIViewController+NLDAdditionalInfo.h"
#import "NSString+NLDAddition.h"

@implementation UIView (NLDHierarchy)

- (nullable UIViewController *)NLD_controller
{
    UIResponder *nextResponder = self.nextResponder;
    while (nextResponder && ![nextResponder isKindOfClass:[UIViewController class]]) {
        nextResponder = nextResponder.nextResponder;
    }
    return (UIViewController *)nextResponder;
}

- (nullable NSString *)NLD_pathToControllerOrWindow
{
    UIViewController *controller = [self NLD_controller];
    UIView *finalView = controller ? controller.view : self.window;
    if (!finalView) {
        return nil;
    }
    
    NSMutableArray *pathArray = [NSMutableArray array];
    UIView *superview = self;
    while (superview && superview != finalView) {
        [pathArray insertObject:[superview class] atIndex:0];
        superview = superview.superview;
    }
    [pathArray insertObject:controller ? [controller class] : [self.window class] atIndex:0];
    return [pathArray componentsJoinedByString:@"-"];
}

- (nullable NSString *)NLD_viewPathInControllerOrWindow
{
    return [self caculateViewRoute:YES];
}

- (nullable NSString *)NLD_depthPathInControllerOrWindow
{
    return [self caculateViewRoute:NO];
}

- (nullable NSString *)caculateViewRoute:(BOOL)isViewPath
{
    NSString *viewPath = nil;
    NSString *depthPath = nil;
    
    UIView *view = self;
    UIViewController *controller = nil;
    
    UIView *reuseView = nil;
    UIView *reuseContainer = nil;
    NSIndexPath *indexPath = nil;
    
    NSString *fromControllerViewPaths = @"";
    NSString *fromControllerDepthPaths = @"";
    
    NSString *fromReuseViewPaths = @"";
    NSString *fromReuseViewIndexPaths = @"";
    
    do {
        controller = [self manageViewController:view];
        
        if (controller) {
            fromControllerViewPaths = [NSString stringWithFormat:@"%@-%@", [NSStringFromClass(controller.class) NLD_removeSwiftModule], fromControllerViewPaths];
        } else {
            if ([view isKindOfClass:[UITableViewCell class]] || [view isKindOfClass:[UICollectionViewCell class]]) {
                fromReuseViewPaths = fromControllerViewPaths;
                fromControllerViewPaths = @"";
            } else {
                fromControllerViewPaths = [NSString stringWithFormat:@"%@-%@", [NSStringFromClass(view.class) NLD_removeSwiftModule], fromControllerViewPaths];
            }
        }
        
        if ([view isKindOfClass:[UITableViewCell class]]) {
            UITableView *table = [self manageTableView:(UITableViewCell *)view];
            
            NSIndexPath *path = [table indexPathForCell:(UITableViewCell *)view];
            
            reuseView = view;
            reuseContainer = table;
            indexPath = path;
            
            fromReuseViewIndexPaths = fromControllerDepthPaths;
            fromControllerDepthPaths = @"";
            
            view = table;
        } else if ([view isKindOfClass:[UICollectionViewCell class]]) {
            UICollectionView *collection = [self manageCollectionView:(UICollectionViewCell *)view];
            
            NSIndexPath *path = [collection indexPathForCell:(UICollectionViewCell *)view];
            
            reuseView = view;
            reuseContainer = collection;
            indexPath = path;
            
            fromReuseViewIndexPaths = fromControllerDepthPaths;
            fromControllerDepthPaths = @"";
            
            view = collection;
        } else {
//            NSUInteger idx = [view.superview.subviews indexOfObject:view];
            NSUInteger idx = 0;
            if (!controller) {
                idx = [view NLD_indexAtSuperViewSameSubviews];
            }
            
            fromControllerDepthPaths = [NSString stringWithFormat:@"%@-%@", [NSString stringWithFormat:@"%@", @(idx)], fromControllerDepthPaths];
            
            view = view.superview;
        }
        
    } while (!controller && view);
    
    fromControllerViewPaths = [fromControllerViewPaths stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    fromControllerDepthPaths = [fromControllerDepthPaths stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    
    fromReuseViewPaths = [fromReuseViewPaths stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    fromReuseViewIndexPaths = [fromReuseViewIndexPaths stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    
    if (reuseContainer) {
        UIView *view = reuseView.superview;
        NSString *path = @"";
        NSString *depth = @"";
        while (![view isKindOfClass:[reuseContainer class]]) {
            path = [NSString stringWithFormat:@"%@-%@", [NSStringFromClass([view class]) NLD_removeSwiftModule], path];
//            NSUInteger idx = [view.superview.subviews indexOfObject:view];
            NSUInteger idx = [view NLD_indexAtSuperViewSameSubviews];
            depth = [NSString stringWithFormat:@"%lu-%@", (unsigned long)idx, depth];
            view = view.superview;
        }
        
        path = [path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        if (path.length > 0) {
            viewPath = [NSString stringWithFormat:@"%@-%@-%@-%@", fromControllerViewPaths, path,[NSStringFromClass([reuseView class]) NLD_removeSwiftModule], fromReuseViewPaths];
        } else {
            viewPath = [NSString stringWithFormat:@"%@-%@-%@", fromControllerViewPaths,[NSStringFromClass([reuseView class]) NLD_removeSwiftModule], fromReuseViewPaths];
        }
        
        depth = [depth stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        NSString *indexPathStr = [NSString stringWithFormat:@"%ld:%ld", (long)indexPath.section, (long)indexPath.row];
        if (depth.length > 0) {
            depthPath = [NSString stringWithFormat:@"%@-%@-%@-%@", fromControllerDepthPaths, depth, indexPathStr, fromReuseViewIndexPaths];
        } else {
            depthPath = [NSString stringWithFormat:@"%@-%@-%@", fromControllerDepthPaths, indexPathStr, fromReuseViewIndexPaths];
        }
    } else {
        viewPath = fromControllerViewPaths;
        depthPath = fromControllerDepthPaths;
    }
    
    if (isViewPath) {
        return [viewPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    } else {
        return [depthPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    }
}

- (nullable UIViewController *)manageViewController:(__kindof UIView *)view
{
    UIViewController *viewController = nil;
    SEL viewDelSel = NSSelectorFromString([NSString stringWithFormat:@"%@ewDelegate", @"_vi"]);
    if ([view respondsToSelector:viewDelSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        viewController = [view performSelector:viewDelSel];
#pragma clang diagnostic pop
    }
    return viewController;
}

- (nullable UITableView *)manageTableView:(__kindof UITableViewCell *)cell
{
    UIView *tableView = cell.superview;
    
    while (tableView && ![tableView isKindOfClass:[UITableView class]]) {
        tableView = tableView.superview;
    }
    
    return (UITableView *)tableView;
}

- (nullable UICollectionView *)manageCollectionView:(__kindof UICollectionViewCell *)cell
{
    UIView *collectionView = cell.superview;
    
    while (collectionView && ![collectionView isKindOfClass:[UICollectionView class]]) {
        collectionView = collectionView.superview;
    }
    
    return (UICollectionView *)collectionView;
}

- (NSUInteger)NLD_indexAtSuperViewSameSubviews
{
    return [[self.superview NLD_subviewsOf:self.class] indexOfObject:self];
}

- (nullable NSArray *)NLD_subviewsOf:(Class)aClass
{
    NSMutableArray *temp = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:aClass]) {
            [temp addObject:view];
        }
    }
    
    return temp;
}

- (CGRect)NLD_absoluteRectToWindow
{
    UIWindow *window = self.window;
    if (!window) {
        return CGRectZero;
    }
    
    CGRect rect = self.frame;
    UIView *superview = self.superview;
    while (superview && superview != window) {
        rect.origin.x += superview.frame.origin.x;
        rect.origin.y += superview.frame.origin.y;
        if ([superview isKindOfClass:[UIScrollView class]]) {
            rect.origin.x += ((UIScrollView *)superview).contentInset.left;
            rect.origin.y += ((UIScrollView *)superview).contentInset.top;
        }
        superview = superview.superview;
    }
    return rect;
}

@end
