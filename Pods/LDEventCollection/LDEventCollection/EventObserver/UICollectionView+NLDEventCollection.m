//
//  UICollectionView+NLDEventCollection.m
//  LDEventCollection
//
//  Created by SongLi on 5/17/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "UICollectionView+NLDEventCollection.h"
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
#import "NLDEventCollectionManager.h"

NLDNotificationNameDefine(NLDNotificationCollectionViewDidSelectIndexPath)

@implementation UICollectionView (NLDEventCollection)

+ (void)NLD_swizz
{
    SEL sel = @selector(setDelegate:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hookUICollectionView%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <UICollectionViewDelegate> delegate) {
        SEL subSel = @selector(collectionView:didSelectItemAtIndexPath:);
        SEL subNewSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(subSel)]);
        [[delegate class] NLD_swizzSelector:subSel referProtocol:@protocol(UICollectionViewDelegate) newSel:subNewSel usingBlock:^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof UICollectionView *collectionView, __unsafe_unretained NSIndexPath *indexPath) {
            
            NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];
            
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:cell];
            
            if ([receiver respondsToSelector:subNewSel] && !collectManager.infoBlock) {
                if (![receiver invokeSelector:subNewSel withArguments:@[collectionView, indexPath]]) {
                    ((void ( *)(id, SEL, id, id))objc_msgSend)(receiver, subNewSel, collectionView, indexPath);
                }
            }
            
            LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(subSel));
            
            [userInfo setValue:[indexPath  NLD_description] forKey:@"indexPath"];
            UIViewController *controller = [collectionView NLD_controller];
            
            NSMutableDictionary *additionalDict = [NSMutableDictionary dictionaryWithCapacity:2];
            NSDictionary *relativeInfo = [[NLDRemoteEventManager sharedManager] tryToCollectDataWithCurrentView:cell indexPath:indexPath eventName:NSStringFromSelector(subSel)];
            if (relativeInfo) {
                [additionalDict addEntriesFromDictionary:relativeInfo];
            }
            if ([controller respondsToSelector:@selector(NLD_addInfoForCollectionView:atIndexPath:)]) {
                if ([controller NLD_addInfoForCollectionView:collectionView atIndexPath:indexPath]) {
                    [additionalDict addEntriesFromDictionary:[controller NLD_addInfoForCollectionView:collectionView atIndexPath:indexPath]];
                }
            }
            if (additionalDict.count > 0) {
                [userInfo setValue:additionalDict forKey:@"addition"];
            }
            
            if (collectManager.infoBlock) {
                collectManager.infoBlock(userInfo, cell);
            }
            else {
                [NSNotificationCenter NLD_postEventCollectionNotificationName:NLDNotificationCollectionViewDidSelectIndexPath object:nil userInfo:userInfo.copy];
            }
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
//    res = NLD_swizzSelector(self, sel, nil, newSel, ^void(__unsafe_unretained id receiver, __unsafe_unretained __kindof id <UICollectionViewDataSource> dataSource) {
//        if ([receiver respondsToSelector:newSel]) {
//            ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, dataSource);
//        }
//    });
//    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
}

@end
