//
//  NeteaseMAControllerProber.m
//  MobileAnalysis
//
//  Created by  龙会湖 on 8/14/14.
//  Copyright (c) 2014 zhang jie. All rights reserved.
//

#import "NeteaseMAControllerProber.h"
#import "UIViewController+NeteaseMA.h"

#define RECORD_LIMIT 50

@interface NeteaseMAControllerProber()<NeteaseMAViewControllerDelegate>
@end

@implementation NeteaseMAControllerProber {
    NSMutableDictionary *_recordMap;
    NSMutableArray *_historyViewControllerNames;
    NSInteger _recordLimit;
}

- (id)init {
    if (self=[super init]) {
        _recordMap = [NSMutableDictionary dictionary];
        [UIViewController neteasema_setDelegate:self];
        
        _historyViewControllerNames = [NSMutableArray array];
        
        _recordLimit = RECORD_LIMIT;
    }
    return self;
}

- (void)start {
    [UIViewController neteasema_startProbe];
}

- (NeteaseMAViewControllerRecord*)getRecordForController:(UIViewController*)controller {
    if (!controller) {
        return nil;
    }
    NSString *pageName = NSStringFromClass(controller.class);
    NeteaseMAViewControllerRecord *record = [_recordMap objectForKey:pageName];
    if (!record) {
        if (![_historyViewControllerNames containsObject:pageName]) {
            NeteaseMAViewControllerRecord *record = [NeteaseMAViewControllerRecord new];
            record.controllerName = pageName;
            [_recordMap setObject:record forKey:pageName];
            [_historyViewControllerNames addObject:pageName];
        }
    }
    return record;
}

- (void)clearExpiredRecords {
    NSEnumerator *keyEnum = [_recordMap keyEnumerator];
    NSHashTable *expiredKeys = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:30];
    id key = nil;
    while (key = [keyEnum nextObject]) {
        [expiredKeys addObject:key];
    }
    for (id key in expiredKeys) {
        [_recordMap removeObjectForKey:key];
    }
    if (_recordMap.count+10>_recordLimit) {
        _recordLimit += _recordLimit;
    }
}

#pragma mark NeteaseMAViewControllerDelegate

- (void)viewControllerLoadView:(UIViewController*)controller {
    NeteaseMAViewControllerRecord *record = [self getRecordForController:controller];
    record.willloadTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewControllerViewDidLoad:(UIViewController *)controller {
    if (_recordMap.count>_recordLimit) {
        [self clearExpiredRecords];
    }
    NeteaseMAViewControllerRecord *record = [self getRecordForController:controller];
    record.didloadTime = [[NSDate date] timeIntervalSince1970];
    [self.delegate controllerProber:self didGetEvent:NeteaseMAControllerCreate forController:controller];
}

- (void)viewControllerWillAppear:(UIViewController *)controller {
    NSString *pageName = NSStringFromClass(controller.class);
    NeteaseMAViewControllerRecord *record = [_recordMap objectForKey:pageName];
    if (!record) { //当一个viewcontroller再次出现时，不统计其时间
        return;
    }
    record.appearTime = [[NSDate date] timeIntervalSince1970];
    [_recordMap removeObjectForKey:pageName];
    
    NSDictionary *dict = [record toDictionary];
    if (dict) {
        [self.delegate controllerProber:self didGetPeformanceRecord:dict];
    }
}

- (void)viewControllerWillDisappear:(UIViewController *)controller {
    [self.delegate controllerProber:self didGetEvent:NeteaseMAControllerClose forController:controller];
}

- (void)viewControllerDidAppear:(UIViewController *)controller {
    [self.delegate controllerProber:self didGetEvent:NeteaseMAControllerOpen forController:controller];
}

- (void)viewControllerDealloc:(UIViewController *)controller {
    [self.delegate controllerProber:self didGetEvent:NeteaseMAControllerDestroy forController:controller];
}

@end

@implementation NeteaseMAViewControllerRecord

- (BOOL)isExpired {
    if (!self.controllerName) {
        return YES;
    }
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (self.willloadTime>0&&self.willloadTime+CONTROLLER_LOAD_TIME_LIMIT<now) {
        return YES;
    }
    if (self.didloadTime>0&&self.didloadTime+CONTROLLER_LOAD_TIME_LIMIT<now) {
        return YES;
    }
    return NO;
}

- (NSDictionary*)toDictionary {
    if (!self.controllerName) {
        return nil;
    }
    NSTimeInterval startTime = self.willloadTime>0?self.willloadTime:self.didloadTime;
    if (startTime<0.1) {
        return nil;
    }
    
    return @{@"n":self.controllerName,
             @"st":[NSNumber numberWithLongLong:startTime*1000],
             @"et":[NSNumber numberWithLongLong:self.appearTime*1000]};
}

@end
