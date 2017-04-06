//
//  UIScrollView+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/6/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UIScrollView+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NSObject+MethodSwizzle.h"
#import "UITableView+NLDIndexCollection.h"
#import "NLDRemoteEventManager.h"
#import "UIView+NLDHierarchy.h"
#import "UIViewController+NLDAdditionalInfo.h"

NLDNotificationNameDefine(NLDNotificationScrollViewWillEndDragging)
NLDNotificationNameDefine(NLDNotificationScrollViewDidEndZooming)
NLDNotificationNameDefine(NLDNotificationScrollViewDidScrollToTop)
NLDNotificationNameDefine(NLDNotificationScrollViewDidStop)

@implementation UIScrollView (NLDEventCollection)

+ (void)NLD_swizz
{
    SEL sel = @selector(setDelegate:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hookUIScrollView%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <UIScrollViewDelegate> delegate) {
        NSString *webScrollViewDelegate = [NSString stringWithFormat:@"_U%@crollViewDeleg%@", @"IWebViewS", @"ateForwarder"];
        if (![NSStringFromClass([delegate class]) isEqualToString:webScrollViewDelegate]) {
            SEL subSel = @selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:);
            SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
            [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UIScrollViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIScrollView *scrollView, CGPoint velocity, CGPoint *targetContentOffset) {
                if ([receiver respondsToSelector:subNewSel]) {
                    ((void ( *)(id, SEL, id, CGPoint, CGPoint *))objc_msgSend)(receiver, subNewSel, scrollView, velocity, targetContentOffset);
                }
                
                LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
                
                NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:scrollView];
                [userInfo setValue:[NSValue valueWithCGPoint:velocity] forKey:@"velocity"];
                [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationScrollViewWillEndDragging object:nil userInfo:userInfo.copy];
            }];
            
            subSel = @selector(scrollViewDidEndZooming:withView:atScale:);
            subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
            [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UIScrollViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIScrollView *scrollView, __unsafe_unretained UIView *view, CGFloat scale) {
                if ([receiver respondsToSelector:subNewSel]) {
                    ((void ( *)(id, SEL, id, id, CGFloat))objc_msgSend)(receiver, subNewSel, scrollView, view, scale);
                }
                
                LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
                
                NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:scrollView];
                [userInfo setValue:@(scale) forKey:@"scale"];
                //[userInfo setValue:view forKey:@"view"];
                [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationScrollViewDidEndZooming object:nil userInfo:userInfo.copy];
            }];
            
            subSel = @selector(scrollViewDidScrollToTop:);
            subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
            [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UIScrollViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIScrollView *scrollView) {
                if ([receiver respondsToSelector:subNewSel]) {
                    if (![receiver invokeSelector:subNewSel withArguments:@[scrollView]]) {
                        ((void ( *)(id, SEL, id))objc_msgSend)(receiver, subNewSel, scrollView);
                    }
                }
                
                LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
                
                NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:scrollView];
                [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationScrollViewDidScrollToTop object:nil userInfo:userInfo.copy];
            }];
            
            // 利用 scrollViewDidEndDecelerating: 和 scrollViewDidEndDragging:willDecelerate:来收集曝光量的信息
            subSel = @selector(scrollViewDidEndDecelerating:);
            subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
            [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UIScrollViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIScrollView *scrollView) {
                if ([receiver respondsToSelector:subNewSel]) {
                    if (![receiver invokeSelector:subNewSel withArguments:@[scrollView]]) {
                        ((void ( *)(id, SEL, id))objc_msgSend)(receiver, subNewSel, scrollView);
                    }
                }
                
                LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
                
                if ([scrollView isKindOfClass:[UITableView class]]) {
                    UITableView *tableView = scrollView;
                    NSArray *indexPathArray = tableView.indexPathsForVisibleRows;
                    tableView.showIndexDictionary = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:scrollView];
                    
                    for (NSIndexPath *indexPath in indexPathArray) {
                        NSString *indexString = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                        NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:cell indexPath:indexPath eventName:NSStringFromSelector(subSel)];
                        if (relativeInfo.count > 0) {
                            NSArray *allKeys = [relativeInfo allKeys];
                            NSString *value = [relativeInfo objectForKey:[allKeys objectAtIndex:0]];
                            
                            [tableView.showIndexDictionary setObject:value forKey:indexString];
                            
                            if ([tableView.hideIndexDictionary objectForKey:indexString]) {
                                [tableView.hideIndexDictionary removeObjectForKey:indexString];
                            }
                        }
                    }
                    
                    [userInfo setValue:tableView.showIndexDictionary forKey:@"show"];
                    
                    if (tableView.hideIndexDictionary.count > 0) {
                        [userInfo setValue:tableView.hideIndexDictionary forKey:@"hide"];
                    }
                    
                    if (tableView.showIndexDictionary.count > 0 || tableView.hideIndexDictionary.count > 0) {
                        [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationScrollViewDidStop object:nil userInfo:userInfo.copy];
                    }
                    
                    tableView.hideIndexDictionary = [[NSMutableDictionary alloc] init];
                }
            }];
            
            subSel = @selector(scrollViewDidEndDragging:willDecelerate:);
            subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
            [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UIScrollViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UIScrollView *scrollView, BOOL decelerate) {
                if ([receiver respondsToSelector:subNewSel]) {
                    ((void ( *)(id, SEL, id, BOOL))objc_msgSend)(receiver, subNewSel, scrollView, decelerate);
                }
                
                LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
                
                // 没有减速过程，直接停止
                if (!decelerate) {
                    if ([scrollView isKindOfClass:[UITableView class]]) {
                        UITableView *tableView = scrollView;
                        NSArray *indexPathArray = tableView.indexPathsForVisibleRows;
                        tableView.showIndexDictionary = [[NSMutableDictionary alloc] init];
                        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:scrollView];
                        
                        for (NSIndexPath *indexPath in indexPathArray) {
                            NSString *indexString = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                            NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:cell indexPath:indexPath eventName:@"scrollViewDidEndDecelerating:"];
                            if (relativeInfo.count > 0) {
                                NSArray *allKeys = [relativeInfo allKeys];
                                NSString *value = [relativeInfo objectForKey:[allKeys objectAtIndex:0]];
                                
                                [tableView.showIndexDictionary setObject:value forKey:indexString];
                                
                                if ([tableView.hideIndexDictionary objectForKey:indexString]) {
                                    [tableView.hideIndexDictionary removeObjectForKey:indexString];
                                }
                            }
                        }
                        
                        [userInfo setValue:tableView.showIndexDictionary forKey:@"show"];
                        
                        if (tableView.hideIndexDictionary.count > 0) {
                            [userInfo setValue:tableView.hideIndexDictionary forKey:@"hide"];
                        }
                        
                        if (tableView.showIndexDictionary.count > 0 || tableView.hideIndexDictionary.count > 0) {
                            [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationScrollViewDidStop object:nil userInfo:userInfo.copy];
                        }
                        
                        tableView.hideIndexDictionary = [[NSMutableDictionary alloc] init];
                    }
                }
            }];
        }
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[delegate ?: [NSNull null]]]) {
                ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, delegate);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
}

@end
