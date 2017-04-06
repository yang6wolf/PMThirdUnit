//
//  UITableView+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/6/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UITableView+NLDEventCollection.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import "UIViewController+NLDAdditionalInfo.h"
#import "UIView+NLDHierarchy.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NSIndexPath+NLDDescription.h"
#import "NLDRemoteEventManager.h"
#import "NSObject+MethodSwizzle.h"
#import "UITableView+NLDIndexCollection.h"
#import "NLDEventCollectionManager.h"

NLDNotificationNameDefine(NLDNotificationTableViewDidSelectRow)

@implementation UITableView (NLDEventCollection)

+ (void)NLD_swizz
{
//    [UITableView aspect_hookSelector:@selector(setDelegate:)
//                         withOptions:AspectPositionAfter
//                          usingBlock:^(id<AspectInfo> aspectInfo) {
//                            NSObject *obj = [[aspectInfo arguments] firstObject];
//                            
//                            if (obj != [NSNull null]) {
//                                NSError *insideError = nil;
//                                [obj aspect_hookSelector:@selector(tableView:didSelectRowAtIndexPath:)
//                                             withOptions:AspectPositionAfter
//                                              usingBlock:^(id<AspectInfo> aspectInfo) {
//                                                  
//                                                  NSLog(@"------------------");
//                                                  
//                                              } error:&insideError];
//                                if (insideError) {
//                                    NSLog(@"Error ＝ %@", insideError);
//                                }
//                            }
//                        } error:NULL];
    
    
    
    SEL sel = @selector(setDelegate:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hookUITableView%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <UITableViewDelegate> delegate) {
        SEL subSel = @selector(tableView:didSelectRowAtIndexPath:);
        SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UITableViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UITableView *tableView, __unsafe_unretained NSIndexPath *indexPath) {
            NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:cell];
            
            if ([receiver respondsToSelector:subNewSel] && !collectManager.infoBlock) {
                if (![receiver invokeSelector:subNewSel withArguments:@[tableView ?: [NSNull null], indexPath ?: [NSNull null]]]) {
                    ((void ( *)(id, SEL, id, id))objc_msgSend)(receiver, subNewSel, tableView, indexPath);
                }
            }
            
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
            
            [userInfo setValue:[indexPath NLD_description] forKey:@"indexPath"];
            UIViewController *controller = [tableView NLD_controller];
            
            NSMutableDictionary *additionalDict = [NSMutableDictionary dictionaryWithCapacity:2];
            NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:cell indexPath:indexPath eventName:NSStringFromSelector(subSel)];
            if (relativeInfo) {
                [additionalDict addEntriesFromDictionary:relativeInfo];
            }
            if ([controller respondsToSelector:@selector(NLD_addInfoForTableView:atIndexPath:)]) {
                if ([controller NLD_addInfoForTableView:tableView atIndexPath:indexPath]) {
                    [additionalDict addEntriesFromDictionary:[controller NLD_addInfoForTableView:tableView atIndexPath:indexPath]];
                }
            }
            
            NSString *title = cell.textLabel.text;
            if (!title) {
                NSString *detailText = cell.detailTextLabel.text;
                title = detailText;
//                title = detailText.length <= 10 ? detailText : [detailText substringToIndex:10];
            }
            [additionalDict setValue:title forKey:@"cellTitle"];
            
            
            if (additionalDict.count > 0) {
                [userInfo setValue:additionalDict forKey:@"addition"];
            }

            if (collectManager.infoBlock) {
                collectManager.infoBlock(userInfo, cell);
            }else {
                if (collectManager.logInfoBlock) {
                    userInfo[@"eventName"] = @"ListItemClick";
                    collectManager.logInfoBlock(userInfo);
                }

                [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationTableViewDidSelectRow object:nil userInfo:userInfo.copy];
            }
            
        }];
        
        // 使用 tableView:didEndDisplayingCell:forRowAtIndexPath 来收集离开屏幕的 cell
        subSel = @selector(tableView:didEndDisplayingCell:forRowAtIndexPath:);
        subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UITableViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UITableView *tableView, __unsafe_unretained UITableViewCell* cell, __unsafe_unretained NSIndexPath *indexPath) {
            if ([receiver respondsToSelector:subNewSel]) {
                if (![receiver invokeSelector:subNewSel withArguments:@[tableView ?: [NSNull null], cell ?: [NSNull null],indexPath ?: [NSNull null]]]) {
                    ((void ( *)(id, SEL, id, id, id))objc_msgSend)(receiver, subNewSel, tableView, cell, indexPath);
                }
            }
            
            NSString *index = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            NSString *indexContent = [tableView.showIndexDictionary objectForKey:index];
            if (indexContent) {
                [tableView.hideIndexDictionary setObject:indexContent forKey:index];
            }

            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));

        }];
        
        if ([receiver respondsToSelector:newSel]) {
            if (![receiver invokeSelector:newSel withArguments:@[delegate ?: [NSNull null]]]) {
                ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, delegate);
            }
        }
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
    
//    sel = @selector(setDataSource:);
//    newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
//    res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <UITableViewDataSource> dataSource) {
//        if ([receiver respondsToSelector:newSel]) {
//            ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, dataSource);
//        }
//    });
//    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));

    
//    [UITableView aspect_hookSelector:@selector(setDataSource:)
//                         withOptions:AspectPositionAfter
//                          usingBlock:^(id<AspectInfo> aspectInfo) {
//                              NSLog(@"1 data source hooked");
//                              
//                          } error:nil];
}

@end
