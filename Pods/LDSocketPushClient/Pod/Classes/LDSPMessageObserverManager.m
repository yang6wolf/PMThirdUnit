//
//  LDSPMessageObserverManager.m
//  Pods
//
//  Created by liubing on 8/6/15.
//
//

#import "LDSPMessageObserverManager.h"
#import "LDSPMessageObserver.h"

@interface LDSPMessageObserverManager ()

@property (nonatomic,strong) NSMutableDictionary *observersDictionary;

@end

@implementation LDSPMessageObserverManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _observersDictionary = [NSMutableDictionary new];
    }
    return self;
}

- (BOOL)hasObservers
{
    for (NSArray *array in self.observersDictionary.allValues) {
        if (array.count) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)observersQueueWithTopic:(NSString *)topic
{
    return [[self privateObserversQueueWithTopic:topic] copy];
}

- (NSArray *)allObservedTopic
{
    return self.observersDictionary.allKeys;
}

- (NSMutableArray *)privateObserversQueueWithTopic:(NSString *)topic
{
    if (!topic) {
        return nil;
    }
    
    return self.observersDictionary[topic];
}

- (void)removeTopic:(NSString *)topic
{
    if (!topic) {
        return;
    }
    
    [self.observersDictionary removeObjectForKey:topic];
}

- (void)addObserver:(LDSPMessageObserver *)observer
{
    if (!observer || !observer.topic) {
        return;
    }
    
    NSMutableArray *queue = [self privateObserversQueueWithTopic:observer.topic];
    
    if (queue == nil) {
        queue = [NSMutableArray new];
        self.observersDictionary[observer.topic] = queue;
    }
    
    if (![queue containsObject:observer]) {
        [queue addObject:observer];
    }
}

- (void)removeObserver:(LDSPMessageObserver *)observer
{
    NSMutableArray *queue = [self privateObserversQueueWithTopic:observer.topic];
    [queue removeObject:observer];
    
    if (queue.count == 0) {
        [self removeTopic:observer.topic];
    }
}

@end
