//
//  LDSPMessageObserverManager.h
//  Pods
//
//  Created by liubing on 8/6/15.
//
//

#import <Foundation/Foundation.h>

@class LDSPMessageObserver;

@interface LDSPMessageObserverManager : NSObject

- (BOOL)hasObservers;

- (NSArray *)observersQueueWithTopic:(NSString *)topic;
- (NSArray *)allObservedTopic;

- (void)addObserver:(LDSPMessageObserver *)observer;
- (void)removeObserver:(LDSPMessageObserver *)observer;

@end
