//
//  NLDRemoteEventService.h
//  Pods
//
//  Created by 高振伟 on 16/8/8.
//
//

#import <Foundation/Foundation.h>

@class NLDRemoteEventModel;

NS_ASSUME_NONNULL_BEGIN

@interface NLDRemoteEventService : NSObject

@property (nonatomic, strong, readonly, nullable)NSArray<NLDRemoteEventModel *> *remoteEvents;

- (instancetype)initWithAppKey:(NSString *)appKey domain:(NSString *)domain;

- (void)fetchRemoteEvents;

- (nullable NSArray<NLDRemoteEventModel *> *)getRemoteEvents;

@end

NS_ASSUME_NONNULL_END
