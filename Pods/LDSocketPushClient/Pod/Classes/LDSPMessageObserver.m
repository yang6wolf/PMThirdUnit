//
//  LDSPMessageObserver.m
//  Pods
//
//  Created by liubing on 8/6/15.
//
//

#import "LDSPMessageObserver.h"

@implementation LDSPMessageObserver

+ (instancetype)observerWithTarget:(id)target topic:(NSString *)topic block:(id)block
{
    LDSPMessageObserver *observer = [LDSPMessageObserver new];
    
    observer.target = target;
    observer.topic = topic;
    observer.block = block;
    
    return observer;
}

- (BOOL)isEqual:(LDSPMessageObserver *)object
{
    if (![object isKindOfClass:[LDSPMessageObserver class]]) {
        return NO;
    }
    
    return self.target == object.target && [self.topic isEqualToString:object.topic] && [self.block isEqual:object.block];
}

- (NSUInteger)hash
{
    return [self.target hash] & self.topic.hash;
}

@end
