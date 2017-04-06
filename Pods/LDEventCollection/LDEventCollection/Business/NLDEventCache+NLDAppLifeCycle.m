//
//  NLDEventCache+NLDAppLifeCycle.m
//  LDEventCollection
//
//  Created by SongLi on 6/3/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import "NLDEventCache+NLDAppLifeCycle.h"
#import "NLDEventCollectionManager.h"
#import "NLDEventCollector.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+MethodSwizzle.h"

static NSUncaughtExceptionHandler *originHandler;
static void NLDUncaughtExceptionHandler(NSException *exeption)
{
    NLDEventCollector *collector = [[NLDEventCollectionManager sharedManager] valueForKey:@"eventCollector"];
    NLDEventCache *cache = [[NLDEventCollectionManager sharedManager] valueForKey:@"eventCache"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([collector respondsToSelector:@selector(handleAppDidRecieveUncaughtException)]) {
        [collector performSelector:@selector(handleAppDidRecieveUncaughtException)];
    }
    if ([cache respondsToSelector:@selector(quickSave)]) {
        [cache performSelector:@selector(quickSave)];
    }
#pragma clang diagnostic pop
    
    !originHandler ?: originHandler(exeption);
}

@implementation NLDEventCache (NLDAppLifeCycle)

+ (void)NLD_swizzForAppTerminate
{
    NSObject <UIApplicationDelegate> *appDelegate = [UIApplication sharedApplication].delegate;
    SEL sel = @selector(applicationWillTerminate:);
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"NLD_hook%@", NSStringFromSelector(sel)]);
    __unused BOOL res = [[appDelegate class] NLD_swizzSelector:sel referProtocol:@protocol(UIApplicationDelegate) newSel:newSel usingBlock:^void(__unsafe_unretained NSObject<UIApplicationDelegate> *receiver, __unsafe_unretained UIApplication *application) {
        NLDEventCache *cache = [[NLDEventCollectionManager sharedManager] valueForKey:@"eventCache"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([cache respondsToSelector:@selector(quickSave)]) {
            [cache performSelector:@selector(quickSave)];
        }
#pragma clang diagnostic pop
        
        if ([receiver respondsToSelector:newSel]) {
            ((void ( *)(id, SEL, id))objc_msgSend)(receiver, newSel, application);
        }
    }];
    NSAssert(res, @"%s Failed Hook %@!", __func__, NSStringFromSelector(sel));
}

- (void)setupUncaughtExceptionHandler
{
    originHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&NLDUncaughtExceptionHandler);
}

@end
