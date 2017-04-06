//
//  UIResponder+NLDEventCollection.m
//  Pods
//
//  Created by 高振伟 on 16/10/17.
//
//

#import "UIResponder+NLDEventCollection.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NLDMacroDef.h"
#import "NSObject+NLDPerformSelector.h"
#import "NSMutableDictionary+NLDEventCollection.h"
#import "UIView+NLDHierarchy.h"
#import "NSNotificationCenter+NLDEventCollection.h"
#import "NSObject+MethodSwizzle.h"
#import "NLDEventCollectionManager.h"

@implementation UIResponder (NLDEventCollection)

+ (void)NLD_swizz
{
    NLDEventCollectionManager *collectManager = [NLDEventCollectionManager sharedManager];
    
    SEL sel = @selector(touchesEnded:withEvent:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [self NLD_swizzSelector:sel referProtocol:nil newSel:newSel usingBlock:^void(__unsafe_unretained UIResponder *receiver, __unsafe_unretained NSSet<UITouch *> *touches, __unsafe_unretained UIEvent *event) {
        
        LDECLog(@"监测到系统调用的方法：%@ ", NSStringFromSelector(sel));
        
        if ([receiver respondsToSelector:newSel] && !collectManager.infoBlock) {
            ((void ( *)(id, SEL, id, id))objc_msgSend)(receiver, newSel, touches, event);
        }
        
        UIView *view = [touches anyObject].view;
        NSMutableDictionary *userInfo = [NSMutableDictionary NLD_dictionaryWithView:view];
        __unused UIViewController *controller = [view NLD_controller];
        
        if (collectManager.infoBlock) {
            collectManager.infoBlock(userInfo, view);
        }
        else {
            [NSNotificationCenter NLD_postEventCollectionNotificationName:@"NLDNotificationTapGesture" object:nil userInfo:userInfo.copy];
        }

        
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
}

@end
