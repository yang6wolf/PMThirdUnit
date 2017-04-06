//
//  NLDEventCollector.h
//  LDEventCollection
//
//  Created by SongLi on 5/17/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NLDEventCache;
@interface NLDEventCollector : NSObject

@property (nonatomic, copy, nonnull) NSString *channel;

@property (nonatomic, weak, readonly, nullable) NLDEventCache *eventCache;

- (nullable instancetype)initWithEventCache:(nonnull NLDEventCache *)eventCache appKey:(nonnull NSString *)appKey deviceId:(nonnull NSString *)deviceId channel:(nonnull NSString *)channel NS_DESIGNATED_INITIALIZER;

- (void)addEventName:(nonnull NSString *)eventName withParams:(nullable NSDictionary<NSString *, NSString *> *)params;

@end
