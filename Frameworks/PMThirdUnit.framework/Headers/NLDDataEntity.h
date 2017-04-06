//
//  NLDDataEntity.h
//  LDEventCollection
//
//  Created by SongLi on 5/17/16.
//  Copyright © 2016 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  只能存非nil的id类型，存储只能是强引用，通过toDictionary方法拿到数据，或者通过protocol的property方法获取数据。
 */
@interface NLDDataEntity<ProtocolType> : NSProxy <NSSecureCoding>

- (nullable NLDDataEntity<ProtocolType> *)initWithDictionary:(nullable NSDictionary<NSString *, id> *)dict;

- (nullable NLDDataEntity<ProtocolType> *)initWithProtocol:(nullable Protocol *)protocol;

- (nullable NLDDataEntity<ProtocolType> *)initWithDictionary:(nullable NSDictionary<NSString *, id> *)dict protocol:(nullable Protocol *)protocol;

- (NSDictionary<NSString *, id> *)toDictionary;

@end

NS_ASSUME_NONNULL_END
